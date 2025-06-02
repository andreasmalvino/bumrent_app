import 'package:get/get.dart';
import '../controllers/petugas_tambah_paket_controller.dart';

class PetugasTambahPaketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PetugasTambahPaketController>(
      () => PetugasTambahPaketController(),
    );
  }
}
