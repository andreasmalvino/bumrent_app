import 'package:get/get.dart';
import '../controllers/list_tagihan_periode_controller.dart';

class ListTagihanPeriodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListTagihanPeriodeController>(
      () => ListTagihanPeriodeController(),
    );
  }
}
