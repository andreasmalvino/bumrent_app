import 'package:get/get.dart';

// Import bindings
import '../bindings/auth_binding.dart';
import '../bindings/warga_binding.dart';
import '../bindings/petugas_bumdes_binding.dart';
import '../bindings/petugas_mitra_binding.dart';
import '../bindings/splash_binding.dart';
import '../modules/warga/bindings/sewa_aset_binding.dart';
import '../modules/warga/bindings/order_sewa_aset_binding.dart';
import '../modules/warga/bindings/order_sewa_paket_binding.dart';
import '../modules/warga/bindings/warga_sewa_binding.dart';
import '../modules/warga/bindings/pembayaran_sewa_binding.dart';
import '../modules/petugas_bumdes/bindings/petugas_aset_binding.dart';
import '../modules/petugas_bumdes/bindings/petugas_paket_binding.dart';
import '../modules/petugas_bumdes/bindings/petugas_sewa_binding.dart';
import '../modules/petugas_bumdes/bindings/petugas_manajemen_bumdes_binding.dart';
import '../modules/petugas_bumdes/bindings/petugas_tambah_aset_binding.dart';
import '../modules/petugas_bumdes/bindings/petugas_tambah_paket_binding.dart';
import '../modules/petugas_bumdes/bindings/petugas_bumdes_cbp_binding.dart';
import '../modules/petugas_bumdes/bindings/list_petugas_mitra_binding.dart';
import '../modules/petugas_bumdes/bindings/list_pelanggan_aktif_binding.dart';
import '../modules/petugas_bumdes/bindings/list_tagihan_periode_binding.dart';

// Import views
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/registration_view.dart';
import '../modules/auth/views/registration_success_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/warga/views/warga_dashboard_view.dart';
import '../modules/warga/views/sewa_aset_view.dart';
import '../modules/warga/views/warga_sewa_view.dart';
import '../modules/warga/views/warga_profile_view.dart';
import '../modules/petugas_bumdes/views/petugas_bumdes_dashboard_view.dart';
import '../modules/petugas_bumdes/views/petugas_aset_view.dart';
import '../modules/petugas_bumdes/views/petugas_paket_view.dart';
import '../modules/petugas_bumdes/views/petugas_sewa_view.dart';
import '../modules/petugas_bumdes/views/petugas_manajemen_bumdes_view.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/warga/views/order_sewa_aset_view.dart';
import '../modules/warga/views/order_sewa_paket_view.dart';
import '../modules/warga/views/pembayaran_sewa_view.dart';
import '../modules/petugas_bumdes/views/petugas_tambah_aset_view.dart';
import '../modules/petugas_bumdes/views/petugas_tambah_paket_view.dart';
import '../modules/petugas_bumdes/views/petugas_bumdes_cbp_view.dart';
import '../modules/petugas_bumdes/views/list_petugas_mitra_view.dart';
import '../modules/petugas_bumdes/views/list_pelanggan_aktif_view.dart';
import '../modules/petugas_bumdes/views/list_tagihan_periode_view.dart';

// Import fixed routes (standalone file)
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegistrationView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.REGISTRATION_SUCCESS,
      page: () => const RegistrationSuccessView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    // Warga Dashboard with navbar
    GetPage(
      name: Routes.WARGA_DASHBOARD,
      page: () => const WargaDashboardView(),
      binding: WargaBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.PETUGAS_BUMDES_DASHBOARD,
      page: () => const PetugasBumdesDashboardView(),
      binding: PetugasBumdesBinding(),
      transition: Transition.fadeIn,
    ),
    // Warga Features Routes
    GetPage(
      name: Routes.SEWA_ASET,
      page: () => const SewaAsetView(),
      binding: SewaAsetBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.ORDER_SEWA_ASET,
      page: () => const OrderSewaAsetView(),
      binding: OrderSewaAsetBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
      preventDuplicates: false,
      maintainState: true,
      opaque: true,
    ),
    GetPage(
      name: Routes.ORDER_SEWA_PAKET,
      page: () => const OrderSewaPaketView(),
      binding: OrderSewaPaketBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
      preventDuplicates: false,
      maintainState: true,
      opaque: true,
    ),
    GetPage(
      name: Routes.PEMBAYARAN_SEWA,
      page: () => const PembayaranSewaView(),
      binding: PembayaranSewaBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // Warga Sewa with navbar
    GetPage(
      name: Routes.WARGA_SEWA,
      page: () => const WargaSewaView(),
      binding: WargaSewaBinding(),
      transition: Transition.noTransition,
    ),
    // Profile page
    GetPage(
      name: Routes.PROFILE,
      page: () => const WargaProfileView(),
      binding: WargaBinding(),
      transition: Transition.noTransition,
    ),
    // Petugas BUMDes Features
    GetPage(
      name: Routes.PETUGAS_ASET,
      page: () => const PetugasAsetView(),
      binding: PetugasAsetBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.PETUGAS_PAKET,
      page: () => const PetugasPaketView(),
      binding: PetugasPaketBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.PETUGAS_SEWA,
      page: () => const PetugasSewaView(),
      binding: PetugasSewaBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.PETUGAS_MANAJEMEN_BUMDES,
      page: () => const PetugasManajemenBumdesView(),
      binding: PetugasManajemenBumdesBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.PETUGAS_TAMBAH_ASET,
      page: () => const PetugasTambahAsetView(),
      binding: PetugasTambahAsetBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.PETUGAS_TAMBAH_PAKET,
      page: () => const PetugasTambahPaketView(),
      binding: PetugasTambahPaketBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.PETUGAS_BUMDES_CBP,
      page: () => const PetugasBumdesCbpView(),
      binding: PetugasBumdesCbpBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.LIST_PETUGAS_MITRA,
      page: () => const ListPetugasMitraView(),
      binding: ListPetugasMitraBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.LIST_PELANGGAN_AKTIF,
      page: () => const ListPelangganAktifView(),
      binding: ListPelangganAktifBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.LIST_TAGIHAN_PERIODE,
      page: () => const ListTagihanPeriodeView(),
      binding: ListTagihanPeriodeBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
