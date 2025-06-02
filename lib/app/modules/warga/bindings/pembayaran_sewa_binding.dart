import 'package:get/get.dart';
import '../controllers/pembayaran_sewa_controller.dart';

class PembayaranSewaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PembayaranSewaController>(() => PembayaranSewaController());
  }
}
