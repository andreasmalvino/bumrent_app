import 'package:get/get.dart';

class ListPetugasMitraController extends GetxController {
  // Observable list of partners/mitra
  final partners =
      <Map<String, dynamic>>[
        {
          'id': '1',
          'name': 'Malih',
          'contact': '081234567890',
          'address': 'Jl. Desa No. 123, Kecamatan Bumdes, Kabupaten Desa',
          'is_active': true,
          'role': 'Petugas Lapangan',
          'join_date': '10 Januari 2023',
        },
      ].obs;

  // Loading state
  final isLoading = false.obs;

  // Search functionality
  final searchQuery = ''.obs;

  // Filtered list based on search
  List<Map<String, dynamic>> get filteredPartners {
    if (searchQuery.value.isEmpty) {
      return partners;
    }
    return partners
        .where(
          (partner) =>
              partner['name'].toString().toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              partner['contact'].toString().toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              partner['role'].toString().toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }

  // Add a new partner
  void addPartner(Map<String, dynamic> partner) {
    partners.add(partner);
    Get.back();
    Get.snackbar(
      'Sukses',
      'Petugas mitra berhasil ditambahkan',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Edit an existing partner
  void editPartner(String id, Map<String, dynamic> updatedPartner) {
    final index = partners.indexWhere((partner) => partner['id'] == id);
    if (index != -1) {
      partners[index] = updatedPartner;
      Get.back();
      Get.snackbar(
        'Sukses',
        'Data petugas mitra berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete a partner
  void deletePartner(String id) {
    partners.removeWhere((partner) => partner['id'] == id);
    Get.snackbar(
      'Sukses',
      'Petugas mitra berhasil dihapus',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Toggle partner active status
  void togglePartnerStatus(String id) {
    final index = partners.indexWhere((partner) => partner['id'] == id);
    if (index != -1) {
      final currentStatus = partners[index]['is_active'] as bool;
      partners[index]['is_active'] = !currentStatus;
      Get.snackbar(
        'Status Diperbarui',
        'Status petugas mitra diubah menjadi ${!currentStatus ? 'Aktif' : 'Nonaktif'}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
