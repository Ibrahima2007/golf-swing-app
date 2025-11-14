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
      return jsonResponse['session-token'];
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
      return jsonResponse['user-info']['session-token'];
    } else {
      // Handle error
      print('Failed to login: ${response.body}');
      return '';
    }
  }
}