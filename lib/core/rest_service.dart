import 'dart:convert';
import 'package:http/http.dart' as http;

class RestService {
  
  // Phương thức POST tĩnh
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    print('POST: http://10.0.2.2:8090$endpoint');

    // Thiết lập headers nếu không được truyền vào
    headers ??= {
      'Content-Type': 'application/json',
    };
    var s = json.encode(body);
    print('s:  ${s}');
    var request = http.Request('POST', Uri.parse('http://10.0.2.2:8090$endpoint'));
    request.body = s;
    request.headers.addAll(headers);

    // Gửi request
    http.StreamedResponse streamedResponse = await request.send();

    // Chuyển từ StreamedResponse về Response
    http.Response response = await http.Response.fromStream(streamedResponse);

    return response;
  }

  // Phương thức GET tĩnh
  static Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    print('GET: http://10.0.2.2:8090$endpoint');
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8090$endpoint'),
      headers: headers ??
          <String, String>{
            'Content-Type': 'application/json'
          },
    );

    return response;
  }

  // Phương thức PUT tĩnh
  static Future<http.Response> put(String endpoint, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    print('PUT: http://10.0.2.2:8090$endpoint');
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8090$endpoint'),
      headers: headers ??
          <String, String>{
            'Content-Type': 'application/json'
          },
      body: jsonEncode(body),
    );

    return response;
  }

  // Phương thức DELETE tĩnh
  static Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    print('DELETE: http://10.0.2.2:8090$endpoint');
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8090$endpoint'),
      headers: headers ??
          <String, String>{
            'Content-Type': 'application/json'
          },
    );

    return response;
  }
}
