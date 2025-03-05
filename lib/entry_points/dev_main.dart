import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:huang_box_manager_web/di/di.dart';
import 'package:huang_box_manager_web/firebase_options.dart';
import '../main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlavorConfig(name: "DEV", variables: {"baseUrl": "http://127.0.0.1:5050"});
  usePathUrlStrategy();
  // Инициализация DI
  setupDependencies();
  runApp(ClientApp());
}
