import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../theme/app_colors.dart';

class RegistrationView extends GetView<AuthController> {
  const RegistrationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient - same as login page
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.primaryLight.withOpacity(0.1),
                  AppColors.background,
                  AppColors.accentLight.withOpacity(0.1),
                ],
              ),
            ),
          ),

          // Pattern overlay - same as login page
          Opacity(
            opacity: 0.03,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[50], // Temporary solid color
              ),
            ),
          ),

          // Accent circles - same as login page
          Positioned(
            top: -40,
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    _buildBackButton(),
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildRegistrationCard(),
                    _buildLoginLink(),
                    _buildCheckStatusLink(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: InkWell(
        onTap: () => Get.back(),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.arrow_back, size: 20, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Hero(
        tag: 'logo',
        child: Image.asset(
          'assets/images/logo.png',
          width: 150,
          height: 150,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.apartment_rounded,
              size: 120,
              color: AppColors.primary,
            );
          },
        ),
      ),
    );
  }

  Widget _buildRegistrationCard() {
    return Card(
      elevation: 4,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome text
              Text(
                'Daftar Akun',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lengkapi data berikut untuk mendaftar',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),

              // Account Credentials Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_circle_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    _buildInputLabel('Email'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'Masukkan email anda',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => controller.email.value = value,
                      validator: controller.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    _buildInputLabel('Password'),
                    const SizedBox(height: 8),
                    Obx(
                      () => _buildTextField(
                        hintText: 'Masukkan password anda',
                        prefixIcon: Icons.lock_outline,
                        obscureText: !controller.isPasswordVisible.value,
                        onChanged: (value) => controller.password.value = value,
                        validator: controller.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.iconGrey,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password field
                    _buildInputLabel('Konfirmasi Password'),
                    const SizedBox(height: 8),
                    Obx(
                      () => _buildTextField(
                        controller: controller.confirmPasswordController,
                        hintText: 'Masukkan ulang password anda',
                        prefixIcon: Icons.lock_outline,
                        obscureText: !controller.isConfirmPasswordVisible.value,
                        validator: controller.validateConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.iconGrey,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Personal Data Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentLight.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accentLight.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Data Diri',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    _buildInputLabel('Nama Lengkap'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: controller.nameController,
                      hintText: 'Masukkan nama lengkap anda',
                      prefixIcon: Icons.person_outline,
                      validator: controller.validateName,
                    ),
                    const SizedBox(height: 16),

                    // NIK field
                    _buildInputLabel('NIK'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'Masukkan NIK anda',
                      prefixIcon: Icons.credit_card_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => controller.nik.value = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'NIK tidak boleh kosong';
                        }
                        if (value.length != 16) {
                          return 'NIK harus 16 digit';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'NIK hanya boleh berisi angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tanggal Lahir field
                    _buildInputLabel('Tanggal Lahir'),
                    const SizedBox(height: 8),
                    Builder(builder: (context) => _buildDateField(context)),
                    const SizedBox(height: 16),

                    // Phone field
                    _buildInputLabel('No HP'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'Masukkan nomor HP anda',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      onChanged:
                          (value) => controller.phoneNumber.value = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'No HP tidak boleh kosong';
                        }
                        if (!value.startsWith('08')) {
                          return 'Nomor HP harus diawali dengan 08';
                        }
                        if (value.length < 10 || value.length > 13) {
                          return 'Nomor HP harus antara 10-13 digit';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Nomor HP hanya boleh berisi angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // RT/RW field
                    _buildInputLabel('RT/RW'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'Contoh: 001/002',
                      prefixIcon: Icons.home_work_outlined,
                      onChanged: (value) => controller.rtRw.value = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'RT/RW tidak boleh kosong';
                        }
                        if (!RegExp(r'^\d{1,3}\/\d{1,3}$').hasMatch(value)) {
                          return 'Format RT/RW tidak valid (contoh: 001/002)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Kelurahan/Desa field
                    _buildInputLabel('Kelurahan/Desa'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'Masukkan kelurahan/desa anda',
                      prefixIcon: Icons.location_city_outlined,
                      onChanged: (value) => controller.kelurahan.value = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kelurahan/Desa tidak boleh kosong';
                        }
                        if (value.length < 3) {
                          return 'Kelurahan/Desa minimal 3 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Kecamatan field
                    _buildInputLabel('Kecamatan'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'Masukkan kecamatan anda',
                      prefixIcon: Icons.location_on_outlined,
                      onChanged: (value) => controller.kecamatan.value = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kecamatan tidak boleh kosong';
                        }
                        if (value.length < 3) {
                          return 'Kecamatan minimal 3 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address field
                    _buildInputLabel('Alamat Lengkap'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'Masukkan alamat lengkap anda',
                      prefixIcon: Icons.home_outlined,
                      onChanged:
                          (value) => controller.alamatLengkap.value = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat lengkap tidak boleh kosong';
                        }
                        if (value.length < 5) {
                          return 'Alamat terlalu pendek, minimal 5 karakter';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Important info
              _buildImportantInfo(),
              const SizedBox(height: 24),

              // Register button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading.value
                            ? null
                            : controller.registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.buttonText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: controller.isLoading.value ? 0 : 2,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child:
                        controller.isLoading.value
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                  ),
                ),
              ),

              // Error message
              Obx(
                () =>
                    controller.errorMessage.value.isNotEmpty
                        ? Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontSize: 15,
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textLight),
        prefixIcon: Icon(prefixIcon, color: AppColors.iconGrey, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildImportantInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Setelah melakukan pendaftaran, silahkan simpan kode registrasi untuk cek status pendaftaran',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Sudah punya akun?",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              'Masuk',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add button to check registration status
  Widget _buildCheckStatusLink() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextButton(
          onPressed: () => _showCheckStatusDialog(Get.context!),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 18, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'Cek Status Pendaftaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show dialog to check registration status
  void _showCheckStatusDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    final TextEditingController identifierController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.search,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cek Status Pendaftaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Registration code field
                Text(
                  'Kode Registrasi',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan kode registrasi',
                    hintStyle: TextStyle(color: AppColors.textLight),
                    prefixIcon: Icon(
                      Icons.confirmation_number_outlined,
                      color: AppColors.iconGrey,
                      size: 22,
                    ),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.accent,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email/NIK/Phone field
                Text(
                  'Email/NIK/No HP',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: identifierController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan email, NIK, atau no HP',
                    hintStyle: TextStyle(color: AppColors.textLight),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppColors.iconGrey,
                      size: 22,
                    ),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.accent,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement check status functionality
                      Navigator.pop(context);

                      // Show a mock response for now
                      Get.snackbar(
                        'Status Pendaftaran',
                        'Status pendaftaran sedang diproses. Silakan tunggu konfirmasi lebih lanjut.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.infoLight,
                        colorText: AppColors.info,
                        icon: Icon(Icons.info_outline, color: AppColors.info),
                        duration: const Duration(seconds: 4),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Cek Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // New method to build date picker field
  Widget _buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(
            const Duration(days: 365 * 18),
          ), // Default to 18 years ago
          firstDate: DateTime(1940),
          lastDate: DateTime.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          controller.tanggalLahir.value = picked;
        }
      },
      child: Obx(() {
        final selectedDate = controller.tanggalLahir.value;
        final displayText =
            selectedDate != null
                ? '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}'
                : 'Pilih tanggal lahir';

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.iconGrey,
                  size: 22,
                ),
              ),
              Text(
                displayText,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textLight,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
