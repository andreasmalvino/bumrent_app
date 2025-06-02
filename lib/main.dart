import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/data/providers/auth_provider.dart';
import 'app/modules/petugas_bumdes/controllers/petugas_bumdes_dashboard_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/services/navigation_service.dart';
import 'app/services/service_manager.dart';
import 'app/theme/app_theme.dart';

void main() async {
  // Pastikan Flutter diinisialisasi dengan benar
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientasi layar ke portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize GetStorage
  await GetStorage.init();
  debugPrint('✅ GetStorage initialized successfully');

  // Load .env file
  try {
    await dotenv.load();
    debugPrint('✅ .env file loaded successfully');
  } catch (e) {
    debugPrint('❌ Error loading .env file: $e');
  }

  // Initialize intl package for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Initialize navigation service
  await Get.putAsync<NavigationService>(() => NavigationService().init());
  debugPrint('✅ NavigationService initialized successfully');

  // Buat instance dan inisialisasi Supabase (hanya 1 kali)
  final authProvider = Get.put(AuthProvider(), permanent: true);

  try {
    await authProvider.init();
    debugPrint('✅ Auth provider initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing auth provider: $e');
  }

  // Pre-register the dashboard controller to fix dependency issues
  Get.put(PetugasBumdesDashboardController(), permanent: true);
  debugPrint('✅ PetugasBumdesDashboardController initialized globally');

  // Register services yang akan digunakan secara global
  ServiceManager.registerServices();

  // Jalankan aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BumRent',
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      locale: const Locale('id', 'ID'),
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
