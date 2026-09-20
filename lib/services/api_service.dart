import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://fakestoreapi.com/',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    try {
      var response = await dio.post('auth/login', data: data);
      return {'success': true, 'token': response.data['token']};
    } catch (e) {
      return {'success': false, 'error': '$e'};
    }
  }

  Future<Map<String, dynamic>> getProducts() async {
    try {
      var response = await dio.get('products');
      return {
        'success': true,
        'products': response.data,
        'status_code': response.statusCode
      };
    } catch (e) {
      return {'success': false, 'error': '$e'};
    }
  }
}
