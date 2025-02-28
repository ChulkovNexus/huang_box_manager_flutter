import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:huang_box_manager_web/firebase_options.dart';
import '../main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlavorConfig(
    name: "DEV",
    variables: {
      "authBaseUrl": "https://pmh-api.metholding.com/auth-dev",
      "1cBaseUrl": "https://pmh-api.metholding.com/1c-service-dev",
      "newsBaseUrl": "https://pmh-api.metholding.com/news-service-dev",
      "filesBaseUrl": "https://pmh-api.metholding.com/files-service-dev",
      "pushBaseUrl": "https://pmh-api.metholding.com/push-dev",
      "calendarBaseUrl": "https://pmh-api.metholding.com/event-dev",
      "logBaseUrl": "https://pmh-api.metholding.com/log-service",
    },
  );
  usePathUrlStrategy();
  runApp(ClientApp());
}
