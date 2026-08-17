import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:landpage/src/services/apiUrl.dart';

class RegisterService {
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(BaseURL.registerAPIUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_name": username,
          "user_email": email,
          "password":  password,
          "user_ph_no": int.parse(phone),
        }),
      );

      // Convert response JSON to Map
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Registration Success
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "statusCode": response.statusCode,
          "message": data["message"] ?? "Registration Successful",
          "data": data,
        };
      }

      // Registration Failed
      return {
        "success": false,
        "statusCode": response.statusCode,
        "message": data["message"] ?? "Registration Failed",
      };
    } catch (e) {
      // Network/Server Exception
      return {
        "success": false,
        "statusCode": 500,
        "message": e.toString(),
      };
    }
  }
}