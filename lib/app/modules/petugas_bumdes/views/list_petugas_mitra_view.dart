import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/list_petugas_mitra_controller.dart';
import '../../../theme/app_colors_petugas.dart';

class ListPetugasMitraView extends GetView<ListPetugasMitraController> {
  const ListPetugasMitraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Petugas Mitra',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: AppColorsPetugas.navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),

            // List of Partners
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredPartners.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildPartnersList();
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPartnerDialog(context);
        },
        backgroundColor: AppColorsPetugas.blueGrotto,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        onChanged: (value) {
          controller.searchQuery.value = value;
        },
        decoration: InputDecoration(
          hintText: 'Cari petugas mitra...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: Obx(() {
            return controller.searchQuery.value.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.searchQuery.value = '';
                  },
                )
                : const SizedBox.shrink();
          }),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Belum ada petugas mitra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan petugas mitra dengan menekan tombol "+" di bawah',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnersList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredPartners.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final partner = controller.filteredPartners[index];
        return _buildPartnerCard(partner);
      },
    );
  }

  Widget _buildPartnerCard(Map<String, dynamic> partner) {
    final isActive = partner['is_active'] as bool;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      isActive ? Colors.green.shade100 : Colors.red.shade100,
                  child: Icon(
                    Icons.person,
                    color:
                        isActive ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        partner['role'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(
                      color:
                          isActive
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    _handleMenuAction(value, partner);
                  },
                  itemBuilder:
                      (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'toggle_status',
                          child: Row(
                            children: [
                              Icon(
                                isActive ? Icons.toggle_off : Icons.toggle_on,
                                color:
                                    isActive
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Text('Hapus'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, 'Kontak', partner['contact']),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'Alamat', partner['address']),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Tanggal Bergabung',
              partner['join_date'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> partner) {
    switch (action) {
      case 'toggle_status':
        controller.togglePartnerStatus(partner['id']);
        break;
      case 'edit':
        _showEditPartnerDialog(Get.context!, partner);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(Get.context!, partner);
        break;
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bantuan Petugas Mitra',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColorsPetugas.navyBlue,
                  ),
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  Icons.add_circle_outline,
                  'Tambah Mitra',
                  'Tekan tombol + untuk menambah petugas mitra baru',
                ),
                const SizedBox(height: 12),
                _buildHelpItem(
                  Icons.toggle_on,
                  'Aktif/Nonaktif',
                  'Ubah status aktif petugas mitra melalui menu opsi',
                ),
                const SizedBox(height: 12),
                _buildHelpItem(
                  Icons.edit,
                  'Edit Data',
                  'Ubah informasi petugas mitra melalui menu opsi',
                ),
                const SizedBox(height: 12),
                _buildHelpItem(
                  Icons.delete,
                  'Hapus',
                  'Hapus petugas mitra melalui menu opsi',
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsPetugas.blueGrotto,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Mengerti'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColorsPetugas.blueGrotto, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddPartnerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final addressController = TextEditingController();
    final roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Petugas Mitra',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColorsPetugas.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(nameController, 'Nama Lengkap', Icons.person),
                  const SizedBox(height: 12),
                  _buildTextField(
                    contactController,
                    'Nomor Kontak',
                    Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    addressController,
                    'Alamat',
                    Icons.location_on,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(roleController, 'Jabatan', Icons.work),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColorsPetugas.navyBlue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(color: AppColorsPetugas.navyBlue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameController.text.isEmpty ||
                                contactController.text.isEmpty ||
                                addressController.text.isEmpty ||
                                roleController.text.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Harap isi semua data',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            final newPartner = {
                              'id':
                                  DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                              'name': nameController.text,
                              'contact': contactController.text,
                              'address': addressController.text,
                              'role': roleController.text,
                              'is_active': true,
                              'join_date':
                                  '${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                            };

                            controller.addPartner(newPartner);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorsPetugas.blueGrotto,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditPartnerDialog(
    BuildContext context,
    Map<String, dynamic> partner,
  ) {
    final nameController = TextEditingController(text: partner['name']);
    final contactController = TextEditingController(text: partner['contact']);
    final addressController = TextEditingController(text: partner['address']);
    final roleController = TextEditingController(text: partner['role']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Petugas Mitra',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColorsPetugas.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(nameController, 'Nama Lengkap', Icons.person),
                  const SizedBox(height: 12),
                  _buildTextField(
                    contactController,
                    'Nomor Kontak',
                    Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    addressController,
                    'Alamat',
                    Icons.location_on,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(roleController, 'Jabatan', Icons.work),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColorsPetugas.navyBlue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(color: AppColorsPetugas.navyBlue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameController.text.isEmpty ||
                                contactController.text.isEmpty ||
                                addressController.text.isEmpty ||
                                roleController.text.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Harap isi semua data',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            final updatedPartner = {
                              'id': partner['id'],
                              'name': nameController.text,
                              'contact': contactController.text,
                              'address': addressController.text,
                              'role': roleController.text,
                              'is_active': partner['is_active'],
                              'join_date': partner['join_date'],
                            };

                            controller.editPartner(
                              partner['id'],
                              updatedPartner,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorsPetugas.blueGrotto,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    Map<String, dynamic> partner,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penghapusan'),
          content: Text(
            'Apakah Anda yakin ingin menghapus petugas mitra "${partner['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.deletePartner(partner['id']);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
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
    return months[month];
  }
}
