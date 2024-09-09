import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import '../libs/routes.dart';

class ApiService {
  // ApiService(this.baseUrl);
  String baseUrl = dotenv.env['APP_URL']!;

  Future<Map<String, dynamic>> getResponseData(String endpoint, BuildContext context) async {
    
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(
      url,
      headers: await _headers()
    );

    if (response.statusCode == 200) {
      if ( jsonDecode(response.body)['status'] == 401 ) {
        removeAuth(context);
        throw Exception("Expired token");
      }

      return jsonDecode(response.body);

    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> getListData(String endpoint, BuildContext context) async {
    
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(
      url,
      headers: await _headers()
    );
    
    if (response.statusCode == 200) {
      if (jsonDecode(response.body) is List == false) {
        if ( jsonDecode(response.body)['status'] == 401 ) {
          removeAuth(context);
          throw Exception("Expired token");
        }
      }
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  

  Future<Map<String, dynamic>> postDataRequest(String endpoint, Map<String, dynamic> fields) async {    
    var url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.post(
      url,
      headers: await _headers(),
      body: json.encode(fields),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> postDataFormWithFiles(String endpoint, Map<String, dynamic> fields, List<PlatformFile> files, BuildContext context) async {    
    var url = Uri.parse('$baseUrl/$endpoint');
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(
      await _headers()
    );

    for (var file in files) {
      var f = File(file.path!);
      var stream = http.ByteStream(f.openRead());
      var length = await f.length();
      var multipartFile = http.MultipartFile(
        'files', 
        stream,
        length,
        filename: f.uri.pathSegments.last,
      );
      request.files.add(multipartFile);
    }
    
    fields.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    
    var response = await request.send();
    var responseData = await http.Response.fromStream(response);


    if ( jsonDecode(responseData.body)['status'] == 401 ) {
      removeAuth(context);
      throw Exception("Expired token");
    }

    return jsonDecode(responseData.body);
  }


  Future<Map<String, dynamic>> deleteDataForm(String endpoint, Map<String, dynamic> fields, BuildContext context) async {    
    var url = Uri.parse('$baseUrl/$endpoint');
    var request = http.MultipartRequest('DELETE', url);
    request.headers.addAll(
      await _headers()
    );
    
    fields.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    
    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    return jsonDecode(responseData.body);
  }


  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      return {
        'Content-Type': 'application/json'
      };
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
  }

  Future<void> removeAuth(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final Routes routes = Routes();
    await prefs.remove('token');
    await prefs.remove('user');

    routes.to(context, 'signin', null);
  }

}