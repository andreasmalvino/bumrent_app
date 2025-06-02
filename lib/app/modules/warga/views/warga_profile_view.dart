import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/warga_dashboard_controller.dart';
import '../views/warga_layout.dart';
import '../../../theme/app_colors.dart';

class WargaProfileView extends GetView<WargaDashboardController> {
  const WargaProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return WargaLayout(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Get.snackbar(
                'Info',
                'Fitur edit profil akan segera tersedia',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profil',
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
          controller.refreshData();
          return;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(context),
              const SizedBox(height: 16),
              _buildInfoCard(context),
              const SizedBox(height: 16),
              _buildSettingsCard(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
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
              return Container(
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
                      avatarUrl != null && avatarUrl.isNotEmpty
                          ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    _buildAvatarFallback(),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return _buildAvatarFallback();
                            },
                          )
                          : _buildAvatarFallback(),
                ),
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

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'INFORMASI PERSONAL',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildInfoItem(
            icon: Icons.email_outlined,
            title: 'Email',
            value:
                controller.userEmail.value.isEmpty
                    ? 'emailpengguna@example.com'
                    : controller.userEmail.value,
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildInfoItem(
            icon: Icons.credit_card_outlined,
            title: 'NIK',
            value:
                controller.userNik.value.isEmpty
                    ? '123456789012345'
                    : controller.userNik.value,
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildInfoItem(
            icon: Icons.phone_outlined,
            title: 'Nomor Telepon',
            value:
                controller.userPhone.value.isEmpty
                    ? '081234567890'
                    : controller.userPhone.value,
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildInfoItem(
            icon: Icons.home_outlined,
            title: 'Alamat Lengkap',
            value:
                controller.userAddress.value.isEmpty
                    ? 'Jl. Contoh No. 123, Desa Sejahtera, Kec. Makmur, Kab. Berkah, Prov. Damai'
                    : controller.userAddress.value,
            isMultiLine: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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

  Widget _buildSettingsCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'PENGATURAN',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildActionItem(
            icon: Icons.lock_outline,
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
            icon: Icons.logout,
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
            const SizedBox(width: 12),
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
