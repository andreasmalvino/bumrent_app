import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PetugasManajemenBumdesController extends GetxController {
  // Reactive variables
  final RxInt selectedTabIndex = 0.obs;
  final RxBool isLoading = false.obs;

  // Tab options
  final List<String> tabOptions = ['Akun Bank', 'Mitra'];

  // Sample data for Bank Accounts
  final RxList<Map<String, dynamic>> bankAccounts =
      <Map<String, dynamic>>[
        {
          'bankName': 'Bank BRI',
          'accountName': 'BUMDes Sejahtera',
          'accountNumber': '123456789',
          'isPrimary': true,
        },
        {
          'bankName': 'Bank BNI',
          'accountName': 'BUMDes Sejahtera',
          'accountNumber': '987654321',
          'isPrimary': false,
        },
      ].obs;

  // Sample data for Partners
  final RxList<Map<String, dynamic>> partners =
      <Map<String, dynamic>>[
        {
          'name': 'CV Maju Jaya',
          'email': 'majujaya@example.com',
          'phone': '081234567890',
          'address': 'Jl. Maju No. 123, Kecamatan Berkah',
          'isActive': true,
        },
        {
          'name': 'PT Sentosa',
          'email': 'sentosa@example.com',
          'phone': '089876543210',
          'address': 'Jl. Sentosa No. 456, Kecamatan Damai',
          'isActive': false,
        },
      ].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    isLoading.value = true;
    // Simulate loading data from API
    Future.delayed(const Duration(milliseconds: 500), () {
      // Data already loaded with sample data
      isLoading.value = false;
    });
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  void setPrimaryBankAccount(int index) {
    // Set all accounts to non-primary first
    for (var i = 0; i < bankAccounts.length; i++) {
      bankAccounts[i]['isPrimary'] = false;
    }

    // Set the selected account as primary
    bankAccounts[index]['isPrimary'] = true;

    // Force UI refresh
    bankAccounts.refresh();

    Get.snackbar(
      'Sukses',
      'Rekening utama berhasil diubah',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void togglePartnerStatus(int index) {
    // Toggle the active status
    partners[index]['isActive'] = !partners[index]['isActive'];

    // Force UI refresh
    partners.refresh();

    Get.snackbar(
      'Sukses',
      'Status mitra berhasil diubah',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void addBankAccount(Map<String, dynamic> account) {
    // Set as primary if it's the first account
    if (bankAccounts.isEmpty) {
      account['isPrimary'] = true;
    } else {
      account['isPrimary'] = false;
    }

    bankAccounts.add(account);

    Get.snackbar(
      'Sukses',
      'Rekening bank berhasil ditambahkan',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void updateBankAccount(int index, Map<String, dynamic> updatedAccount) {
    // Preserve the primary status
    updatedAccount['isPrimary'] = bankAccounts[index]['isPrimary'];

    bankAccounts[index] = updatedAccount;
    bankAccounts.refresh();

    Get.snackbar(
      'Sukses',
      'Rekening bank berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void deleteBankAccount(int index) {
    // Check if the account to be deleted is primary
    final isPrimary = bankAccounts[index]['isPrimary'];

    // Remove the account
    bankAccounts.removeAt(index);

    // If the deleted account was primary and there are other accounts, set the first one as primary
    if (isPrimary && bankAccounts.isNotEmpty) {
      bankAccounts[0]['isPrimary'] = true;
    }

    bankAccounts.refresh();

    Get.snackbar(
      'Sukses',
      'Rekening bank berhasil dihapus',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void addPartner(Map<String, dynamic> partner) {
    partners.add(partner);

    Get.snackbar(
      'Sukses',
      'Mitra berhasil ditambahkan',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void updatePartner(int index, Map<String, dynamic> updatedPartner) {
    partners[index] = updatedPartner;
    partners.refresh();

    Get.snackbar(
      'Sukses',
      'Mitra berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void deletePartner(int index) {
    partners.removeAt(index);
    partners.refresh();

    Get.snackbar(
      'Sukses',
      'Mitra berhasil dihapus',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
