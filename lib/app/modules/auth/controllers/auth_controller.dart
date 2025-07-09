import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import 'dart:math';
import '../../../modules/warga/controllers/warga_dashboard_controller.dart';

class AuthController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool isConfirmPasswordVisible = false.obs;

  // Form fields for registration
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString nik = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString selectedRole = 'WARGA'.obs; // Default role
  final RxString alamatLengkap = ''.obs;
  final Rx<DateTime?> tanggalLahir = Rx<DateTime?>(null);
  final RxString rtRw = ''.obs;
  final RxString kelurahan = ''.obs;
  final RxString kecamatan = ''.obs;

  // Form status
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;

  // Role options
  final List<String> roleOptions = ['WARGA', 'PETUGAS_MITRA'];

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
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
        await _checkWargaStatusAndNavigate(); // Default to warga if role name not found
        return;
      }

      switch (roleName.toUpperCase()) {
        case 'PETUGAS_BUMDES':
          _navigateToPetugasBumdesDashboard();
          break;
        case 'WARGA':
          // For WARGA role, check account status in warga_desa table
          await _checkWargaStatusAndNavigate();
          break;
        default:
          _navigateToWargaDashboard();
          break;
      }
    } catch (e) {
      errorMessage.value = 'Gagal navigasi: ${e.toString()}';
    }
  }

  // Check warga status in warga_desa table and navigate accordingly
  Future<void> _checkWargaStatusAndNavigate() async {
    try {
      final user = _authProvider.currentUser;
      if (user == null) {
        errorMessage.value = 'Tidak dapat memperoleh data pengguna';
        return;
      }

      // Get user data from warga_desa table
      final userData =
          await _authProvider.client
              .from('warga_desa')
              .select('status, keterangan')
              .eq('user_id', user.id)
              .maybeSingle();

      if (userData == null) {
        errorMessage.value = 'Data pengguna tidak ditemukan';
        return;
      }

      final status = userData['status'] as String?;

      switch (status?.toLowerCase()) {
        case 'active':
          // Allow login for active users
          _navigateToWargaDashboard();
          break;
        case 'suspended':
          // Show error for suspended users
          final keterangan =
              userData['keterangan'] as String? ?? 'Tidak ada keterangan';
          errorMessage.value =
              'Akun Anda dinonaktifkan oleh petugas. Keterangan: $keterangan';
          // Sign out the user
          await _authProvider.signOut();
          break;
        case 'pending':
          // Show error for pending users
          errorMessage.value =
              'Akun Anda sedang dalam proses verifikasi. Silakan tunggu hingga verifikasi selesai.';
          // Sign out the user
          await _authProvider.signOut();
          break;
        default:
          errorMessage.value = 'Status akun tidak valid';
          // Sign out the user
          await _authProvider.signOut();
          break;
      }
    } catch (e) {
      errorMessage.value = 'Gagal memeriksa status akun: ${e.toString()}';
      // Sign out the user on error
      await _authProvider.signOut();
    }
  }

  void _navigateToPetugasBumdesDashboard() {
    Get.offAllNamed(Routes.PETUGAS_BUMDES_DASHBOARD);
  }

  void _navigateToWargaDashboard() {
    // Navigate to warga dashboard with parameter to indicate it's coming from login
    // This will trigger an immediate refresh of the data
    Get.offAllNamed(Routes.WARGA_DASHBOARD, arguments: {'from_login': true});
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
        snackPosition: SnackPosition.TOP,
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
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Register user implementation
  Future<void> registerUser() async {
    // Clear previous error messages
    errorMessage.value = '';

    // Validate form fields
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate date of birth separately (since it's not a standard form field)
    if (!validateDateOfBirth()) {
      return;
    }

    try {
      isLoading.value = true;

      // Format tanggal lahir to string (YYYY-MM-DD)
      final formattedTanggalLahir =
          tanggalLahir.value != null
              ? '${tanggalLahir.value!.year}-${tanggalLahir.value!.month.toString().padLeft(2, '0')}-${tanggalLahir.value!.day.toString().padLeft(2, '0')}'
              : '';

      // Generate register_id with format REG-YYYY-1234567
      final currentYear = DateTime.now().year.toString();
      final randomDigits = _generateRandomDigits(7); // Generate 7 random digits
      final registerId = 'REG-$currentYear-$randomDigits';

      // 1. Register user with Supabase Auth and add role_id to metadata
      final response = await _authProvider.client.auth.signUp(
        email: email.value.trim(),
        password: password.value,
        data: {
          'role_id':
              'bb5360d5-8fd0-404e-8f6f-71ec4d8ad0ae', // Fixed role_id for WARGA
        },
      );

      // Check if registration was successful
      if (response.user != null) {
        // 2. Get the UID from the created auth user
        final userId = response.user!.id;

        // 3. Insert user data into the warga_desa table
        await _authProvider.client.from('warga_desa').insert({
          'user_id': userId,
          'email': email.value.trim(),
          'nama_lengkap': nameController.text.trim(),
          'nik': nik.value.trim(),
          'status': 'pending',
          'tanggal_lahir': formattedTanggalLahir,
          'no_hp': phoneNumber.value.trim(),
          'rt_rw': rtRw.value.trim(),
          'kelurahan_desa': kelurahan.value.trim(),
          'kecamatan': kecamatan.value.trim(),
          'alamat': alamatLengkap.value.trim(),
          'register_id': registerId, // Add register_id to the warga_desa table
        });

        // Reset registration fields BEFORE navigation to ensure clean state
        resetRegistrationFields();

        // Bersihkan data auth provider untuk memastikan tidak ada data user yang tersimpan
        _authProvider.clearAuthData();

        // Print debug message
        print(
          'Registration successful: Fields and controllers have been cleared',
        );

        // Registration successful - navigate to success page
        Get.offNamed(
          Routes.REGISTRATION_SUCCESS,
          arguments: {'register_id': registerId},
        );
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

  // Generate random digits of specified length
  String _generateRandomDigits(int length) {
    final random = Random();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(random.nextInt(10));
    }
    return buffer.toString();
  }

  // Validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus memiliki minimal 1 huruf besar';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password harus memiliki minimal 1 angka';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != password.value) {
      return 'Password tidak cocok';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama lengkap minimal 3 karakter';
    }
    if (!RegExp(r"^[a-zA-Z\s\.]+$").hasMatch(value)) {
      return 'Nama hanya boleh berisi huruf, spasi, titik, dan apostrof';
    }
    return null;
  }

  String? validateNIK(String? value) {
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
  }

  String? validatePhone(String? value) {
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
  }

  String? validateRTRW(String? value) {
    if (value == null || value.isEmpty) {
      return 'RT/RW tidak boleh kosong';
    }
    if (!RegExp(r'^\d{1,3}\/\d{1,3}$').hasMatch(value)) {
      return 'Format RT/RW tidak valid (contoh: 001/002)';
    }
    return null;
  }

  String? validateKelurahan(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kelurahan/Desa tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Kelurahan/Desa minimal 3 karakter';
    }
    return null;
  }

  String? validateKecamatan(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kecamatan tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Kecamatan minimal 3 karakter';
    }
    return null;
  }

  String? validateAlamat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat lengkap tidak boleh kosong';
    }
    if (value.length < 5) {
      return 'Alamat terlalu pendek, minimal 5 karakter';
    }
    return null;
  }

  bool validateDateOfBirth() {
    if (tanggalLahir.value == null) {
      errorMessage.value = 'Tanggal lahir harus diisi';
      return false;
    }

    // Check if user is at least 17 years old
    final DateTime today = DateTime.now();
    final DateTime minimumAge = DateTime(
      today.year - 17,
      today.month,
      today.day,
    );

    if (tanggalLahir.value!.isAfter(minimumAge)) {
      errorMessage.value = 'Anda harus berusia minimal 17 tahun';
      return false;
    }

    return true;
  }

  // Check registration status by register_id and email
  Future<Map<String, dynamic>?> checkRegistrationStatus(
    String registerId,
    String email,
  ) async {
    try {
      isLoading.value = true;

      print('Checking registration status - ID: $registerId, Email: $email');

      // Validasi input
      if (registerId.isEmpty || email.isEmpty) {
        print('Invalid input: registerId or email is empty');
        return null;
      }

      // Query warga_desa table where register_id and email match
      final response =
          await _authProvider.client
              .from('warga_desa')
              .select(
                '*',
              ) // Ensure we select all columns including 'keterangan'
              .eq('register_id', registerId)
              .eq('email', email)
              .maybeSingle();

      // Log response for debugging
      print('Registration status query response: $response');

      // Validasi hasil query
      if (response == null) {
        print('No matching registration found');
        return null;
      }

      if (response is Map<String, dynamic> && response.isEmpty) {
        print('Empty response received');
        return null;
      }

      // Jika berhasil, kembalikan data
      print('Registration found with status: ${response['status']}');
      return response;
    } catch (e) {
      print('Error checking registration status: ${e.toString()}');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Reset all registration fields
  void resetRegistrationFields() {
    // Reset text controllers
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();

    // Reset form fields
    email.value = '';
    password.value = '';
    nik.value = '';
    phoneNumber.value = '';
    selectedRole.value = 'WARGA'; // Reset to default role
    alamatLengkap.value = '';
    tanggalLahir.value = null;
    rtRw.value = '';
    kelurahan.value = '';
    kecamatan.value = '';

    // Reset form status
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
    errorMessage.value = '';

    // Reset form key if needed
    if (formKey.currentState != null) {
      formKey.currentState!.reset();
    }

    // Bersihkan WargaDashboardController jika terdaftar
    try {
      if (Get.isRegistered<WargaDashboardController>()) {
        print(
          'Removing WargaDashboardController to ensure clean state after registration',
        );
        Get.delete<WargaDashboardController>(force: true);
      }
    } catch (e) {
      print('Error removing WargaDashboardController: $e');
    }
  }
}
