import 'package:get/get.dart';
import '../controllers/petugas_tambah_aset_controller.dart';

class PetugasTambahAsetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PetugasTambahAsetController>(
      () => PetugasTambahAsetController(),
    );
  }
}
