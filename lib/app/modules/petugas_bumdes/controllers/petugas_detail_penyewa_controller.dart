import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';

class PetugasDetailPenyewaController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();

  final isLoading = true.obs;
  final penyewaDetail = Rx<Map<String, dynamic>>({});
  final sewaHistory = <Map<String, dynamic>>[].obs;
  final userId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['userId'] != null) {
      userId.value = Get.arguments['userId'];
      fetchPenyewaDetail();
      fetchSewaHistory();
    } else {
      Get.back();
      Get.snackbar(
        'Error',
        'Data penyewa tidak ditemukan',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> fetchPenyewaDetail() async {
    try {
      isLoading.value = true;

      final data =
          await _authProvider.client
              .from('warga_desa')
              .select('*')
              .eq('user_id', userId.value)
              .single();

      if (data != null) {
        penyewaDetail.value = Map<String, dynamic>.from(data);
        print('Penyewa detail fetched: ${penyewaDetail.value}');
      }
    } catch (e) {
      print('Error fetching penyewa detail: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data penyewa',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSewaHistory() async {
    try {
      final data = await _authProvider.client
          .from('sewa_aset')
          .select('*')
          .eq('user_id', userId.value)
          .order('created_at', ascending: false);

      if (data != null) {
        sewaHistory.value = List<Map<String, dynamic>>.from(data);
        print('Sewa history fetched: ${sewaHistory.length} items');

        // Process data for each item
        for (int i = 0; i < sewaHistory.length; i++) {
          final item = sewaHistory[i];

          // Fetch tagihan data for this sewa_aset
          try {
            final tagihanResponse =
                await _authProvider.client
                    .from('tagihan_sewa')
                    .select('tagihan_awal, denda, tagihan_dibayar')
                    .eq('sewa_aset_id', item['id'])
                    .maybeSingle();

            if (tagihanResponse != null) {
              // Add tagihan data to the item
              sewaHistory[i] = {...item, 'tagihan_sewa': tagihanResponse};
            }
          } catch (e) {
            print('Error fetching tagihan for sewa_aset ${item['id']}: $e');
          }

          // Get the updated item after adding tagihan data
          final updatedItem = sewaHistory[i];

          // If this is a package rental (aset_id is null and paket_id exists)
          if (updatedItem['aset_id'] == null &&
              updatedItem['paket_id'] != null) {
            final String paketId = updatedItem['paket_id'];

            try {
              // Get package name from paket table
              final paketResponse =
                  await _authProvider.client
                      .from('paket')
                      .select('nama')
                      .eq('id', paketId)
                      .maybeSingle();

              // Get package photo from foto_aset table
              final fotoResponse =
                  await _authProvider.client
                      .from('foto_aset')
                      .select('foto_aset')
                      .eq('id_paket', paketId)
                      .limit(1)
                      .maybeSingle();

              // Create a synthetic aset object for paket
              Map<String, dynamic> syntheticAset = {};

              if (paketResponse != null) {
                syntheticAset['nama'] = paketResponse['nama'] ?? 'Paket';
              }

              if (fotoResponse != null) {
                syntheticAset['foto_utama'] = fotoResponse['foto_aset'];
              }

              // Update the item with the synthetic aset
              sewaHistory[i] = {
                ...updatedItem,
                'aset': syntheticAset,
                'tipe_pesanan': 'paket',
              };
            } catch (e) {
              print('Error fetching package details: $e');
            }
          }
          // If this is an asset rental (aset_id exists and paket_id is null)
          else if (updatedItem['aset_id'] != null &&
              updatedItem['paket_id'] == null) {
            final String asetId = updatedItem['aset_id'];

            try {
              // Get asset name from aset table
              final asetResponse =
                  await _authProvider.client
                      .from('aset')
                      .select('nama')
                      .eq('id', asetId)
                      .maybeSingle();

              // Get asset photo from foto_aset table using id_aset
              final fotoResponse =
                  await _authProvider.client
                      .from('foto_aset')
                      .select('foto_aset')
                      .eq('id_aset', asetId)
                      .limit(1)
                      .maybeSingle();

              // Create aset object for individual asset
              Map<String, dynamic> asetData = {};

              if (asetResponse != null) {
                asetData['nama'] = asetResponse['nama'] ?? 'Aset';
              }

              if (fotoResponse != null) {
                asetData['foto_utama'] = fotoResponse['foto_aset'];
              }

              // Update the item with the aset data
              sewaHistory[i] = {
                ...updatedItem,
                'aset': asetData,
                'tipe_pesanan': 'aset',
              };
            } catch (e) {
              print('Error fetching asset details: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching sewa history: $e');
    }
  }

  Future<void> updatePenyewaStatus(String status, String keterangan) async {
    try {
      isLoading.value = true;

      await _authProvider.client
          .from('warga_desa')
          .update({
            'status': status,
            'keterangan': keterangan,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId.value);

      // Refresh data
      await fetchPenyewaDetail();

      Get.snackbar(
        'Berhasil',
        'Status penyewa berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Error updating penyewa status: $e');
      Get.snackbar(
        'Error',
        'Gagal memperbarui status penyewa',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'Aktif';
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'suspended':
        return 'Dinonaktifkan';
      default:
        return 'Tidak diketahui';
    }
  }
}
