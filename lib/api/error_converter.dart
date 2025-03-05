import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';

class JsonErrorConverter implements ErrorConverter {
  @override
  FutureOr<Response<dynamic>> convertError<BodyType, InnerType>(
    Response response,
  ) {
    try {
      dynamic error = response.error;
      Map<String, dynamic>? errorMap;

      if (response.bodyString.isNotEmpty) {
        // Если ошибка — строка, пытаемся разобрать её как JSON
        errorMap = jsonDecode(response.bodyString) as Map<String, dynamic>;
      } else if (error is Map<String, dynamic>) {
        // Если ошибка уже Map, используем её напрямую
        errorMap = error;
      } else {
        // Если тип неизвестен, создаём дефолтную ошибку
        errorMap = {'error': 'unknown_error'};
      }

      // Создаём новый Response с кодом ошибки и телом в формате Map
      return Response<dynamic>(response.base, response.body, error: errorMap);
    } catch (e) {
      // В случае ошибки парсинга возвращаем Response с дефолтной ошибкой
      return Response<dynamic>(
        response.base,
        response.body,
        error: {'error': 'failed_to_parse_error'},
      );
    }
  }
}
