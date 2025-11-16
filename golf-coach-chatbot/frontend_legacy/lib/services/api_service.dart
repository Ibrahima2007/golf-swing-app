import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final apiServiceProvider = Provider<ApiService>(
  (ref) => ApiService(),
);

class ApiService {
  ApiService({http.Client? client, this.baseUrl = 'http://localhost:5000'})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Future<UploadResponse> uploadVideo(PlatformFile file) async {
    final uri = Uri.parse('$baseUrl/upload_video');
    final request = http.MultipartRequest('POST', uri);

    if (kIsWeb) {
      final bytes = file.bytes;
      if (bytes == null) {
        throw Exception('Unable to read video bytes on web.');
      }
      request.files.add(
        http.MultipartFile.fromBytes(
          'video',
          bytes as List<int>,
          filename: file.name,
        ),
      );
    } else {
      final path = file.path;
      if (path == null) {
        throw Exception('File path missing.');
      }
      request.files.add(
        await http.MultipartFile.fromPath(
          'video',
          path,
          filename: file.name,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UploadResponse(
      videoId: data['video_id'] as String,
      initialAnalysis: (data['initial_analysis'] ?? '') as String,
    );
  }

  Future<String> sendChatMessage({
    required String videoId,
    required String message,
  }) async {
    final uri = Uri.parse('$baseUrl/chat');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'video_id': videoId,
        'message': message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Chat failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['reply'] ?? '') as String;
  }
}

class UploadResponse {
  UploadResponse({required this.videoId, required this.initialAnalysis});

  final String videoId;
  final String initialAnalysis;
}

