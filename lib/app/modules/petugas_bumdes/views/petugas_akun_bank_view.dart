import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/petugas_akun_bank_controller.dart';
import '../controllers/petugas_bumdes_dashboard_controller.dart';
import '../widgets/petugas_side_navbar.dart';
import '../../../theme/app_colors_petugas.dart';

class PetugasAkunBankView extends GetView<PetugasAkunBankController> {
  const PetugasAkunBankView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get dashboard controller for side navbar
    final dashboardController = Get.find<PetugasBumdesDashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Akun Bank'),
        backgroundColor: AppColorsPetugas.navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadBankAccounts,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (controller.bankAccounts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada akun bank',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditBankAccountDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Akun Bank'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorsPetugas.blueGrotto,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: controller.loadBankAccounts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.bankAccounts.length,
                itemBuilder: (context, index) {
                  final account = controller.bankAccounts[index];
                  return _buildBankAccountCard(context, account);
                },
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () => _showAddEditBankAccountDialog(context),
                backgroundColor: AppColorsPetugas.blueGrotto,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBankAccountCard(
    BuildContext context,
    Map<String, dynamic> account,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColorsPetugas.blueGrotto.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: AppColorsPetugas.blueGrotto,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account['nama_bank'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account['nama_akun'] ?? '',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showAddEditBankAccountDialog(context, account);
                    } else if (value == 'delete') {
                      _showDeleteConfirmationDialog(context, account);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.credit_card, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'No. Rekening: ${account['no_rekening'] ?? ''}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditBankAccountDialog(
    BuildContext context, [
    Map<String, dynamic>? account,
  ]) {
    final isEditing = account != null;
    final formKey = GlobalKey<FormState>();

    String bankName = account?['nama_bank'] ?? '';
    String accountName = account?['nama_akun'] ?? '';
    String accountNumber = account?['no_rekening'] ?? '';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Akun Bank' : 'Tambah Akun Bank',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: bankName,
                      decoration: const InputDecoration(
                        labelText: 'Nama Bank',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama bank tidak boleh kosong';
                        }
                        return null;
                      },
                      onChanged: (value) => bankName = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: accountName,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pemilik Rekening',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama pemilik rekening tidak boleh kosong';
                        }
                        return null;
                      },
                      onChanged: (value) => accountName = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: accountNumber,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Rekening',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor rekening tidak boleh kosong';
                        }
                        return null;
                      },
                      onChanged: (value) => accountNumber = value,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final accountData = {
                          'nama_bank': bankName,
                          'nama_akun': accountName,
                          'no_rekening': accountNumber,
                        };

                        if (isEditing) {
                          controller.updateBankAccount(
                            account['id'],
                            accountData,
                          );
                        } else {
                          controller.addBankAccount(accountData);
                        }

                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsPetugas.blueGrotto,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEditing ? 'Simpan' : 'Tambah'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    Map<String, dynamic> account,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus akun bank ${account['nama_bank']} - ${account['nama_akun']}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              controller.deleteBankAccount(account['id']);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
