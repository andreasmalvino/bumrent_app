import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/aset_provider.dart';

class PetugasAkunBankController extends GetxController {
  final AsetProvider asetProvider = Get.find<AsetProvider>();

  // Observable variables
  final isLoading = true.obs;
  final bankAccounts = <Map<String, dynamic>>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadBankAccounts();
  }

  // Load bank accounts from the database
  Future<void> loadBankAccounts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('🏦 Loading bank accounts...');

      // Fetch all bank accounts from the database
      final response = await asetProvider.client
          .from('akun_bank')
          .select('id, nama_bank, nama_akun, no_rekening')
          .order('nama_bank', ascending: true);

      if (response is List) {
        bankAccounts.value = List<Map<String, dynamic>>.from(response);
        debugPrint('✅ Loaded ${bankAccounts.length} bank accounts');
      } else {
        bankAccounts.value = [];
        errorMessage.value = 'Failed to load bank accounts';
        debugPrint('❌ Failed to load bank accounts: Invalid response format');
      }
    } catch (e) {
      errorMessage.value = 'Error loading bank accounts: $e';
      debugPrint('❌ Error loading bank accounts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new bank account
  Future<bool> addBankAccount(Map<String, dynamic> accountData) async {
    try {
      debugPrint('🏦 Adding new bank account: ${accountData['nama_bank']}');

      final response = await asetProvider.client
          .from('akun_bank')
          .insert(accountData)
          .select('id');

      if (response is List && response.isNotEmpty) {
        debugPrint('✅ Bank account added successfully');
        await loadBankAccounts(); // Reload the list
        return true;
      } else {
        debugPrint('❌ Failed to add bank account: No response');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error adding bank account: $e');
      return false;
    }
  }

  // Update an existing bank account
  Future<bool> updateBankAccount(
    String id,
    Map<String, dynamic> accountData,
  ) async {
    try {
      debugPrint('🏦 Updating bank account ID: $id');

      final response = await asetProvider.client
          .from('akun_bank')
          .update(accountData)
          .eq('id', id);

      debugPrint('✅ Bank account updated successfully');
      await loadBankAccounts(); // Reload the list
      return true;
    } catch (e) {
      debugPrint('❌ Error updating bank account: $e');
      return false;
    }
  }

  // Delete a bank account
  Future<bool> deleteBankAccount(String id) async {
    try {
      debugPrint('🏦 Deleting bank account ID: $id');

      final response = await asetProvider.client
          .from('akun_bank')
          .delete()
          .eq('id', id);

      debugPrint('✅ Bank account deleted successfully');
      await loadBankAccounts(); // Reload the list
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting bank account: $e');
      return false;
    }
  }
}
