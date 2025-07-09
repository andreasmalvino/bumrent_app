import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../data/providers/aset_provider.dart';
import '../../../theme/app_colors_petugas.dart';

class PetugasLaporanController extends GetxController {
  final AsetProvider asetProvider = Get.find<AsetProvider>();

  // Observable variables
  final isLoading = false.obs;
  final isPdfReady = false.obs;
  final pdfBytes = Rx<Uint8List?>(null);
  final reportData = {}.obs;

  // Filter variables
  final selectedMonth = RxInt(DateTime.now().month);
  final selectedYear = RxInt(DateTime.now().year);

  // Available months and years for dropdown
  final months = <Map<String, dynamic>>[].obs;
  final years = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initMonthsAndYears();
  }

  // Initialize months and years for dropdown selection
  void _initMonthsAndYears() {
    final currentDate = DateTime.now();
    final currentMonth = currentDate.month;
    final currentYear = currentDate.year;

    // Initialize months
    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    months.clear();
    for (int i = 1; i <= 12; i++) {
      // Only include months up to current month for current year
      if (selectedYear.value < currentYear || i <= currentMonth) {
        months.add({'value': i, 'label': monthNames[i - 1]});
      }
    }

    // Initialize years (start from 2023 or adjust as needed)
    years.clear();
    for (int i = 2023; i <= currentYear; i++) {
      years.add(i);
    }

    // Set default to current month and year
    selectedMonth.value = currentMonth;
    selectedYear.value = currentYear;
  }

  // Update available months when year changes
  void onYearChanged(int? year) {
    if (year != null) {
      selectedYear.value = year;

      // Refresh months list based on selected year
      final currentDate = DateTime.now();
      final currentMonth = currentDate.month;
      final currentYear = currentDate.year;

      final monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      months.clear();
      for (int i = 1; i <= 12; i++) {
        // Only include months up to current month for current year
        if (selectedYear.value < currentYear || i <= currentMonth) {
          months.add({'value': i, 'label': monthNames[i - 1]});
        }
      }

      // Adjust selected month if necessary
      if (selectedYear.value == currentYear &&
          selectedMonth.value > currentMonth) {
        selectedMonth.value = currentMonth;
      }

      // Reset PDF if it was previously generated
      isPdfReady.value = false;
      pdfBytes.value = null;
    }
  }

  // Update selected month
  void onMonthChanged(int? month) {
    if (month != null) {
      selectedMonth.value = month;

      // Reset PDF if it was previously generated
      isPdfReady.value = false;
      pdfBytes.value = null;
    }
  }

  // Generate report based on selected month and year
  Future<void> generateReport() async {
    try {
      isLoading.value = true;

      // Format selected month and year for display
      final monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final monthName = monthNames[selectedMonth.value - 1];

      // Calculate date range for the selected month
      final startDate = DateTime(selectedYear.value, selectedMonth.value, 1);
      final endDate = DateTime(
        selectedYear.value,
        selectedMonth.value + 1,
        0,
      ); // Last day of month

      debugPrint('📊 Generating report for ${monthName} ${selectedYear.value}');
      debugPrint(
        '📅 Date range: ${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}',
      );

      // Fetch data from database
      await _fetchReportData(startDate, endDate);

      // Generate PDF
      final pdfData = await _generatePdf(
        Map<String, dynamic>.from(reportData.value),
      );
      pdfBytes.value = pdfData;
      isPdfReady.value = true;

      debugPrint('✅ Report generated successfully');
    } catch (e) {
      debugPrint('❌ Error generating report: $e');
      Get.snackbar(
        'Gagal',
        'Gagal membuat laporan: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch data for report
  Future<void> _fetchReportData(DateTime startDate, DateTime endDate) async {
    try {
      final reportDataMap = <String, dynamic>{};

      // Format dates for database queries
      final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

      // Calculate previous month date range
      final prevMonthStart = DateTime(
        startDate.month == 1 ? startDate.year - 1 : startDate.year,
        startDate.month == 1 ? 12 : startDate.month - 1,
        1,
      );
      final prevMonthEnd = DateTime(startDate.year, startDate.month, 0);
      final prevMonthStartStr = DateFormat('yyyy-MM-dd').format(prevMonthStart);
      final prevMonthEndStr = DateFormat('yyyy-MM-dd').format(prevMonthEnd);

      debugPrint('📊 Previous month: $prevMonthStartStr to $prevMonthEndStr');

      // 1. Fetch rental orders for the period
      final rentalOrders = await asetProvider.client
          .from('sewa_aset')
          .select('''
            id, 
            created_at, 
            user_id, 
            aset_id, 
            paket_id, 
            waktu_mulai, 
            waktu_selesai, 
            status, 
            total, 
            tipe_pesanan, 
            kuantitas
          ''')
          .gte('created_at', startDateStr)
          .lte('created_at', endDateStr)
          .order('created_at');

      // 1.1 Fetch previous month rental orders for comparison
      final prevMonthRentalOrders = await asetProvider.client
          .from('sewa_aset')
          .select('id, status, total')
          .gte('created_at', prevMonthStartStr)
          .lte('created_at', prevMonthEndStr);

      // 2. Get users data (renters)
      final userIds =
          (rentalOrders as List)
              .map((order) => order['user_id'].toString())
              .toSet()
              .toList();
      final users = await asetProvider.client
          .from('warga_desa')
          .select('id, nama_lengkap, email, no_hp')
          .inFilter('id', userIds);

      // 3. Get assets data
      final allAsset = await asetProvider.client
          .from('aset')
          .select('id, nama')
          .order('nama');

      final assetIds =
          (rentalOrders as List)
              .where((order) => order['tipe_pesanan'] == 'tunggal')
              .map((order) => order['aset_id'].toString())
              .where((id) => id != null)
              .toSet()
              .toList();

      final assets =
          assetIds.isNotEmpty
              ? await asetProvider.client
                  .from('aset')
                  .select('id, nama')
                  .inFilter('id', assetIds)
              : [];

      // 4. Get packages data
      final allPackage = await asetProvider.client
          .from('paket')
          .select('id, nama')
          .order('nama');

      final packageIds =
          (rentalOrders as List)
              .where((order) => order['tipe_pesanan'] == 'paket')
              .map((order) => order['paket_id'].toString())
              .where((id) => id != null)
              .toSet()
              .toList();

      final packages =
          packageIds.isNotEmpty
              ? await asetProvider.client
                  .from('paket')
                  .select('id, nama')
                  .inFilter('id', packageIds)
              : [];

      // 5. Get tagihan_sewa data
      final sewaIds =
          (rentalOrders as List)
              .map((order) => order['id'].toString())
              .toList();
      final tagihan = await asetProvider.client
          .from('tagihan_sewa')
          .select(
            'id, sewa_aset_id, durasi, satuan_waktu, harga_sewa, tagihan_awal, status_tagihan_awal, denda, status_denda',
          )
          .inFilter('sewa_aset_id', sewaIds);

      // 6. Get payment data
      final tagihanIds =
          (tagihan as List).map((t) => t['id'].toString()).toList();
      final payments =
          tagihanIds.isNotEmpty
              ? await asetProvider.client
                  .from('pembayaran')
                  .select(
                    'id, tagihan_sewa_id, metode_pembayaran, jenis_tagihan, total_pembayaran, status, waktu_pembayaran, created_at',
                  )
                  .inFilter('tagihan_sewa_id', tagihanIds)
              : [];

      // Process data for the report
      final userMap = {for (var user in users) user['id'].toString(): user};
      final assetMap = {
        for (var asset in assets) asset['id'].toString(): asset,
      };
      final packageMap = {for (var pkg in packages) pkg['id'].toString(): pkg};
      final tagihanMap = {
        for (var t in tagihan) t['sewa_aset_id'].toString(): t,
      };

      // Calculate summary statistics
      int totalOrders = rentalOrders.length;
      double totalRevenue = 0;
      int completedOrders = 0;
      int canceledOrders = 0;

      // Count distinct users (renters) with completed orders
      final Set<String> uniqueRenters = {};

      // Get completed orders filtered by updated_at for the selected month
      final completedOrdersWithDetails = await asetProvider.client
          .from('sewa_aset')
          .select('''
            id, 
            user_id, 
            aset_id, 
            paket_id, 
            total, 
            tipe_pesanan, 
            updated_at
          ''')
          .eq('status', 'SELESAI')
          .gte('updated_at', startDateStr)
          .lte('updated_at', endDateStr);

      final canceledOrdersData = await asetProvider.client
          .from('sewa_aset')
          .select('id, user_id, status, updated_at')
          .eq('status', 'DIBATALKAN')
          .gte('updated_at', startDateStr)
          .lte('updated_at', endDateStr);

      // Count completed orders
      completedOrders = completedOrdersWithDetails.length;

      // Count canceled orders
      canceledOrders = canceledOrdersData.length;

      // Add unique renters from completed orders
      for (var order in completedOrdersWithDetails) {
        final userId = order['user_id'].toString();
        uniqueRenters.add(userId);
      }

      // Calculate total revenue from payments
      for (var payment in payments) {
        if (payment['status'] == 'selesai') {
          // Use waktu_pembayaran to determine if payment falls within the current month
          final paymentDate = DateTime.parse(
            payment['waktu_pembayaran'] ?? payment['created_at'],
          );
          if (paymentDate.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              paymentDate.isBefore(endDate.add(const Duration(days: 1)))) {
            totalRevenue += (payment['total_pembayaran'] as num).toDouble();
          }
        }
      }

      // Calculate previous month revenue for comparison
      double prevMonthRevenue = 0;

      // Get all payments (not just for the previous month orders)
      final allPayments = await asetProvider.client
          .from('pembayaran')
          .select('total_pembayaran, status, waktu_pembayaran, created_at')
          .order('waktu_pembayaran');

      // Filter payments for previous month based on waktu_pembayaran
      for (var payment in allPayments) {
        if (payment['status'] == 'selesai') {
          final paymentDate = DateTime.parse(
            payment['waktu_pembayaran'] ?? payment['created_at'],
          );
          if (paymentDate.isAfter(
                prevMonthStart.subtract(const Duration(days: 1)),
              ) &&
              paymentDate.isBefore(prevMonthEnd.add(const Duration(days: 1)))) {
            prevMonthRevenue += (payment['total_pembayaran'] as num).toDouble();
          }
        }
      }

      // Calculate percentage change
      double? prevMonthComparison;
      if (prevMonthRevenue > 0) {
        prevMonthComparison =
            ((totalRevenue - prevMonthRevenue) / prevMonthRevenue) * 100;
        prevMonthComparison = double.parse(
          prevMonthComparison.toStringAsFixed(2),
        );
      }

      // Prepare daily revenue data for chart
      final dailyRevenue = <String, double>{};
      DateTime currentDate = startDate.copyWith();
      while (currentDate.isBefore(endDate) ||
          currentDate.isAtSameMomentAs(endDate)) {
        final dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
        dailyRevenue[dateStr] = 0;
        currentDate = currentDate.add(const Duration(days: 1));
      }

      // Fill in daily revenue data based on waktu_pembayaran
      for (var payment in payments) {
        if (payment['status'] == 'selesai') {
          final paymentDate = DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              payment['waktu_pembayaran'] ?? payment['created_at'],
            ),
          );
          if (dailyRevenue.containsKey(paymentDate)) {
            dailyRevenue[paymentDate] =
                dailyRevenue[paymentDate]! +
                (payment['total_pembayaran'] as num).toDouble();
          }
        }
      }

      // Store all collected data in the reportData object
      reportDataMap['period'] = {
        'month': selectedMonth.value,
        'monthName':
            months.firstWhere(
              (m) => m['value'] == selectedMonth.value,
            )['label'],
        'year': selectedYear.value,
        'startDate': startDateStr,
        'endDate': endDateStr,
      };

      reportDataMap['summary'] = {
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'completedOrders': completedOrders,
        'canceledOrders': canceledOrders,
        'uniqueRenters': uniqueRenters.length,
      };

      reportDataMap['prevMonthRevenue'] = prevMonthRevenue;
      reportDataMap['prevMonthComparison'] = prevMonthComparison;

      reportDataMap['rentalOrders'] = rentalOrders;
      reportDataMap['users'] = userMap;
      reportDataMap['assets'] = assetMap;
      reportDataMap['packages'] = packageMap;
      reportDataMap['tagihan'] = tagihanMap;
      reportDataMap['payments'] = payments;
      reportDataMap['dailyRevenue'] = dailyRevenue;
      reportDataMap['allAsset'] = allAsset;
      reportDataMap['allPackage'] = allPackage;

      // Save completed orders with details for asset performance analysis
      reportDataMap['completedOrdersWithDetails'] = completedOrdersWithDetails;

      // Calculate payment type summary (Sewa and Denda)
      double totalSewa = 0;
      double totalDenda = 0;

      for (var payment in payments) {
        if (payment['status'] == 'selesai') {
          // Use waktu_pembayaran to determine if payment falls within the current month
          final paymentDate = DateTime.parse(
            payment['waktu_pembayaran'] ?? payment['created_at'],
          );
          if (paymentDate.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              paymentDate.isBefore(endDate.add(const Duration(days: 1)))) {
            // Group by jenis_tagihan
            final jenisTagihan =
                payment['jenis_tagihan']?.toString()?.toLowerCase() ?? '';
            final amount = (payment['total_pembayaran'] as num).toDouble();

            if (jenisTagihan == 'sewa') {
              totalSewa += amount;
            } else if (jenisTagihan == 'denda') {
              totalDenda += amount;
            }
          }
        }
      }

      // Add payment type summary data
      reportDataMap['paymentTypeSummary'] = {
        'totalSewa': totalSewa,
        'totalDenda': totalDenda,
      };

      // Prepare daily payment data for the daily payment table
      final dailyPaymentData = <String, Map<String, double>>{};
      DateTime paymentDate = startDate.copyWith();
      while (paymentDate.isBefore(endDate) ||
          paymentDate.isAtSameMomentAs(endDate)) {
        final dateStr = DateFormat('yyyy-MM-dd').format(paymentDate);
        dailyPaymentData[dateStr] = {'sewa': 0, 'denda': 0, 'total': 0};
        paymentDate = paymentDate.add(const Duration(days: 1));
      }

      // Fill in daily payment data based on waktu_pembayaran and jenis_tagihan
      for (var payment in payments) {
        if (payment['status'] == 'selesai') {
          final paymentDate = DateTime.parse(
            payment['waktu_pembayaran'] ?? payment['created_at'],
          );
          final dateStr = DateFormat('yyyy-MM-dd').format(paymentDate);

          if (dailyPaymentData.containsKey(dateStr)) {
            final jenisTagihan =
                payment['jenis_tagihan']?.toString()?.toLowerCase() ?? '';
            final amount = (payment['total_pembayaran'] as num).toDouble();

            if (jenisTagihan == 'sewa') {
              dailyPaymentData[dateStr]!['sewa'] =
                  dailyPaymentData[dateStr]!['sewa']! + amount;
            } else if (jenisTagihan == 'denda') {
              dailyPaymentData[dateStr]!['denda'] =
                  dailyPaymentData[dateStr]!['denda']! + amount;
            }

            dailyPaymentData[dateStr]!['total'] =
                dailyPaymentData[dateStr]!['total']! + amount;
          }
        }
      }

      reportDataMap['dailyPaymentData'] = dailyPaymentData;

      // Update the observable reportData
      reportData.value = reportDataMap;
    } catch (e) {
      debugPrint('❌ Error fetching report data: $e');
      throw Exception('Failed to fetch report data: $e');
    }
  }

  // Generate PDF report
  Future<Uint8List> _generatePdf(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();

    // Try to load logo (wrapped in try-catch in case logo is not available)
    pw.MemoryImage? logo;
    try {
      final logoData = await rootBundle.load('assets/images/logo.png');
      logo = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      debugPrint('⚠️ Logo not found: $e');
    }

    // Use basic fonts
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    // Title
    final title = 'Laporan Bulanan BUMDes Rental';
    final period =
        '${_getMonthName(selectedMonth.value)} ${selectedYear.value}';

    // Data preparation
    final orders = reportData['rentalOrders'] as List<dynamic>;
    final List<Map<String, dynamic>> typedOrders =
        orders
            .map(
              (order) =>
                  Map<String, dynamic>.from(order as Map<dynamic, dynamic>),
            )
            .toList();
    final users = Map<String, dynamic>.from(
      reportData['users'] as Map<dynamic, dynamic>,
    );
    final assets = Map<String, dynamic>.from(
      reportData['assets'] as Map<dynamic, dynamic>,
    );
    final packages = Map<String, dynamic>.from(
      reportData['packages'] as Map<dynamic, dynamic>,
    );
    final tagihan = Map<String, dynamic>.from(
      reportData['tagihan'] as Map<dynamic, dynamic>,
    );
    final payments = reportData['payments'] as List<dynamic>;
    final List<Map<String, dynamic>> typedPayments =
        payments
            .map(
              (payment) =>
                  Map<String, dynamic>.from(payment as Map<dynamic, dynamic>),
            )
            .toList();

    // 1. Asset Performance Analysis
    final assetRentalFrequency = <String, int>{};
    final assetRevenue = <String, double>{};
    final allAssetIds =
        (reportData['allAsset'] as List)
            .map((asset) => asset['id'].toString())
            .toList();
    final rentedAssetIds = <String>{};

    // 2. Package Performance Analysis
    final packageRentalFrequency = <String, int>{};
    final packageRevenue = <String, double>{};
    final allPackageIds =
        (reportData['allPackage'] as List)
            .map((pkg) => pkg['id'].toString())
            .toList();
    final rentedPackageIds = <String>{};

    // 4. Payment and Financial Analysis
    final paymentMethods = <String, double>{};
    final unpaidTransactions = <Map<String, dynamic>>[];
    final penaltyPayments = <Map<String, dynamic>>[];

    // Process data for analysis - only include completed orders
    final completedOrdersWithDetails =
        reportData['completedOrdersWithDetails'] as List<dynamic>;
    for (final order in completedOrdersWithDetails) {
      final String orderId = order['id'].toString();
      final bool isPackage = order['tipe_pesanan'] == 'paket';
      final String itemId =
          isPackage
              ? order['paket_id']?.toString() ?? ''
              : order['aset_id']?.toString() ?? '';

      if (itemId.isEmpty) continue; // Skip if no valid item ID

      final double total = double.parse(order['total']?.toString() ?? '0');

      // Asset/Package frequency and revenue
      if (isPackage) {
        rentedPackageIds.add(itemId);
        packageRentalFrequency[itemId] =
            (packageRentalFrequency[itemId] ?? 0) + 1;
        packageRevenue[itemId] = (packageRevenue[itemId] ?? 0) + total;
      } else {
        rentedAssetIds.add(itemId);
        assetRentalFrequency[itemId] = (assetRentalFrequency[itemId] ?? 0) + 1;
        assetRevenue[itemId] = (assetRevenue[itemId] ?? 0) + total;
      }

      // Payment analysis
      bool isPaid = false;
      bool hasPenalty = false;
      double penaltyAmount = 0;

      for (final payment in typedPayments) {
        if (payment['tagihan_sewa_id'].toString() ==
            tagihan[orderId]?['id']?.toString()) {
          isPaid = payment['status'] == 'selesai';
          final method = payment['metode_pembayaran'] ?? 'Tidak diketahui';
          paymentMethods[method] =
              (paymentMethods[method] ?? 0) +
              double.parse(payment['total_pembayaran'].toString());

          // Check for penalty
          if (payment['denda'] != null && payment['denda'] > 0) {
            hasPenalty = true;
            penaltyAmount = double.parse(payment['denda'].toString());
          }
        }
      }

      // Add to unpaid transactions
      if (!isPaid) {
        unpaidTransactions.add({
          'id': orderId,
          'user':
              users[order['user_id'].toString()]?['nama_lengkap'] ?? 'Unknown',
          'item':
              isPackage
                  ? (packages[itemId]?['nama'] ?? 'Unknown Package')
                  : (assets[itemId]?['nama'] ?? 'Unknown Asset'),
          'total': total,
          'date': order['created_at'] ?? 'Unknown',
        });
      }

      // Add to penalty payments
      if (hasPenalty) {
        penaltyPayments.add({
          'id': orderId,
          'user':
              users[order['user_id'].toString()]?['nama_lengkap'] ?? 'Unknown',
          'item':
              isPackage
                  ? (packages[itemId]?['nama'] ?? 'Unknown Package')
                  : (assets[itemId]?['nama'] ?? 'Unknown Asset'),
          'penalty': penaltyAmount,
          'date': order['created_at'] ?? 'Unknown',
        });
      }
    }

    // Initialize frequency and revenue for all assets
    for (final assetId in allAssetIds) {
      // Initialize with 0 for frequency if not already set
      if (!assetRentalFrequency.containsKey(assetId)) {
        assetRentalFrequency[assetId] = 0;
      }

      // Initialize with 0 for revenue if not already set
      if (!assetRevenue.containsKey(assetId)) {
        assetRevenue[assetId] = 0;
      }
    }

    // Find non-rented assets and packages
    final nonRentedAssetIds =
        allAssetIds.where((id) => !rentedAssetIds.contains(id)).toList();
    final nonRentedPackageIds =
        allPackageIds.where((id) => !rentedPackageIds.contains(id)).toList();

    // Sort assets and packages by frequency and revenue
    final topAssetsByFrequency =
        assetRentalFrequency.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final topAssetsByRevenue =
        assetRevenue.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // Create a list of all assets with their frequency and revenue
    final allAssetsWithData =
        (reportData['allAsset'] as List).map((asset) {
          final assetId = asset['id'].toString();
          final assetName = asset['nama'] ?? 'Unknown Asset';
          final frequency = assetRentalFrequency[assetId] ?? 0;
          final revenue = assetRevenue[assetId] ?? 0;
          return {
            'id': assetId,
            'name': assetName,
            'frequency': frequency,
            'revenue': revenue,
          };
        }).toList();

    // Sort by frequency (descending) for frequency table
    allAssetsWithData.sort(
      (a, b) => (b['frequency'] as int).compareTo(a['frequency'] as int),
    );
    final assetsByFrequency = List.from(allAssetsWithData);

    // Sort by revenue (descending) for revenue table
    allAssetsWithData.sort(
      (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double),
    );
    final assetsByRevenue = List.from(allAssetsWithData);

    // Create a list of all packages with their frequency and revenue
    final allPackagesWithData =
        (reportData['allPackage'] as List).map((pkg) {
          final packageId = pkg['id'].toString();
          final packageName = pkg['nama'] ?? 'Unknown Package';
          final frequency = packageRentalFrequency[packageId] ?? 0;
          final revenue = packageRevenue[packageId] ?? 0;
          return {
            'id': packageId,
            'name': packageName,
            'frequency': frequency,
            'revenue': revenue,
          };
        }).toList();

    // Sort by frequency (descending) for frequency table
    allPackagesWithData.sort(
      (a, b) => (b['frequency'] as int).compareTo(a['frequency'] as int),
    );
    final packagesByFrequency = List.from(allPackagesWithData);

    // Sort by revenue (descending) for revenue table
    allPackagesWithData.sort(
      (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double),
    );
    final packagesByRevenue = List.from(allPackagesWithData);

    // Sort packages by frequency and revenue
    final topPackagesByFrequency =
        packageRentalFrequency.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final topPackagesByRevenue =
        packageRevenue.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // Daily revenue data (already in reportData)
    final dailyRevenue = reportData['dailyRevenue'] as Map<String, double>;

    // Create the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'BUMDes Cahaya Buana Paku',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 24,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Laporan Bulanan Penyewaan Aset',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 16,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Periode: $period',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 14,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Tanggal Cetak: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              if (logo != null)
                pw.Container(width: 60, height: 60, child: pw.Image(logo)),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Executive Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'RINGKASAN EKSEKUTIF',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 14,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem(
                        'Total Pendapatan',
                        'Rp ${_formatCurrency(reportData['summary']['totalRevenue'])}',
                        font,
                        fontBold,
                      ),
                      _buildSummaryItem(
                        'Transaksi Selesai',
                        '${reportData['summary']['completedOrders']}',
                        font,
                        fontBold,
                      ),
                      _buildSummaryItem(
                        'Transaksi Dibatalkan',
                        '${reportData['summary']['canceledOrders']}',
                        font,
                        fontBold,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem(
                        'Total Penyewa',
                        '${reportData['summary']['uniqueRenters']}',
                        font,
                        fontBold,
                      ),
                      _buildSummaryItem(
                        'Perbandingan dengan Bulan Lalu',
                        reportData['prevMonthComparison'] != null
                            ? '${reportData['prevMonthComparison'] >= 0 ? '+' : ''}${reportData['prevMonthComparison']}%'
                            : 'Tidak ada data',
                        font,
                        fontBold,
                      ),
                      pw.SizedBox(width: 10), // Empty placeholder for alignment
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // 1. Asset Performance Analysis
            pw.Text(
              '1. ANALISIS KINERJA ASET',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 16,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 10),

            // Top assets by frequency
            pw.Text(
              'Aset dengan Frekuensi Penyewaan',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              border: null,
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue700,
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'No',
                        style: pw.TextStyle(
                          font: fontBold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Nama Aset',
                        style: pw.TextStyle(
                          font: fontBold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Frekuensi',
                        style: pw.TextStyle(
                          font: fontBold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                ...assetsByFrequency.asMap().entries.map((entry) {
                  final index = entry.key;
                  final asset = entry.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColors.grey300,
                          width: 0.5,
                        ),
                      ),
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text(
                          '${index + 1}',
                          style: pw.TextStyle(font: font, fontSize: 11),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text(
                          asset['name'] as String,
                          style: pw.TextStyle(font: font, fontSize: 11),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text(
                          '${asset['frequency']}',
                          style: pw.TextStyle(font: font, fontSize: 11),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            pw.SizedBox(height: 10),

            // Top assets by revenue
            pw.Text(
              'Aset dengan Total Pendapatan',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              border: null,
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue700,
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'No',
                        style: pw.TextStyle(
                          font: fontBold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Nama Aset',
                        style: pw.TextStyle(
                          font: fontBold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Pendapatan',
                        style: pw.TextStyle(
                          font: fontBold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                ...assetsByRevenue.asMap().entries.map((entry) {
                  final index = entry.key;
                  final asset = entry.value;
                  final double revenue = asset['revenue'] as double;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColors.grey300,
                          width: 0.5,
                        ),
                      ),
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text(
                          '${index + 1}',
                          style: pw.TextStyle(font: font, fontSize: 11),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text(
                          asset['name'] as String,
                          style: pw.TextStyle(font: font, fontSize: 11),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text(
                          revenue > 0 ? 'Rp ${_formatCurrency(revenue)}' : '-',
                          style: pw.TextStyle(font: font, fontSize: 11),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            pw.SizedBox(height: 10),

            // 2. Package Performance Analysis
            pw.Text(
              '2. ANALISIS KINERJA PAKET',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 16,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 10),

            // Top packages by frequency
            pw.Text(
              'Paket dengan Frekuensi Penyewaan',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'No',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Nama Paket',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Frekuensi',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...packagesByFrequency.asMap().entries.map((entry) {
                  final index = entry.key;
                  final pkg = entry.value;
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('${index + 1}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(pkg['name'] as String),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('${pkg['frequency']}'),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            pw.SizedBox(height: 10),

            // Top packages by revenue
            pw.Text(
              'Paket dengan Total Pendapatan',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'No',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Nama Paket',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Pendapatan',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...packagesByRevenue.asMap().entries.map((entry) {
                  final index = entry.key;
                  final pkg = entry.value;
                  final double revenue = pkg['revenue'] as double;
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('${index + 1}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(pkg['name'] as String),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          revenue > 0 ? 'Rp ${_formatCurrency(revenue)}' : '-',
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            pw.SizedBox(height: 10),

            // 3. Payments and Finance
            pw.Text(
              '3. PEMBAYARAN DAN KEUANGAN',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 16,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 10),

            // Payment methods summary
            pw.Text(
              'Ringkasan Pembayaran berdasarkan Metode Pembayaran',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'No',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Metode Pembayaran',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...paymentMethods.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final methodEntry = entry.value;
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('${index + 1}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(methodEntry.key),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Rp ${_formatCurrency(methodEntry.value)}',
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            pw.SizedBox(height: 15),

            // Daily Payment Table
            pw.Text(
              'Pembayaran Harian',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(1), // No
                1: const pw.FlexColumnWidth(3), // Tanggal
                2: const pw.FlexColumnWidth(2), // Sewa
                3: const pw.FlexColumnWidth(2), // Denda
                4: const pw.FlexColumnWidth(2), // Total
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'No',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Tanggal',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Sewa',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Denda',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                // Data rows
                ...(reportData['dailyPaymentData'] as Map<String, dynamic>)
                    .entries
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                      final index = entry.key;
                      final dateStr = entry.value.key;
                      final data = entry.value.value as Map<String, dynamic>;

                      // Format the date for display
                      final date = DateTime.parse(dateStr);
                      final formattedDate = DateFormat(
                        'dd MMMM yyyy',
                      ).format(date);

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('${index + 1}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(formattedDate),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              'Rp ${_formatCurrency(data['sewa'] ?? 0)}',
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              'Rp ${_formatCurrency(data['denda'] ?? 0)}',
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              'Rp ${_formatCurrency(data['total'] ?? 0)}',
                            ),
                          ),
                        ],
                      );
                    })
                    .toList(),

                // Total row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(''),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'TOTAL',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Rp ${_formatCurrency(reportData['paymentTypeSummary']?['totalSewa'] ?? 0)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Rp ${_formatCurrency(reportData['paymentTypeSummary']?['totalDenda'] ?? 0)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Rp ${_formatCurrency((reportData['paymentTypeSummary']?['totalSewa'] ?? 0) + (reportData['paymentTypeSummary']?['totalDenda'] ?? 0))}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),

            // Signature
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Dibuat oleh,', style: pw.TextStyle(font: font)),
                    pw.SizedBox(height: 60),
                    pw.Text(
                      '____________________',
                      style: pw.TextStyle(font: font),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Petugas BUMDes', style: pw.TextStyle(font: font)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Helper method to get month name from month number
  String _getMonthName(int month) {
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }
    return 'Unknown';
  }

  // Widget builder for summary items in PDF
  pw.Widget _buildSummaryItem(
    String title,
    String value,
    pw.Font regularFont,
    pw.Font boldFont,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 14,
            color: PdfColors.blue900,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    final formatter = NumberFormat('#,###');
    return formatter.format(double.parse(value.toString()));
  }

  // Preview the generated PDF
  void previewPdf() {
    if (isPdfReady.value && pdfBytes.value != null) {
      Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes.value!,
      );
    } else {
      Get.snackbar(
        'Tidak Ada Laporan',
        'Harap generate laporan terlebih dahulu',
        backgroundColor: Colors.amber[100],
        colorText: Colors.amber[900],
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Save PDF to device
  Future<void> savePdf() async {
    if (!isPdfReady.value || pdfBytes.value == null) {
      Get.snackbar(
        'Tidak Ada Laporan',
        'Harap generate laporan terlebih dahulu',
        backgroundColor: Colors.amber[100],
        colorText: Colors.amber[900],
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      final monthName = monthNames[selectedMonth.value - 1];
      final fileName = 'Laporan_${monthName}_${selectedYear.value}.pdf';
      final file = File('${dir.path}/$fileName');

      await file.writeAsBytes(pdfBytes.value!);

      Get.snackbar(
        'Berhasil',
        'Laporan disimpan di ${file.path}',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );

      // Open file
      // Note: You might need additional plugins for this functionality
      // such as open_file or url_launcher depending on platform
    } catch (e) {
      debugPrint('❌ Error saving PDF: $e');
      Get.snackbar(
        'Gagal',
        'Gagal menyimpan laporan: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Print PDF
  void printPdf() {
    if (!isPdfReady.value || pdfBytes.value == null) {
      Get.snackbar(
        'Tidak Ada Laporan',
        'Harap generate laporan terlebih dahulu',
        backgroundColor: Colors.amber[100],
        colorText: Colors.amber[900],
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes.value!,
      name:
          'Laporan_${reportData['period']['monthName']}_${reportData['period']['year']}',
    );
  }
}
