import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AccountHandler extends ChangeNotifier {
  final url = 'http://10.0.2.2:5000/account';

  // demo user name
  String get userName => "Alex";

  Future<String> createAccount(String firstName, String lastName, String email, String password) async {
    Map<String, String> request = {
      'first-name': firstName,
      'last-name': lastName,
      'email': email,
      'password': password,
    };
    final headers = {"Content-Type": "application/json"};
    final response = await http.post(
      Uri.parse('$url/part1'),
      headers: headers,
      body: json.encode(request),
    );

    var jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 'success') {
      // Account created successfully
      print('Account created: ${response.body}');
      return jsonResponse['session_token'];
    } else {
      // Handle error
      print('Failed to create account: ${response.body}');
      return '';
    }
  }

  Future<String> login(String email, String password) async {
    final headers = {"Content-Type": "application/json"};
    final response = await http.get(
      Uri.parse('$url?email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}'),
      headers: headers,
    );

    var jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 'success') {
      // Login successful
      print('Login successful: ${response.body}');
      return jsonResponse['user-info']['session_token'];
    } else {
      // Handle error
      print('Failed to login: ${response.body}');
      return '';
    }
  }

  Future<Map<String, dynamic>?> getUserInfo(String sessionToken) async {
    final headers = {"Content-Type": "application/json"};
    final response = await http.get(
      Uri.parse('$url/info?session_token=${Uri.encodeComponent(sessionToken)}'),
      headers: headers,
    );

    var jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 'success') {
      // Retrieved user info successfully
      print('User info retrieved: ${response.body}');
      return jsonResponse['user-info'];
    } else {
      // Handle error
      print('Failed to retrieve user info: ${response.body}');
      return null;
    }
  }

  Future<String> updateAccountDetails(dateOfBirth, role, privacy, golf, gender, country, sessionToken) async {
    Map<String, String> request = {
      'date-of-birth': dateOfBirth.toString(),
      'role': role,
      'privacy': privacy,
      'level-of-golf': golf,
      'gender': gender,
      'country': country,
      'session_token': sessionToken
    };
    final headers = {"Content-Type": "application/json"};
    final response = await http.post(
      Uri.parse('$url/update'),
      headers: headers,
      body: json.encode(request),
    );

    var jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 'success') {
      // Account created successfully
      print('Account info updated: ${response.body}');
      return 'success';
    } else {
      // Handle error
      print('Failed to update account: ${response.body}');
      return '';
    }
  } 
  
  Future<String> sendResetPasswordEmail(email) async {
    Map<String, String> request = {
      'email': email
    };
    final headers = {"Content-Type": "application/json"};
    final response = await http.post(
      Uri.parse('$url/reset'),
      headers: headers,
      body: json.encode(request),
    );

    var jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 'success') {
      // Account created successfully
      return 'success';
    } else {
      // Handle error
      return '';
    }
  }

  Future<String> resetPasswordCode(code) async {
    Map<String, String> request = {
      'code': code
    };
    final headers = {"Content-Type": "application/json"};
    final response = await http.post(
      Uri.parse('$url/resetCode'),
      headers: headers,
      body: json.encode(request),
    );

    var jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 'success') {
      // Account created successfully
      return jsonResponse["session_token"];
    } else {
      // Handle error
      return '';
    }
  }

  Future<String> resetPassword(password, sessionToken) async {
    Map<String, String> request = {
      'password': password,
      'session_token': sessionToken
    };
    final headers = {"Content-Type": "application/json"};
    final response = await http.post(
      Uri.parse('$url/resetPassword'),
      headers: headers,
      body: json.encode(request),
    );

    var jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 'success') {
      // Account created successfully
      return 'success';
    } else {
      // Handle error
      return '';
    }
  }
}