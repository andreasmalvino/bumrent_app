import 'package:get/get.dart';
import '../controllers/list_pelanggan_aktif_controller.dart';

class ListPelangganAktifBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListPelangganAktifController>(
      () => ListPelangganAktifController(),
    );
  }
}
