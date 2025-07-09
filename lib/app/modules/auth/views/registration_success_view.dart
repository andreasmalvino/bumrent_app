import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import 'package:flutter/rendering.dart';
import '../../../routes/app_routes.dart';

class RegistrationSuccessView extends StatefulWidget {
  const RegistrationSuccessView({Key? key}) : super(key: key);

  @override
  State<RegistrationSuccessView> createState() =>
      _RegistrationSuccessViewState();
}

class _RegistrationSuccessViewState extends State<RegistrationSuccessView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  String? registerId;

  @override
  void initState() {
    super.initState();

    // Get the registration ID from arguments
    if (Get.arguments != null && Get.arguments is Map) {
      registerId = Get.arguments['register_id'] as String?;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background elements
            Positioned(
              top: -120,
              left: -120,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.successLight,
                ),
              ),
            ),
            Positioned(
              right: -80,
              bottom: 100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight.withOpacity(0.2),
                ),
              ),
            ),

            // Confetti particles
            Positioned.fill(child: _buildConfettiParticles()),

            // Main content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSuccessAnimation(),
                  const SizedBox(height: 40),
                  _buildSuccessMessage(),
                  const SizedBox(height: 40),
                  _buildBackToLoginButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfettiParticles() {
    return Stack(
      children: List.generate(20, (index) {
        final left = (index * 20) % MediaQuery.of(context).size.width;
        final top = (index * 30) % MediaQuery.of(context).size.height;
        final size = 8.0 + (index % 5) * 2;

        final colors = [
          AppColors.success,
          AppColors.primary,
          AppColors.accent,
          AppColors.primaryLight,
        ];

        return Positioned(
          left: left.toDouble(),
          top: top.toDouble(),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final delay = index * 0.1;
              final startTime = delay;
              final endTime = startTime + 0.8;

              double opacity = 0.0;
              if (_animationController.value >= startTime) {
                opacity =
                    (_animationController.value - startTime) /
                    (endTime - startTime);
                if (opacity > 1.0) opacity = 1.0;
              }

              return Opacity(
                opacity: opacity,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape:
                        index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius:
                        index % 2 == 0 ? null : BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildSuccessAnimation() {
    return Center(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Hero(
                  tag: 'success',
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            children: [
              Text(
                'Pendaftaran Berhasil!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Akun Anda telah berhasil terdaftar. Silahkan tunggu petugas untuk melakukan verifikasi data diri anda.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (registerId != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Kode Registrasi:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        registerId!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.copy,
                          size: 20,
                          color: AppColors.success,
                        ),
                        onPressed: () {
                          // Copy to clipboard
                          final data = ClipboardData(text: registerId!);
                          Clipboard.setData(data);
                          Get.snackbar(
                            'Berhasil Disalin',
                            'Kode registrasi telah disalin ke clipboard',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: AppColors.successLight,
                            colorText: AppColors.success,
                            margin: const EdgeInsets.all(16),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Simpan kode registrasi ini untuk memeriksa status pendaftaran Anda.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackToLoginButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () {
                // Navigate back to login page
                Get.offNamed(Routes.LOGIN);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.buttonText,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Masuk Sekarang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
