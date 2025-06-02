import 'package:get/get.dart';
import '../data/providers/auth_provider.dart';
import '../modules/warga/controllers/warga_dashboard_controller.dart';

class WargaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<WargaDashboardController>(() => WargaDashboardController());
  }
}
