import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/warga_dashboard_controller.dart';
import '../views/warga_layout.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_drawer.dart';
import '../../../services/navigation_service.dart';

class WargaProfileView extends GetView<WargaDashboardController> {
  const WargaProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = Get.find<NavigationService>();
    navigationService.setNavIndex(2);

    // State for editing mode
    final isEditing = false.obs;
    // State for avatar deletion
    final isAvatarDeleted = false.obs;

    // Text editing controllers for editable fields
    final nameController = TextEditingController(
      text: controller.userName.value,
    );
    final phoneController = TextEditingController(
      text: controller.userPhone.value,
    );

    // Store original values for cancel functionality
    final originalName = controller.userName.value;
    final originalPhone = controller.userPhone.value;

    return WargaLayout(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        actions: [
          Obx(
            () =>
                isEditing.value
                    ? Row(
                      children: [
                        // Cancel button
                        IconButton(
                          onPressed: () {
                            // Reset values to original
                            nameController.text = originalName;
                            phoneController.text = originalPhone;
                            isEditing.value = false;
                            isAvatarDeleted.value =
                                false; // Reset avatar deletion state
                            controller
                                .cancelAvatarChange(); // Reset temporary avatar
                          },
                          icon: const Icon(Icons.close),
                          tooltip: 'Batal',
                        ),
                        // Save button
                        IconButton(
                          onPressed: () async {
                            // Show loading indicator
                            final loadingDialog = Get.dialog(
                              const Center(child: CircularProgressIndicator()),
                              barrierDismissible: false,
                            );

                            bool success = true;

                            // Check if there's a new avatar to save
                            if (controller.tempAvatarBytes.value != null) {
                              // Save the new avatar
                              success = await controller.saveNewAvatar();
                              if (!success) {
                                // Close loading dialog if avatar saving fails
                                Get.back();

                                Get.snackbar(
                                  'Gagal',
                                  'Terjadi kesalahan saat menyimpan foto profil',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );

                                isEditing.value = false;
                                return;
                              }
                            }
                            // If avatar was deleted (and no new avatar selected), update it in the database
                            else if (isAvatarDeleted.value) {
                              success = await controller.deleteUserAvatar();
                              if (!success) {
                                // Close loading dialog if avatar deletion fails
                                Get.back();

                                Get.snackbar(
                                  'Gagal',
                                  'Terjadi kesalahan saat menghapus foto profil',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );

                                isAvatarDeleted.value =
                                    false; // Reset avatar deletion state
                                isEditing.value = false;
                                return;
                              }
                            }

                            // Save profile changes to database
                            success = await controller.updateUserProfile(
                              namaLengkap: nameController.text,
                              noHp: phoneController.text,
                            );

                            // Close loading dialog
                            Get.back();

                            if (success) {
                              Get.snackbar(
                                'Sukses',
                                'Perubahan berhasil disimpan',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            } else {
                              Get.snackbar(
                                'Gagal',
                                'Terjadi kesalahan saat menyimpan perubahan',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );

                              // Reset to original values on failure
                              nameController.text = originalName;
                              phoneController.text = originalPhone;
                              isAvatarDeleted.value =
                                  false; // Reset avatar deletion state
                              controller
                                  .cancelAvatarChange(); // Reset temporary avatar
                            }

                            isEditing.value = false;
                          },
                          icon: const Icon(Icons.check),
                          tooltip: 'Simpan',
                        ),
                      ],
                    )
                    : IconButton(
                      onPressed: () {
                        isEditing.value = true;
                      },
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit Profil',
                    ),
          ),
        ],
      ),
      drawer: AppDrawer(
        onNavItemTapped: (index) {
          // Handle navigation if needed
        },
        onLogout: () {
          controller.logout();
        },
      ),
      backgroundColor: Colors.grey.shade100,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
          controller.refreshData();
          // Update text controllers with refreshed data
          nameController.text = controller.userName.value;
          phoneController.text = controller.userPhone.value;
          isAvatarDeleted.value = false; // Reset avatar deletion state
          return;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Obx(
                () => _buildProfileHeader(
                  context,
                  isEditing.value,
                  isAvatarDeleted,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => _buildPersonalInfoCard(
                  context,
                  isEditing.value,
                  nameController,
                  phoneController,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingsCard(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    bool isEditing,
    RxBool isAvatarDeleted,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withBlue(AppColors.primary.blue + 30),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(
          children: [
            // Profile picture with shadow effect
            Obx(() {
              final avatarUrl = controller.userAvatar.value;
              final shouldShowFallback =
                  isAvatarDeleted.value ||
                  avatarUrl == null ||
                  avatarUrl.isEmpty;

              // Check if there's a temporary avatar preview
              final hasTemporaryAvatar =
                  controller.tempAvatarBytes.value != null;

              return Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(55),
                          child:
                              hasTemporaryAvatar
                                  // Show temporary avatar preview
                                  ? Image.memory(
                                    controller.tempAvatarBytes.value!,
                                    fit: BoxFit.cover,
                                  )
                                  : shouldShowFallback
                                  ? _buildAvatarFallback()
                                  : Image.network(
                                    avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildAvatarFallback(),
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return _buildAvatarFallback();
                                    },
                                  ),
                        ),
                      ),
                      if (isEditing)
                        GestureDetector(
                          onTap: () {
                            // Show image source dialog when camera icon is tapped
                            controller.showImageSourceDialog();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Image selection buttons when in edit mode
                  if (isEditing)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Show "Batal" button if temporary avatar is selected
                          if (hasTemporaryAvatar)
                            ElevatedButton.icon(
                              onPressed: () {
                                controller.cancelAvatarChange();
                              },
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text('Batal'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.grey.shade800,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                textStyle: const TextStyle(fontSize: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (hasTemporaryAvatar) {
                                // If temporary avatar exists, don't show the snackbar
                                // The actual saving will happen when the user presses the save button
                                isAvatarDeleted.value = false;
                              } else {
                                // Set avatar deleted flag
                                isAvatarDeleted.value = true;

                                Get.snackbar(
                                  'Info',
                                  'Foto profil akan dihapus setelah menekan Simpan',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.orange.shade700,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Hapus'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red.shade700,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(fontSize: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            }),
            const SizedBox(height: 16),
            // User name with subtle text shadow
            Obx(
              () => Text(
                controller.userName.value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            // User role in a stylish chip
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.userRole.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(
    BuildContext context,
    bool isEditing,
    TextEditingController nameController,
    TextEditingController phoneController,
  ) {
    return Column(
      children: [
        // Section 1: Data Diri
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Data Diri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (isEditing) ...[
                      const Spacer(),
                      Text(
                        'Mode Edit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.edit_note,
                        color: Colors.orange.shade700,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                // Email - always read-only
                _buildInfoItemModern(
                  context,
                  icon: Icons.email_rounded,
                  title: 'Email',
                  value: controller.userEmail.value,
                ),
                const SizedBox(height: 16),
                // Nama Lengkap - editable
                _buildEditableInfoItem(
                  context,
                  icon: Icons.person_rounded,
                  title: 'Nama Lengkap',
                  value: controller.userName.value,
                  isEditing: isEditing,
                  controller: nameController,
                ),
                const SizedBox(height: 16),
                // Nomor Telepon - editable
                _buildEditableInfoItem(
                  context,
                  icon: Icons.phone_rounded,
                  title: 'Nomor Telepon',
                  value: controller.userPhone.value,
                  isEditing: isEditing,
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Section 2: Informasi Warga
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.badge_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Informasi Warga',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoItemModern(
                  context,
                  icon: Icons.credit_card_rounded,
                  title: 'NIK',
                  value: controller.userNik.value,
                ),
                const SizedBox(height: 16),
                _buildInfoItemModern(
                  context,
                  icon: Icons.calendar_today_rounded,
                  title: 'Tanggal Lahir',
                  value: controller.userTanggalLahir.value,
                ),
                const SizedBox(height: 16),
                _buildInfoItemModern(
                  context,
                  icon: Icons.home_rounded,
                  title: 'Alamat',
                  value: controller.userAddress.value,
                  isMultiLine: true,
                ),
                const SizedBox(height: 16),
                _buildInfoItemModern(
                  context,
                  icon: Icons.location_on_rounded,
                  title: 'RT/RW',
                  value: controller.userRtRw.value,
                ),
                const SizedBox(height: 16),
                _buildInfoItemModern(
                  context,
                  icon: Icons.location_city_rounded,
                  title: 'Kelurahan/Desa',
                  value: controller.userKelurahanDesa.value,
                ),
                const SizedBox(height: 16),
                _buildInfoItemModern(
                  context,
                  icon: Icons.map_rounded,
                  title: 'Kecamatan',
                  value: controller.userKecamatan.value,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItemModern(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isMultiLine = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Tidak tersedia' : value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: isMultiLine ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required bool isEditing,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isEditing ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isEditing
                  ? AppColors.primary.withOpacity(0.5)
                  : Colors.grey.shade200,
        ),
        boxShadow:
            isEditing
                ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      padding: EdgeInsets.all(isEditing ? 12 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                if (isEditing)
                  TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: InputBorder.none,
                      hintText: 'Masukkan $title',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 15,
                      ),
                    ),
                  )
                else
                  Text(
                    value.isEmpty ? 'Tidak tersedia' : value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
              ],
            ),
          ),
          if (isEditing) Icon(Icons.edit, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.settings_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Pengaturan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildActionItem(
            icon: Icons.lock_outline_rounded,
            title: 'Ubah Password',
            iconColor: AppColors.primary,
            onTap: () {
              Get.snackbar(
                'Info',
                'Fitur Ubah Password akan segera tersedia',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildActionItem(
            icon: Icons.logout_rounded,
            title: 'Keluar',
            iconColor: Colors.red.shade400,
            isDestructive: true,
            onTap: () {
              _showLogoutConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    final color =
        isDestructive ? Colors.red.shade400 : iconColor ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color:
                    isDestructive ? Colors.red.shade400 : Colors.grey.shade800,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.person,
          color: AppColors.primary.withOpacity(0.7),
          size: 50,
        ),
      ),
    );
  }
}
