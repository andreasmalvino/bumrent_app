// Daftar route constant untuk aplikasi
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();

  // Auth
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const REGISTRATION_SUCCESS = '/registration-success';
  static const FORGOT_PASSWORD = '/forgot-password';

  // Splash
  static const SPLASH = '/splash';

  // Main Dashboards
  static const WARGA_DASHBOARD = '/warga-dashboard';
  static const PETUGAS_BUMDES_DASHBOARD = '/petugas-bumdes-dashboard';

  // Warga Features
  static const SEWA_ASET = '/sewa-aset';
  static const ORDER_SEWA_ASET = '/order-sewa-aset';
  static const ORDER_SEWA_PAKET = '/order-sewa-paket';
  static const PEMBAYARAN_SEWA = '/pembayaran-sewa';
  static const WARGA_SEWA = '/warga-sewa';
  static const LANGGANAN = '/langganan';
  static const LANGGANAN_ASET = '/langganan-aset';

  // Petugas BUMDes Features
  static const PETUGAS_ASET = '/petugas-aset';
  static const PETUGAS_PAKET = '/petugas-paket';
  static const PETUGAS_SEWA = '/petugas-sewa';
  static const PETUGAS_MANAJEMEN_BUMDES = '/petugas-manajemen-bumdes';
  static const PETUGAS_TAMBAH_ASET = '/petugas-tambah-aset';
  static const PETUGAS_TAMBAH_PAKET = '/petugas-tambah-paket';
  static const PETUGAS_BUMDES_CBP = '/petugas-bumdes-cbp';
  static const LIST_PETUGAS_MITRA = '/list-petugas-mitra';
  static const LIST_PELANGGAN_AKTIF = '/list-pelanggan-aktif';
  static const LIST_TAGIHAN_PERIODE = '/list-tagihan-periode';
  static const PETUGAS_LANGGANAN = '/petugas-langganan';
  static const PETUGAS_TAGIHAN_LANGGANAN = '/petugas-tagihan-langganan';

  // Petugas Mitra Features
  static const PETUGAS_MITRA_DASHBOARD = '/petugas-mitra-dashboard';

  // Other common routes
  static const PROFILE = '/profile';
}
