import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Form fields for registration
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString nik = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString selectedRole = 'WARGA'.obs; // Default role

  // Form status
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;

  // Role options
  final List<String> roleOptions = ['WARGA', 'PETUGAS_MITRA'];

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Change role selection
  void setRole(String? role) {
    if (role != null) {
      selectedRole.value = role;
    }
  }

  void login() async {
    // Clear previous error messages
    errorMessage.value = '';

    // Basic validation
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'Email dan password tidak boleh kosong';
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      errorMessage.value = 'Format email tidak valid';
      return;
    }

    try {
      isLoading.value = true;

      // Use the actual Supabase authentication
      final response = await _authProvider.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Check if login was successful
      if (response.user != null) {
        await _checkRoleAndNavigate();
      } else {
        errorMessage.value = 'Login gagal. Periksa email dan password Anda.';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkRoleAndNavigate() async {
    try {
      // Get the user's role ID from the auth provider
      final roleId = await _authProvider.getUserRoleId();

      if (roleId == null) {
        errorMessage.value = 'Tidak dapat memperoleh peran pengguna';
        return;
      }

      // Get role name based on role ID
      final roleName = await _authProvider.getRoleName(roleId);

      // Navigate based on role name
      if (roleName == null) {
        _navigateToWargaDashboard(); // Default to warga if role name not found
        return;
      }

      switch (roleName.toUpperCase()) {
        case 'PETUGAS_BUMDES':
          _navigateToPetugasBumdesDashboard();
          break;
        case 'WARGA':
        default:
          _navigateToWargaDashboard();
          break;
      }
    } catch (e) {
      errorMessage.value = 'Gagal navigasi: ${e.toString()}';
    }
  }

  void _navigateToPetugasBumdesDashboard() {
    Get.offAllNamed(Routes.PETUGAS_BUMDES_DASHBOARD);
  }

  void _navigateToWargaDashboard() {
    Get.offAllNamed(Routes.WARGA_DASHBOARD);
  }

  void forgotPassword() async {
    // Clear previous error messages
    errorMessage.value = '';

    // Basic validation
    if (emailController.text.isEmpty) {
      errorMessage.value = 'Email tidak boleh kosong';
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      errorMessage.value = 'Format email tidak valid';
      return;
    }

    try {
      isLoading.value = true;

      // Call Supabase to send password reset email
      await _authProvider.client.auth.resetPasswordForEmail(
        emailController.text.trim(),
      );

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Link reset password telah dikirim ke email Anda',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );

      // Return to login page after a short delay
      await Future.delayed(const Duration(seconds: 2));
      Get.back();
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void goToSignUp() {
    // Clear error message when navigating away
    errorMessage.value = '';
    Get.toNamed(Routes.REGISTER);
  }

  void goToForgotPassword() {
    // Clear error message when navigating away
    errorMessage.value = '';
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Register user implementation
  Future<void> registerUser() async {
    // Validate all required fields
    if (email.value.isEmpty ||
        password.value.isEmpty ||
        nik.value.isEmpty ||
        phoneNumber.value.isEmpty) {
      errorMessage.value = 'Semua field harus diisi';
      return;
    }

    // Basic validation for email
    if (!GetUtils.isEmail(email.value.trim())) {
      errorMessage.value = 'Format email tidak valid';
      return;
    }

    // Basic validation for password
    if (password.value.length < 6) {
      errorMessage.value = 'Password minimal 6 karakter';
      return;
    }

    // Basic validation for NIK
    if (nik.value.length != 16) {
      errorMessage.value = 'NIK harus 16 digit';
      return;
    }

    // Basic validation for phone number
    if (!phoneNumber.value.startsWith('08') || phoneNumber.value.length < 10) {
      errorMessage.value =
          'Nomor HP tidak valid (harus diawali 08 dan minimal 10 digit)';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Create user with Supabase
      final response = await _authProvider.signUp(
        email: email.value.trim(),
        password: password.value,
        data: {
          'nik': nik.value.trim(),
          'phone_number': phoneNumber.value.trim(),
          'role': selectedRole.value,
        },
      );

      if (response.user != null) {
        // Registration successful
        Get.offNamed(Routes.REGISTRATION_SUCCESS);
      } else {
        errorMessage.value = 'Gagal mendaftar. Silakan coba lagi.';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
      print('Registration error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
