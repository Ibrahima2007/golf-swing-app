import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class AccountHandler extends ChangeNotifier {
  final String _baseUrl = AppConfig.accountBaseUrl;

  // demo user name
  String get userName => "Alex";

  Future<String> createAccount(String firstName, String lastName, String email, String password) async {
    try {
      Map<String, String> request = {
        'first-name': firstName,
        'last-name': lastName,
        'email': email,
        'password': password,
      };
      final headers = {"Content-Type": "application/json"};
      print('Sending account creation request to: $_baseUrl/part1');
      final response = await http.post(
        Uri.parse('$_baseUrl/part1'),
        headers: headers,
        body: json.encode(request),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        print('HTTP error: ${response.statusCode}');
        return '';
      }

      var jsonResponse = json.decode(response.body);
      print('Parsed JSON response: $jsonResponse');
      
      if (jsonResponse['status'] == 'success') {
        // Account created successfully
        final sessionToken = jsonResponse['session_token'] ?? '';
        print('Account created successfully, session token: $sessionToken');
        return sessionToken;
      } else {
        // Handle error
        print('Failed to create account: ${response.body}');
        return '';
      }
    } catch (e) {
      print('Exception in createAccount: $e');
      return '';
    }
  }

  Future<String> login(String email, String password) async {
    final headers = {"Content-Type": "application/json"};
    final response = await http.get(
      Uri.parse('$_baseUrl?email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}'),
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
      Uri.parse('$_baseUrl/info?session_token=${Uri.encodeComponent(sessionToken)}'),
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
      Uri.parse('$_baseUrl/update'),
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
}