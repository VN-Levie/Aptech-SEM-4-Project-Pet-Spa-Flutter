import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:project/constants/app_const.dart';

class RestService {
  final storage = FlutterSecureStorage();

  // Hàm lấy lại token mới bằng refresh token
  Future<String?> refreshToken() async {
    String? refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('${AppConst.apiEndpoint}/auth/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var newToken = jsonResponse['jwt'];
      await storage.write(key: 'jwt_token', value: newToken);
      return newToken;
    } else {
      return null;
    }
  }

  // Phương thức POST với xử lý tự động lấy lại token
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    headers ??= {
      'Content-Type': 'application/json',
    };

    var request = http.Request('POST', Uri.parse('${AppConst.apiEndpoint}$endpoint'));
    request.body = json.encode(body);
    request.headers.addAll(headers);

    return await _sendRequestWithTokenRetry(request);
  }

  // Phương thức GET với xử lý tự động lấy lại token
  static Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    headers ??= {
      'Content-Type': 'application/json',
    };

    var request = http.Request('GET', Uri.parse('${AppConst.apiEndpoint}$endpoint'));
    request.headers.addAll(headers);

    return await _sendRequestWithTokenRetry(request);
  }

  // Phương thức PUT với xử lý tự động lấy lại token
  static Future<http.Response> put(String endpoint, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    headers ??= {
      'Content-Type': 'application/json',
    };

    var request = http.Request('PUT', Uri.parse('${AppConst.apiEndpoint}$endpoint'));
    request.body = json.encode(body);
    request.headers.addAll(headers);

    return await _sendRequestWithTokenRetry(request);
  }

  // Phương thức DELETE với xử lý tự động lấy lại token
  static Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    headers ??= {
      'Content-Type': 'application/json',
    };

    var request = http.Request('DELETE', Uri.parse('${AppConst.apiEndpoint}$endpoint'));
    request.headers.addAll(headers);

    return await _sendRequestWithTokenRetry(request);
  }

  // Hàm chung để gửi request và xử lý nếu có lỗi 401 (Unauthorized)
  static Future<http.Response> _sendRequestWithTokenRetry(http.Request request) async {
    try {
      // Gửi request
      http.StreamedResponse streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      http.Response response = await http.Response.fromStream(streamedResponse);

      // Kiểm tra nếu bị 401 thì thử refresh token và gửi lại yêu cầu
      if (response.statusCode == 401 && request.url.path.contains('/api/auth/verify-token') == false) {
        print("401 Unauthorized, trying to refresh token...");

        String? newToken = await _attemptRefreshToken();
        if (newToken != null) {
          // Thêm token mới vào headers và gửi lại request
          request.headers['Authorization'] = 'Bearer $newToken';
          streamedResponse = await request.send().timeout(const Duration(seconds: 15));
          response = await http.Response.fromStream(streamedResponse);
        }
      }

      return response;
    } catch (e) {
      // Xử lý lỗi và trả về thông báo
      return http.Response(json.encode({'status': 'error', 'message': 'Server is busy. Please try again later.'}), 503, headers: {'Content-Type': 'application/json'});
    }
  }

  // Hàm thử lấy lại token mới nếu bị 401
  static Future<String?> _attemptRefreshToken() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String? refreshToken = await storage.read(key: 'refresh_token');

    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('${AppConst.apiEndpoint}/auth/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var newToken = jsonResponse['jwt'];
      await storage.write(key: 'jwt_token', value: newToken);
      return newToken;
    } else {
      return null;
    }
  }
}
