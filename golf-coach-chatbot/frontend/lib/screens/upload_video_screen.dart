import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/root_shell.dart';
import '../providers/chat_session_provider.dart';
import '../providers/navigation_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  PlatformFile? _selectedVideo;
  bool _isUploading = false;

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: kIsWeb,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedVideo = result.files.single);
    }
  }

  void _removeVideo() {
    setState(() => _selectedVideo = null);
  }

  Future<void> _uploadVideo() async {
    final selected = _selectedVideo;
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video first.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final api = context.read<ApiService>();
      final response = await api.uploadVideo(selected);
      if (!mounted) return;

      _handleSuccessfulUpload(response, successMessage: 'Video uploaded successfully.');
    } catch (e) {
      if (!mounted) return;
      final demoResponse = UploadResponse(
        videoId: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        initialAnalysis:
            'Demo insight: your backswing tempo looks smooth. Try keeping your lead arm straighter through impact.',
      );
      _handleSuccessfulUpload(
        demoResponse,
        successMessage: 'Backend unreachable, running chatbot in demo mode instead.',
        isFallback: true,
        error: e,
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _handleSuccessfulUpload(
    UploadResponse response, {
    required String successMessage,
    bool isFallback = false,
    Object? error,
  }) {
    final chatProvider = context.read<ChatSessionProvider>();
    chatProvider.initializeSession(response);
    context.read<NavigationProvider>().setIndex(NavigationTabs.chat);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage),
        backgroundColor: isFallback ? Colors.orange : null,
      ),
    );
    if (isFallback && error != null) {
      debugPrint('Upload fallback triggered due to: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Swing Video',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _selectedVideo == null
                              ? Icons.cloud_upload_outlined
                              : Icons.check_circle_outline,
                          size: 56,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedVideo == null
                              ? 'Upload your golf swing video'
                              : 'Selected: ${_selectedVideo!.name}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isUploading ? null : _pickVideo,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Select Video',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_selectedVideo != null)
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              OutlinedButton(
                                onPressed: _isUploading ? null : _pickVideo,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Reselect'),
                              ),
                              OutlinedButton(
                                onPressed: _isUploading ? null : _removeVideo,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        const SizedBox(height: 24),
                        if (_selectedVideo != null)
                          FilledButton(
                            onPressed: _isUploading ? null : _uploadVideo,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              backgroundColor: Colors.green.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isUploading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Analyze Swing',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () =>
                    RootShell.navigateToChat(context),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Go to Chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

