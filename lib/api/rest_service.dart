import 'package:chopper/chopper.dart';

part 'rest_service.chopper.dart';

@ChopperApi()
abstract class RestService extends ChopperService {
  static RestService create([ChopperClient? client]) =>
      _$RestService(client ?? ChopperClient());

  @Get(path: '/user-data')
  Future<Response> verifyToken(@Header('Authorization') String authHeader);

  @Put(path: '/edit-user-data')
  Future<Response> editUserData(
    @Header('Authorization') String authHeader,
    @Body() Map<String, dynamic> body,
  );
}
