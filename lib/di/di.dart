import 'package:chopper/chopper.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:get_it/get_it.dart';
import 'package:huang_box_manager_web/api/error_converter.dart';
import 'package:huang_box_manager_web/api/rest_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  String baseUrl = FlavorConfig.instance.variables["baseUrl"] as String;
  getIt.registerLazySingleton<ChopperClient>(
    () => ChopperClient(
      baseUrl: Uri.parse(baseUrl),
      services: [RestService.create()],
      converter: const JsonConverter(),
      errorConverter: JsonErrorConverter(),
      interceptors: [
        (Request request) async {
          debugPrint('Sending request: ${request.method} ${request.url}');
          debugPrint('Headers: ${request.headers}');
          return request;
        },
        (Response response) async {
          debugPrint('Response: ${response.statusCode} ${response.bodyString}');
          return response;
        },
        HttpLoggingInterceptor(),
      ],
    ),
  );

  getIt.registerLazySingleton<RestService>(
    () => RestService.create(getIt<ChopperClient>()),
  );
}
