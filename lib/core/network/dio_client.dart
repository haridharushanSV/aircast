import 'package:dio/dio.dart';

class DioClient {
  static Dio create() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }
}
