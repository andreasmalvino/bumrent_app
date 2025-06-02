import 'package:get/get.dart';

class PetugasBumdesCbpController extends GetxController {
  // Observable variables
  final isLoading = true.obs;

  // Bank account data
  final bankAccounts =
      <Map<String, dynamic>>[
        {
          'id': '1',
          'bank_name': 'Bank BRI',
          'account_number': '1234-5678-9101',
          'account_holder': 'BUMDes CBP Sukamaju',
          'is_primary': true,
        },
        {
          'id': '2',
          'bank_name': 'Bank BNI',
          'account_number': '9876-5432-1098',
          'account_holder': 'BUMDes CBP Sukamaju',
          'is_primary': false,
        },
      ].obs;

  // Partners data
  final partners =
      <Map<String, dynamic>>[
        {
          'id': '1',
          'name': 'UD Maju Jaya',
          'contact': '081234567890',
          'address': 'Jl. Raya Sukamaju No. 123',
          'is_active': true,
        },
        {
          'id': '2',
          'name': 'CV Tani Mandiri',
          'contact': '087654321098',
          'address': 'Jl. Kelapa Dua No. 45',
          'is_active': true,
        },
        {
          'id': '3',
          'name': 'PT Karya Sejahtera',
          'contact': '089876543210',
          'address': 'Jl. Industri Blok C No. 7',
          'is_active': false,
        },
      ].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      // Data is already loaded in the initialized lists
    } catch (e) {
      print('Error loading data: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Bank Account Methods
  void setPrimaryBankAccount(String id) {
    final index = bankAccounts.indexWhere((account) => account['id'] == id);
    if (index != -1) {
      // First, set all accounts to non-primary
      for (int i = 0; i < bankAccounts.length; i++) {
        final account = Map<String, dynamic>.from(bankAccounts[i]);
        account['is_primary'] = false;
        bankAccounts[i] = account;
      }

      // Then set the selected account as primary
      final account = Map<String, dynamic>.from(bankAccounts[index]);
      account['is_primary'] = true;
      bankAccounts[index] = account;

      Get.snackbar(
        'Rekening Utama',
        'Rekening ${account['bank_name']} telah dijadikan rekening utama',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void addBankAccount(Map<String, dynamic> account) {
    // Generate a new ID (in a real app, this would be from the backend)
    account['id'] = (bankAccounts.length + 1).toString();

    // By default, new accounts are not primary
    account['is_primary'] = false;

    bankAccounts.add(account);
    Get.back();
    Get.snackbar(
      'Rekening Ditambahkan',
      'Rekening bank baru telah berhasil ditambahkan',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void updateBankAccount(String id, Map<String, dynamic> updatedAccount) {
    final index = bankAccounts.indexWhere((account) => account['id'] == id);
    if (index != -1) {
      // Preserve the ID and primary status
      updatedAccount['id'] = id;
      updatedAccount['is_primary'] = bankAccounts[index]['is_primary'];

      bankAccounts[index] = updatedAccount;
      Get.back();
      Get.snackbar(
        'Rekening Diperbarui',
        'Informasi rekening bank telah berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void deleteBankAccount(String id) {
    final index = bankAccounts.indexWhere((account) => account['id'] == id);
    if (index != -1) {
      // Check if trying to delete the primary account
      if (bankAccounts[index]['is_primary'] == true) {
        Get.snackbar(
          'Tidak Dapat Menghapus',
          'Rekening utama tidak dapat dihapus. Silakan atur rekening lain sebagai utama terlebih dahulu.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      bankAccounts.removeAt(index);
      Get.back();
      Get.snackbar(
        'Rekening Dihapus',
        'Rekening bank telah berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Partner Methods
  void togglePartnerStatus(String id) {
    final index = partners.indexWhere((partner) => partner['id'] == id);
    if (index != -1) {
      final partner = Map<String, dynamic>.from(partners[index]);
      partner['is_active'] = !partner['is_active'];
      partners[index] = partner;

      Get.snackbar(
        'Status Diperbarui',
        'Status mitra telah diubah menjadi ${partner['is_active'] ? 'Aktif' : 'Tidak Aktif'}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void addPartner(Map<String, dynamic> partner) {
    // Generate a new ID (in a real app, this would be from the backend)
    partner['id'] = (partners.length + 1).toString();

    // By default, new partners are active
    partner['is_active'] = true;

    partners.add(partner);
    Get.back();
    Get.snackbar(
      'Mitra Ditambahkan',
      'Mitra baru telah berhasil ditambahkan',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void updatePartner(String id, Map<String, dynamic> updatedPartner) {
    final index = partners.indexWhere((partner) => partner['id'] == id);
    if (index != -1) {
      // Preserve the ID and active status
      updatedPartner['id'] = id;
      updatedPartner['is_active'] = partners[index]['is_active'];

      partners[index] = updatedPartner;
      Get.back();
      Get.snackbar(
        'Mitra Diperbarui',
        'Informasi mitra telah berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void deletePartner(String id) {
    final index = partners.indexWhere((partner) => partner['id'] == id);
    if (index != -1) {
      partners.removeAt(index);
      Get.back();
      Get.snackbar(
        'Mitra Dihapus',
        'Mitra telah berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
