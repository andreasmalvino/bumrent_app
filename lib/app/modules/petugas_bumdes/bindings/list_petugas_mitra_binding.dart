import 'package:get/get.dart';
import '../controllers/list_petugas_mitra_controller.dart';

class ListPetugasMitraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListPetugasMitraController>(() => ListPetugasMitraController());
  }
}
