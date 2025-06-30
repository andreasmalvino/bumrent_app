import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../controllers/petugas_laporan_controller.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';
import '../widgets/petugas_side_navbar.dart';
import '../../../theme/app_colors_petugas.dart';

class PetugasLaporanView extends GetView<PetugasLaporanController> {
  const PetugasLaporanView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get dashboard controller for side navbar
    final dashboardController = Get.find<PetugasBumdesDashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Bulanan'),
        backgroundColor: AppColorsPetugas.navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Laporan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Bulan',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              value: controller.selectedMonth.value,
                              items:
                                  controller.months.map<DropdownMenuItem<int>>((
                                    month,
                                  ) {
                                    return DropdownMenuItem<int>(
                                      value: month['value'] as int,
                                      child: Text(month['label'] as String),
                                    );
                                  }).toList(),
                              onChanged: controller.onMonthChanged,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(
                            () => DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Tahun',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              value: controller.selectedYear.value,
                              items:
                                  controller.years.map<DropdownMenuItem<int>>((
                                    year,
                                  ) {
                                    return DropdownMenuItem<int>(
                                      value: year,
                                      child: Text(year.toString()),
                                    );
                                  }).toList(),
                              onChanged: controller.onYearChanged,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => ElevatedButton.icon(
                              onPressed:
                                  controller.isLoading.value
                                      ? null
                                      : controller.generateReport,
                              icon:
                                  controller.isLoading.value
                                      ? Container(
                                        width: 24,
                                        height: 24,
                                        padding: const EdgeInsets.all(2.0),
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                      : const Icon(Icons.refresh),
                              label: Text(
                                controller.isLoading.value
                                    ? 'Memproses...'
                                    : 'Generate Laporan',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColorsPetugas.blueGrotto,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                disabledBackgroundColor: AppColorsPetugas
                                    .blueGrotto
                                    .withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Report Preview Section
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Menghasilkan laporan...'),
                      ],
                    ),
                  );
                }

                if (!controller.isPdfReady.value ||
                    controller.pdfBytes.value == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada laporan',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pilih bulan dan tahun lalu klik "Generate Laporan"',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preview Laporan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Card(
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PdfPreview(
                          build: (format) => controller.pdfBytes.value!,
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          canDebug: false,
                          allowPrinting: false,
                          allowSharing: false,
                          initialPageFormat: PdfPageFormat.a4,
                          pdfFileName:
                              'Laporan_${controller.reportData['period']?['monthName'] ?? ''}_${controller.reportData['period']?['year'] ?? ''}.pdf',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: controller.savePdf,
                          icon: const Icon(Icons.save_alt),
                          label: const Text('Simpan PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorsPetugas.navyBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: controller.printPdf,
                          icon: const Icon(Icons.print),
                          label: const Text('Cetak'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorsPetugas.blueGrotto,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
