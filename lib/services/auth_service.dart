import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';
import 'package:smart_auth/smart_auth.dart';
class AuthService {

  // đường dẫn tới API login
  String get apiUrl =>
      "${Config_URL.baseUrl}Authenticate/login";
  Future<Map<String, dynamic>> login(String username,
      String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        //Lấy thông tin tên đăng nhập và password
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bool status = data['status'];
        if (!status) {
          return {"success": false, "message":
          data['message']};
        }
        //lấy token trả về
        String token = data['token'];
        String name = data['name'];
        String email = data['email'];
        String role = data['role'];
        // Decode token để lấy các thông tin đăng nhập: tên đăng nhập, role...
        Map<String, dynamic> decodedToken =
        JwtDecoder.decode(token);
        // Lưu token vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('jwt_token', token); // Lưu token// prefs.setString('jwt_token', token);
        prefs.setString('name', name);
        prefs.setString('email', email);
        prefs.setString('role', role);
        return {
          "success": true,
          "token": token,
          "decodedToken": decodedToken,
        };
      } else {
        // If status code is not 200, treat it as login failure
        return {"success": false, "message": "Failed to login: ${response.statusCode}"};
      }
    } catch (e) {
      // Handle network or parsing errors
      return {"success": false, "message": "Network error: $e"};
    }
  }
  final SmartAuth _smartAuth = SmartAuth();

  // Lấy mã OTP qua SMS Retriever API
  Future<String?> retrieveSmsCode() async {
    try {
      // Sử dụng hàm getSmsCode của SmartAuth
      final smsCode = await _smartAuth.getSmsCode();
      if (smsCode != null) {
        // Giả sử mã OTP có dạng 6 chữ số
        final otpMatch = RegExp(r'\d{6}').firstMatch(smsCode as String);
        return otpMatch?.group(0); // Trả về mã OTP nếu tìm thấy
      }
      print('Không tìm thấy mã OTP trong tin nhắn SMS.');
    } catch (e) {
      print('Lỗi khi lấy mã OTP: $e');
    }
    return null; // Trả về null nếu không lấy được mã OTP
  }
}