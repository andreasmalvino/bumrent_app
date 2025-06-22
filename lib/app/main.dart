import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bumrent_app/app/data/providers/aset_provider.dart';
import 'package:bumrent_app/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AsetProvider());
  runApp(const MyApp());
}
