import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/aset_model.dart';
import '../models/foto_aset_model.dart';
import '../models/satuan_waktu_model.dart';
import '../models/satuan_waktu_sewa_model.dart';
import 'package:intl/intl.dart';

class AsetProvider extends GetxService {
  late final SupabaseClient client;

  AsetProvider() {
    client = Supabase.instance.client;
  }

  // Mendapatkan semua aset dengan kategori "sewa"
  Future<List<AsetModel>> getSewaAsets() async {
    try {
      debugPrint('Fetching aset with kategori: sewa');

      // Query untuk mendapatkan semua aset dengan kategori "sewa"
      final response = await client
          .from('aset')
          .select('*')
          .eq('kategori', 'sewa')
          .eq('status', 'tersedia') // Hanya yang tersedia
          .order('nama', ascending: true); // Urutan berdasarkan nama

      debugPrint('Fetched ${response.length} aset');

      // Konversi response ke list AsetModel
      List<AsetModel> asets =
          response.map<AsetModel>((item) => AsetModel.fromJson(item)).toList();

      // Untuk setiap aset, ambil foto pertama dan satuan waktu sewa
      for (var aset in asets) {
        await _attachFirstPhoto(aset);
        await attachSatuanWaktuSewa(aset);
      }

      return asets;
    } catch (e) {
      debugPrint('Error fetching aset: $e');
      return [];
    }
  }

  // Mendapatkan semua aset dengan kategori "langganan"
  Future<List<AsetModel>> getLanggananAsets() async {
    try {
      debugPrint('Fetching aset with kategori: langganan');

      // Query untuk mendapatkan semua aset dengan kategori "langganan"
      final response = await client
          .from('aset')
          .select('*')
          .eq('kategori', 'langganan')
          .eq('status', 'tersedia') // Hanya yang tersedia
          .order('nama', ascending: true); // Urutan berdasarkan nama

      debugPrint('Fetched ${response.length} langganan aset');

      // Konversi response ke list AsetModel
      List<AsetModel> asets =
          response.map<AsetModel>((item) => AsetModel.fromJson(item)).toList();

      // Untuk setiap aset, ambil foto pertama dan satuan waktu sewa
      for (var aset in asets) {
        await _attachFirstPhoto(aset);
        await attachSatuanWaktuSewa(aset);
      }

      return asets;
    } catch (e) {
      debugPrint('Error fetching langganan asets: $e');
      return [];
    }
  }

  // Mendapatkan aset berdasarkan ID
  Future<AsetModel?> getAsetById(String asetId) async {
    try {
      debugPrint('📂 Fetching aset with ID: $asetId');

      // Query untuk mendapatkan aset dengan ID tertentu
      final response =
          await client.from('aset').select('*').eq('id', asetId).maybeSingle();

      debugPrint('📂 Raw response type: ${response.runtimeType}');
      debugPrint('📂 Raw response: $response');

      if (response == null) {
        debugPrint('❌ Aset dengan ID $asetId tidak ditemukan');
        return null;
      }

      debugPrint(
        '✅ Successfully fetched aset with ID: $asetId, name: ${response['nama']}',
      );

      // Konversi response ke AsetModel
      AsetModel aset = AsetModel.fromJson(response);
      debugPrint('✅ AsetModel created: ${aset.id} - ${aset.nama}');

      // Ambil foto dan satuan waktu sewa untuk aset ini
      await _attachFirstPhoto(aset);
      await attachSatuanWaktuSewa(aset);
      await loadAssetPhotos(aset);

      return aset;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching aset by ID: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      return null;
    }
  }

  // Load all photos for an asset
  Future<void> loadAssetPhotos(AsetModel aset) async {
    try {
      final photos = await getAsetPhotos(aset.id);
      if (photos.isNotEmpty &&
          (aset.imageUrl == null || aset.imageUrl!.isEmpty)) {
        aset.imageUrl = photos.first.fotoAset;
      }
    } catch (e) {
      debugPrint('Error loading asset photos for ID ${aset.id}: $e');
    }
  }

  // Fungsi untuk mengambil foto pertama dari aset
  Future<void> _attachFirstPhoto(AsetModel aset) async {
    try {
      final responsePhoto =
          await client
              .from('foto_aset')
              .select('*')
              .eq('id_aset', aset.id)
              .limit(1)
              .maybeSingle();

      if (responsePhoto != null) {
        final fotoAset = FotoAsetModel.fromJson(responsePhoto);
        aset.imageUrl = fotoAset.fotoAset;
      }
    } catch (e) {
      debugPrint('Error fetching photo for aset ${aset.id}: $e');
    }
  }

  // Fungsi untuk mendapatkan semua foto aset berdasarkan ID aset
  Future<List<FotoAsetModel>> getAsetPhotos(String asetId) async {
    try {
      debugPrint('Fetching photos for aset ID: $asetId');

      final response = await client
          .from('foto_aset')
          .select('*')
          .eq('id_aset', asetId)
          .order('created_at');

      debugPrint('Fetched ${response.length} photos for aset ID: $asetId');

      // Konversi response ke list FotoAsetModel
      return (response as List)
          .map<FotoAsetModel>((item) => FotoAsetModel.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error fetching photos for aset ID $asetId: $e');
      return [];
    }
  }

  // Retrieve bookings for a specific asset on a specific date
  Future<List<Map<String, dynamic>>> getAsetBookings(
    String asetId,
    String date,
  ) async {
    try {
      // Convert the date to DateTime for comparison
      final targetDate = DateTime.parse(date);
      debugPrint('🔍 Fetching bookings for asset $asetId on date $date');

      // Query booked_detail table (previously was sewa_aset table) for bookings related to this asset
      final response = await client
          .from('booked_detail')
          .select('id, waktu_mulai, waktu_selesai, sewa_aset_id, kuantitas')
          .eq('aset_id', asetId)
          .order('waktu_mulai', ascending: true);

      // Filter bookings to only include those that overlap with our target date
      final bookingsForDate =
          response.where((booking) {
            if (booking['waktu_mulai'] == null ||
                booking['waktu_selesai'] == null) {
              debugPrint('⚠️ Booking has null timestamp: $booking');
              return false;
            }

            // Parse the timestamps
            final DateTime waktuMulai = DateTime.parse(booking['waktu_mulai']);
            final DateTime waktuSelesai = DateTime.parse(
              booking['waktu_selesai'],
            );

            // Check if booking overlaps with our target date
            final bookingStartDate = DateTime(
              waktuMulai.year,
              waktuMulai.month,
              waktuMulai.day,
            );
            final bookingEndDate = DateTime(
              waktuSelesai.year,
              waktuSelesai.month,
              waktuSelesai.day,
            );

            final targetDateOnly = DateTime(
              targetDate.year,
              targetDate.month,
              targetDate.day,
            );

            // The booking overlaps with our target date if:
            // 1. The booking starts on or before our target date AND
            // 2. The booking ends on or after our target date
            return !bookingStartDate.isAfter(targetDateOnly) &&
                !bookingEndDate.isBefore(targetDateOnly);
          }).toList();

      debugPrint(
        '📅 Found ${bookingsForDate.length} bookings for date $date from booked_detail table',
      );

      // Return the complete booking information with original timestamps
      return bookingsForDate.map((booking) {
        // Parse the timestamps for debugging
        final DateTime waktuMulai = DateTime.parse(booking['waktu_mulai']);
        final DateTime waktuSelesai = DateTime.parse(booking['waktu_selesai']);

        // Return the full booking data with formatted display times
        return {
          'id':
              booking['sewa_aset_id'] ??
              booking['id'], // Use sewa_aset_id as id if available
          'waktu_mulai': booking['waktu_mulai'], // Keep original ISO timestamp
          'waktu_selesai':
              booking['waktu_selesai'], // Keep original ISO timestamp
          'jam_mulai': DateFormat('HH:mm').format(waktuMulai), // For display
          'jam_selesai': DateFormat(
            'HH:mm',
          ).format(waktuSelesai), // For display
          'tanggal_mulai': DateFormat(
            'yyyy-MM-dd',
          ).format(waktuMulai), // For calculations
          'tanggal_selesai': DateFormat(
            'yyyy-MM-dd',
          ).format(waktuSelesai), // For calculations
          'kuantitas':
              booking['kuantitas'] ?? 1, // Default to 1 if not specified
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting asset bookings: $e');
      return [];
    }
  }

  // Fungsi untuk membuat pesanan sewa aset
  Future<bool> createSewaAsetOrder(Map<String, dynamic> orderData) async {
    try {
      debugPrint('🔄 Creating sewa_aset order with data:');
      orderData.forEach((key, value) {
        debugPrint('   $key: $value');
      });

      final response =
          await client.from('sewa_aset').insert(orderData).select().single();

      debugPrint('✅ Order created successfully: ${response['id']}');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating sewa_aset order: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');

      // Check for specific error types
      if (e.toString().contains('duplicate key')) {
        debugPrint('❌ This appears to be a duplicate key error');
      } else if (e.toString().contains('violates foreign key constraint')) {
        debugPrint('❌ This appears to be a foreign key constraint violation');
      } else if (e.toString().contains('violates not-null constraint')) {
        debugPrint('❌ This appears to be a null value in a required field');
      }

      return false;
    }
  }

  // Fungsi untuk membuat tagihan sewa
  Future<bool> createTagihanSewa(Map<String, dynamic> tagihanData) async {
    try {
      debugPrint('🔄 Creating tagihan_sewa with data:');
      tagihanData.forEach((key, value) {
        debugPrint('   $key: $value');
      });

      // Ensure we don't try to insert a nama_aset field that no longer exists
      if (tagihanData.containsKey('nama_aset')) {
        debugPrint(
          '⚠️ Removing nama_aset field from tagihan_sewa data as it does not exist in the table',
        );
        tagihanData.remove('nama_aset');
      }

      final response =
          await client
              .from('tagihan_sewa')
              .insert(tagihanData)
              .select()
              .single();

      debugPrint('✅ Tagihan created successfully: ${response['id']}');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating tagihan_sewa: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');

      // Check for specific error types
      if (e.toString().contains('duplicate key')) {
        debugPrint('❌ This appears to be a duplicate key error');
      } else if (e.toString().contains('violates foreign key constraint')) {
        debugPrint('❌ This appears to be a foreign key constraint violation');
      } else if (e.toString().contains('violates not-null constraint')) {
        debugPrint('❌ This appears to be a null value in a required field');
      } else if (e.toString().contains('Could not find the')) {
        debugPrint(
          '❌ This appears to be a column mismatch error - check field names',
        );
        // Print the field names from the data to help debug
        debugPrint('❌ Fields in provided data: ${tagihanData.keys.toList()}');
      }

      return false;
    }
  }

  // Fungsi untuk membuat booked detail
  Future<bool> createBookedDetail(Map<String, dynamic> bookedDetailData) async {
    try {
      debugPrint('🔄 Creating booked_detail with data:');
      bookedDetailData.forEach((key, value) {
        debugPrint('   $key: $value');
      });

      // Ensure we don't try to insert a status field that no longer exists
      if (bookedDetailData.containsKey('status')) {
        debugPrint(
          '⚠️ Removing status field from booked_detail data as it does not exist in the table',
        );
        bookedDetailData.remove('status');
      }

      final response =
          await client
              .from('booked_detail')
              .insert(bookedDetailData)
              .select()
              .single();

      debugPrint('✅ Booked detail created successfully: ${response['id']}');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating booked_detail: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');

      // Check for specific error types
      if (e.toString().contains('duplicate key')) {
        debugPrint('❌ This appears to be a duplicate key error');
      } else if (e.toString().contains('violates foreign key constraint')) {
        debugPrint('❌ This appears to be a foreign key constraint violation');
      } else if (e.toString().contains('violates not-null constraint')) {
        debugPrint('❌ This appears to be a null value in a required field');
      } else if (e.toString().contains('Could not find the')) {
        debugPrint(
          '❌ This appears to be a column mismatch error - check field names',
        );
        // Print the field names from the data to help debug
        debugPrint(
          '❌ Fields in provided data: ${bookedDetailData.keys.toList()}',
        );
      }

      return false;
    }
  }

  // Fungsi untuk membuat pesanan lengkap (sewa_aset, booked_detail, dan tagihan_sewa) dalam satu operasi
  Future<bool> createCompleteOrder({
    required Map<String, dynamic> sewaAsetData,
    required Map<String, dynamic> bookedDetailData,
    required Map<String, dynamic> tagihanSewaData,
  }) async {
    try {
      debugPrint('🔄 Creating complete order with transaction');
      debugPrint('📦 sewa_aset data:');
      sewaAsetData.forEach((key, value) => debugPrint('   $key: $value'));

      debugPrint('📦 booked_detail data:');
      bookedDetailData.forEach((key, value) => debugPrint('   $key: $value'));

      // Ensure we don't try to insert a status field that no longer exists
      if (bookedDetailData.containsKey('status')) {
        debugPrint(
          '⚠️ Removing status field from booked_detail data as it does not exist in the table',
        );
        bookedDetailData.remove('status');
      }

      debugPrint('📦 tagihan_sewa data:');
      tagihanSewaData.forEach((key, value) => debugPrint('   $key: $value'));

      // Ensure we don't try to insert a nama_aset field that no longer exists
      if (tagihanSewaData.containsKey('nama_aset')) {
        debugPrint(
          '⚠️ Removing nama_aset field from tagihan_sewa data as it does not exist in the table',
        );
        tagihanSewaData.remove('nama_aset');
      }

      // Insert all three records
      final sewaAsetResult =
          await client.from('sewa_aset').insert(sewaAsetData).select().single();
      debugPrint('✅ sewa_aset created: ${sewaAsetResult['id']}');

      final bookedDetailResult =
          await client
              .from('booked_detail')
              .insert(bookedDetailData)
              .select()
              .single();
      debugPrint('✅ booked_detail created: ${bookedDetailResult['id']}');

      final tagihanSewaResult =
          await client
              .from('tagihan_sewa')
              .insert(tagihanSewaData)
              .select()
              .single();
      debugPrint('✅ tagihan_sewa created: ${tagihanSewaResult['id']}');

      debugPrint('✅ Complete order created successfully!');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating complete order: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');

      // Check for specific error types
      if (e.toString().contains('duplicate key')) {
        debugPrint('❌ This appears to be a duplicate key error');
      } else if (e.toString().contains('violates foreign key constraint')) {
        debugPrint('❌ This appears to be a foreign key constraint violation');
      } else if (e.toString().contains('violates not-null constraint')) {
        debugPrint('❌ This appears to be a null value in a required field');
      } else if (e.toString().contains('Could not find the')) {
        debugPrint(
          '❌ This appears to be a column mismatch error - check field names',
        );
        // Print the field names from each data object to help debug
        debugPrint('❌ Fields in sewa_aset data: ${sewaAsetData.keys.toList()}');
        debugPrint(
          '❌ Fields in booked_detail data: ${bookedDetailData.keys.toList()}',
        );
        debugPrint(
          '❌ Fields in tagihan_sewa data: ${tagihanSewaData.keys.toList()}',
        );
      }

      return false;
    }
  }

  // Fungsi untuk mendapatkan data satuan waktu berdasarkan ID dari tabel `satuan_waktu`
  Future<SatuanWaktuModel?> getSatuanWaktuById(String id) async {
    try {
      // Asumsikan client adalah instance Supabase (atau library serupa)
      final response =
          await client
              .from('satuan_waktu')
              .select('*')
              .eq('id', id)
              .maybeSingle();

      if (response == null) {
        debugPrint('Tidak ditemukan data satuan waktu untuk id: $id');
        return null;
      }

      return SatuanWaktuModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching satuan waktu by id: $e');
      return null;
    }
  }

  // Fungsi untuk mendapatkan semua data satuan waktu dari tabel `satuan_waktu`
  // Biasanya digunakan untuk menampilkan pilihan pada form atau filter
  Future<List<SatuanWaktuModel>> getAllSatuanWaktu() async {
    try {
      final response = await client
          .from('satuan_waktu')
          .select('*')
          .order('nama_satuan_waktu', ascending: true);

      // Pastikan response berupa list
      return (response as List)
          .map<SatuanWaktuModel>((item) => SatuanWaktuModel.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all satuan waktu: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan data satuan waktu sewa untuk suatu aset tertentu
  // Data diambil dari tabel `satuan_waktu_sewa` dan langsung melakukan join ke tabel `satuan_waktu`
  Future<List<Map<String, dynamic>>> getSatuanWaktuSewa(String asetId) async {
    try {
      debugPrint('Fetching satuan waktu sewa for aset $asetId with join...');

      // Query untuk mendapatkan data dari satuan_waktu_sewa dengan join ke satuan_waktu
      final response = await client
          .from('satuan_waktu_sewa')
          .select('''
            id, 
            aset_id, 
            satuan_waktu_id, 
            harga, 
            denda,
            maksimal_waktu,
            satuan_waktu:satuan_waktu_id(id, nama_satuan_waktu)
          ''')
          .eq('aset_id', asetId);

      debugPrint('Join query raw response type: ${response.runtimeType}');
      debugPrint('Join query raw response: $response');

      List<Map<String, dynamic>> result = [];

      debugPrint('Response is List with ${response.length} items');
      for (var item in response) {
        try {
          debugPrint('Processing item: $item');

          // Pengecekan null dan tipe data yang lebih aman
          var satuanWaktu = item['satuan_waktu'];
          String namaSatuanWaktu = '';

          if (satuanWaktu != null) {
            if (satuanWaktu is Map) {
              // Jika satuan_waktu adalah Map
              namaSatuanWaktu =
                  satuanWaktu['nama_satuan_waktu']?.toString() ?? '';
            } else if (satuanWaktu is List && satuanWaktu.isNotEmpty) {
              // Jika satuan_waktu adalah List
              var firstItem = satuanWaktu.first;
              if (firstItem is Map) {
                namaSatuanWaktu =
                    firstItem['nama_satuan_waktu']?.toString() ?? '';
              }
            }
          }

          final resultItem = {
            'id': item['id']?.toString() ?? '',
            'aset_id': item['aset_id']?.toString() ?? '',
            'satuan_waktu_id': item['satuan_waktu_id']?.toString() ?? '',
            'harga': item['harga'] ?? 0,
            'denda': item['denda'] ?? 0,
            'maksimal_waktu': item['maksimal_waktu'] ?? 0,
            'nama_satuan_waktu': namaSatuanWaktu,
          };

          debugPrint('Successfully processed item: $resultItem');
          result.add(resultItem);
        } catch (e) {
          debugPrint('Error processing item: $e');
          debugPrint('Item data: $item');
        }
      }

      debugPrint(
        'Processed ${result.length} satuan waktu sewa records for aset $asetId',
      );
      return result;
    } catch (e) {
      debugPrint('Error fetching satuan waktu sewa for aset $asetId: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Fungsi untuk melampirkan data satuan waktu sewa ke model aset secara langsung
  // Fungsi ini akan dipanggil misalnya saat Anda memuat detail aset atau list aset
  Future<void> attachSatuanWaktuSewa(AsetModel aset) async {
    try {
      debugPrint(
        'Attaching satuan waktu sewa to aset ${aset.id} (${aset.nama})',
      );

      // Ambil semua data satuan waktu sewa untuk aset tersebut
      final satuanWaktuSewaList = await getSatuanWaktuSewa(aset.id);

      // Urutkan data satuan waktu sewa, Jam dulu, kemudian Hari, kemudian lainnya
      satuanWaktuSewaList.sort((a, b) {
        final namaA = (a['nama_satuan_waktu'] ?? '').toString().toLowerCase();
        final namaB = (b['nama_satuan_waktu'] ?? '').toString().toLowerCase();

        // Jika ada 'jam', tempatkan di urutan pertama
        if (namaA.contains('jam') && !namaB.contains('jam')) {
          return -1;
        }
        // Jika ada 'hari', tempatkan di urutan kedua
        else if (!namaA.contains('jam') &&
            namaA.contains('hari') &&
            !namaB.contains('jam') &&
            !namaB.contains('hari')) {
          return -1;
        }
        // Jika keduanya 'jam' atau keduanya 'hari' atau keduanya lainnya, pertahankan urutan asli
        else if ((namaA.contains('jam') && namaB.contains('jam')) ||
            (namaA.contains('hari') && namaB.contains('hari'))) {
          return 0;
        }
        // Jika b adalah 'jam', tempatkan b lebih dulu
        else if (!namaA.contains('jam') && namaB.contains('jam')) {
          return 1;
        }
        // Jika b adalah 'hari' dan a bukan 'jam', tempatkan b lebih dulu
        else if (!namaA.contains('jam') &&
            !namaA.contains('hari') &&
            !namaB.contains('jam') &&
            namaB.contains('hari')) {
          return 1;
        }
        // Default, pertahankan urutan
        return 0;
      });

      debugPrint('Sorted satuan waktu sewa list: $satuanWaktuSewaList');

      // Bersihkan data lama dan masukkan data baru
      aset.satuanWaktuSewa.clear();
      aset.satuanWaktuSewa.addAll(satuanWaktuSewaList);

      // Debug: tampilkan data satuan waktu sewa yang berhasil dilampirkan
      if (satuanWaktuSewaList.isNotEmpty) {
        debugPrint(
          'Attached ${satuanWaktuSewaList.length} satuan waktu sewa to aset ${aset.id}:',
        );
        for (var sws in satuanWaktuSewaList) {
          debugPrint(
            '  - ID: ${sws['id']}, Harga: ${sws['harga']}, Satuan Waktu: ${sws['nama_satuan_waktu']} (${sws['satuan_waktu_id']})',
          );
        }
      } else {
        debugPrint('No satuan waktu sewa found for aset ${aset.id}');
      }
    } catch (e) {
      debugPrint('Error attaching satuan waktu sewa: $e');
    }
  }

  // Fungsi untuk memformat harga ke format rupiah (contoh: Rp 3.000)
  String formatPrice(int price) {
    // RegExp untuk menambahkan titik sebagai pemisah ribuan
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';

    // Pastikan angka dikonversi ke string
    var numStr = number.toString();

    // Tangani kasus ketika number bukan angka
    try {
      return numStr.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]}.',
      );
    } catch (e) {
      return numStr;
    }
  }

  // Method untuk pemesanan aset
  Future<bool> orderAset({
    required String userId,
    required String asetId,
    required String satuanWaktuSewaId,
    required int durasi,
    required int totalHarga,
  }) async {
    try {
      debugPrint('Creating order for aset $asetId by user $userId');

      // Dapatkan tanggal hari ini
      final tanggalPemesanan = DateTime.now().toIso8601String();

      // Buat pesanan baru
      final response =
          await client
              .from('pesanan')
              .insert({
                'user_id': userId,
                'aset_id': asetId,
                'satuan_waktu_sewa_id': satuanWaktuSewaId,
                'tanggal_pemesanan': tanggalPemesanan,
                'durasi': durasi,
                'total_harga': totalHarga,
                'status': 'pending', // Status awal pesanan
              })
              .select('id')
              .single();

      // Periksa apakah pesanan berhasil dibuat
      if (response['id'] != null) {
        debugPrint('Order created successfully with ID: ${response['id']}');
        return true;
      } else {
        debugPrint('Failed to create order: Response is null or missing ID');
        return false;
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      return false;
    }
  }

  // Get daily bookings for an asset for a date range
  Future<List<Map<String, dynamic>>> getAsetDailyBookings(
    String asetId,
    String startDate,
    String endDate,
  ) async {
    try {
      debugPrint(
        '🔍 Fetching daily bookings for asset $asetId from $startDate to $endDate from booked_detail table',
      );

      // Parse dates for comparison
      final startDateTime = DateTime.parse(startDate);
      final endDateTime = DateTime.parse(endDate);

      // Query booked_detail table (previously was sewa_aset table) for daily bookings related to this asset
      final response = await client
          .from('booked_detail')
          .select('id, waktu_mulai, waktu_selesai, sewa_aset_id, kuantitas')
          .eq('aset_id', asetId)
          .order('waktu_mulai', ascending: true);

      // Filter bookings that overlap with the requested date range
      final List<Map<String, dynamic>> bookingsInRange =
          response.where((booking) {
            if (booking['waktu_mulai'] == null ||
                booking['waktu_selesai'] == null) {
              debugPrint('⚠️ Booking has null dates: $booking');
              return false;
            }

            // Parse the dates
            final DateTime bookingStartDate = DateTime.parse(
              booking['waktu_mulai'],
            );
            final DateTime bookingEndDate = DateTime.parse(
              booking['waktu_selesai'],
            );

            // A booking overlaps with our date range if:
            // 1. The booking ends after or on our start date AND
            // 2. The booking starts before or on our end date
            return !bookingEndDate.isBefore(startDateTime) &&
                !bookingStartDate.isAfter(endDateTime);
          }).toList();

      debugPrint(
        '📅 Found ${bookingsInRange.length} bookings in the specified range from booked_detail table',
      );

      // Debug the booking details
      if (bookingsInRange.isNotEmpty) {
        for (var booking in bookingsInRange) {
          debugPrint(
            '📋 Booking ID: ${booking['sewa_aset_id'] ?? booking['id']}',
          );
          debugPrint('   - Start: ${booking['waktu_mulai']}');
          debugPrint('   - End: ${booking['waktu_selesai']}');
          debugPrint('   - Quantity: ${booking['kuantitas']}');
        }
      }

      return bookingsInRange.map((booking) {
        final Map<String, dynamic> result = Map<String, dynamic>.from(booking);
        // Use sewa_aset_id as the id if available
        if (booking['sewa_aset_id'] != null) {
          result['id'] = booking['sewa_aset_id'];
        }
        return result;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting daily bookings: $e');
      return [];
    }
  }

  bool _isBeforeToday(DateTime date) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    // Return true if date is today or before today (meaning it should be disabled)
    return !checkDate.isAfter(todayDate);
  }

  // Get tagihan sewa by sewa_aset_id
  Future<Map<String, dynamic>?> getTagihanSewa(String sewaAsetId) async {
    try {
      debugPrint('🔍 Fetching tagihan sewa for sewa_aset_id: $sewaAsetId');

      final response =
          await client
              .from('tagihan_sewa')
              .select('*')
              .eq('sewa_aset_id', sewaAsetId)
              .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ No tagihan sewa found for sewa_aset_id: $sewaAsetId');
        return null;
      }

      debugPrint('✅ Tagihan sewa found: ${response['id']}');
      return response;
    } catch (e) {
      debugPrint('❌ Error fetching tagihan sewa: $e');
      return null;
    }
  }
  
  // Get bank accounts from akun_bank table
  Future<List<Map<String, dynamic>>> getBankAccounts() async {
    try {
      debugPrint('🔍 Fetching bank accounts from akun_bank table');
      
      final response = await client
          .from('akun_bank')
          .select('*')
          .order('nama_bank', ascending: true);
          
      debugPrint('✅ Fetched ${response.length} bank accounts');
      
      // Convert response to List<Map<String, dynamic>>
      List<Map<String, dynamic>> accounts = List<Map<String, dynamic>>.from(response);
      
      return accounts;
    } catch (e) {
      debugPrint('❌ Error fetching bank accounts: $e');
      return [];
    }
  }

  // Get sewa_aset details with aset data
  Future<Map<String, dynamic>?> getSewaAsetWithAsetData(
    String sewaAsetId,
  ) async {
    try {
      debugPrint('🔍 Fetching sewa_aset with aset data for id: $sewaAsetId');

      // First get the sewa_aset record
      debugPrint('📊 Executing query: FROM sewa_aset WHERE id = $sewaAsetId');
      final sewaResponse =
          await client
              .from('sewa_aset')
              .select('*')
              .eq('id', sewaAsetId)
              .maybeSingle();

      if (sewaResponse == null) {
        debugPrint('⚠️ No sewa_aset found with id: $sewaAsetId');
        return null;
      }

      debugPrint('📋 Raw sewa_aset response:');
      sewaResponse.forEach((key, value) {
        debugPrint('  $key: $value');
      });

      // Get the aset_id from the sewa_aset record
      final asetId = sewaResponse['aset_id'];
      if (asetId == null) {
        debugPrint('⚠️ sewa_aset record has no aset_id');
        return sewaResponse;
      }

      debugPrint('🔍 Found aset_id: $asetId, now fetching aset details');

      // Get the aset details
      final asetResponse =
          await client.from('aset').select('*').eq('id', asetId).maybeSingle();

      if (asetResponse == null) {
        debugPrint('⚠️ No aset found with id: $asetId');
        return sewaResponse;
      }

      // Combine the data
      final result = Map<String, dynamic>.from(sewaResponse);
      result['aset_detail'] = asetResponse;

      debugPrint('✅ Combined sewa_aset and aset data successfully');
      debugPrint('📋 Final combined data:');
      result.forEach((key, value) {
        if (key != 'aset_detail') {
          // Skip the nested object for clearer output
          debugPrint('  $key: $value');
        }
      });

      // Specifically check waktu_mulai and waktu_selesai
      debugPrint('⏰ CRITICAL TIME FIELDS CHECK:');
      debugPrint('  waktu_mulai exists: ${result.containsKey('waktu_mulai')}');
      debugPrint('  waktu_mulai value: ${result['waktu_mulai']}');
      debugPrint(
        '  waktu_selesai exists: ${result.containsKey('waktu_selesai')}',
      );
      debugPrint('  waktu_selesai value: ${result['waktu_selesai']}');

      return result;
    } catch (e) {
      debugPrint('❌ Error fetching sewa_aset with aset data: $e');
      debugPrint('  Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Fungsi untuk mengambil foto pertama dari paket
  Future<String?> _getFirstPaketPhoto(String paketId) async {
    try {
      debugPrint('Fetching first photo for paket ID: $paketId');
      final responsePhoto =
          await client
              .from('foto_aset')
              .select('*')
              .eq('id_paket', paketId)
              .limit(1)
              .maybeSingle();

      if (responsePhoto != null) {
        debugPrint(
          'Found photo for paket $paketId: ${responsePhoto['foto_aset']}',
        );
        return responsePhoto['foto_aset'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching photo for paket $paketId: $e');
      return null;
    }
  }
  
  // Get all photos for a paket using id_paket column
  Future<List<dynamic>> getFotoPaket(String paketId) async {
    try {
      debugPrint('📷 Fetching all photos for paket ID: $paketId');
      
      final response = await client
          .from('foto_aset')
          .select('*')
          .eq('id_paket', paketId);
      
      if (response.isEmpty) {
        debugPrint('⚠️ No photos found for paket $paketId');
        return [];
      }
      
      debugPrint('✅ Found ${response.length} photos for paket $paketId');
      return response;
    } catch (e) {
      debugPrint('❌ Error fetching photos for paket $paketId: $e');
      return [];
    }
  }

  // Get paket data with their associated satuan waktu sewa data
  Future<List<dynamic>> getPakets() async {
    try {
      final response = await client
          .from('paket')
          .select('*')
          .order('created_at');
      final List<dynamic> pakets = response;

      // Fetch satuan waktu sewa data for each paket
      for (var paket in pakets) {
        // Fetch the first photo for this paket
        final paketId = paket['id'];
        final photoUrl = await _getFirstPaketPhoto(paketId);
        if (photoUrl != null) {
          paket['gambar_url'] = photoUrl;
        }

        final swsResponse = await client
            .from('satuan_waktu_sewa')
            .select('*, satuan_waktu(id, nama_satuan_waktu)')
            .eq('paket_id', paket['id']);

        // Transform the response to include nama_satuan_waktu
        final List<Map<String, dynamic>> formattedSWS = [];
        for (var sws in swsResponse) {
          final Map<String, dynamic> formattedItem = {...sws};
          if (sws['satuan_waktu'] != null) {
            formattedItem['nama_satuan_waktu'] =
                sws['satuan_waktu']['nama_satuan_waktu'];
          }
          formattedSWS.add(formattedItem);
        }

        paket['satuanWaktuSewa'] = formattedSWS;
      }

      return pakets;
    } catch (e) {
      debugPrint('Error getting pakets: $e');
      rethrow;
    }
  }

  // Order a paket
  Future<bool> orderPaket({
    required String userId,
    required String paketId,
    required String satuanWaktuSewaId,
    required int durasi,
    required int totalHarga,
  }) async {
    try {
      // Get satuan waktu sewa details to determine waktu_mulai and waktu_selesai
      final swsResponse =
          await client
              .from('satuan_waktu_sewa')
              .select('*, satuan_waktu(id, nama)')
              .eq('id', satuanWaktuSewaId)
              .single();

      // Calculate waktu_mulai and waktu_selesai based on satuan waktu
      final DateTime now = DateTime.now();
      final DateTime waktuMulai = now.add(Duration(days: 1)); // Start tomorrow

      // Default to hourly if not specified
      String satuanWaktu = 'jam';
      if (swsResponse != null &&
          swsResponse['satuan_waktu'] != null &&
          swsResponse['satuan_waktu']['nama'] != null) {
        satuanWaktu = swsResponse['satuan_waktu']['nama'];
      }

      // Calculate waktu_selesai based on satuan waktu and durasi
      DateTime waktuSelesai;
      if (satuanWaktu.toLowerCase() == 'hari') {
        waktuSelesai = waktuMulai.add(Duration(days: durasi));
      } else {
        waktuSelesai = waktuMulai.add(Duration(hours: durasi));
      }

      // Create the order
      final sewa = {
        'user_id': userId,
        'paket_id': paketId,
        'satuan_waktu_sewa_id': satuanWaktuSewaId,
        'kuantitas': 1, // Default to 1 for packages
        'durasi': durasi,
        'total_harga': totalHarga,
        'status': 'MENUNGGU_PEMBAYARAN',
        'waktu_mulai': waktuMulai.toIso8601String(),
        'waktu_selesai': waktuSelesai.toIso8601String(),
      };

      final response = await client.from('sewa_paket').insert(sewa).select();

      if (response != null && response.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error ordering paket: $e');
      return false;
    }
  }
}
