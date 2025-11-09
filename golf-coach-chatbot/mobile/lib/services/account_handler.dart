import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AccountHandler extends ChangeNotifier {
  final url = 'http://10.0.2.2:5000/account';

  Future<bool> createAccount(String firstName, String lastName, String email, String password) async {
    Map<String, String> request = {
      'first-name': firstName,
      'last-name': lastName,
      'email': email,
      'password': password,
    };
    final headers = {"Content-Type": "application/json"};
    final response = await http.post(
      Uri.parse(url + '/part1'),
      headers: headers,
      body: json.encode(request),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Account created successfully
      print('Account created: ${response.body}');
      return true;
    } else {
      // Handle error
      print('Failed to create account: ${response.statusCode}');
      return false;
    }
  }
}