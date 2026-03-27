import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class VoiceRecognitionService {
  static final VoiceRecognitionService _instance =
      VoiceRecognitionService._internal();
  factory VoiceRecognitionService() => _instance;

  VoiceRecognitionService._internal();

  static const MethodChannel _channel = MethodChannel(
    'com.finot.voice_recognition',
  );
  bool _isListening = false;

  Future<String?> startListening({
    required Function(String) onResult,
    required Function() onDone,
  }) async {
    if (_isListening) {
      return 'Already listening';
    }

    try {
      _isListening = true;

      // Call the platform-specific method to start voice recognition
      final String? result = await _channel.invokeMethod(
        'startVoiceRecognition',
      );

      _isListening = false;

      if (result != null && result.isNotEmpty) {
        onResult(result);
      } else {
        return 'No speech detected';
      }

      onDone();
      return null;
    } on PlatformException catch (e) {
      _isListening = false;
      debugPrint('Platform exception: ${e.message}');
      return 'Error: ${e.message}';
    } catch (e) {
      _isListening = false;
      debugPrint('Error in voice recognition: $e');
      return 'Error: $e';
    }
  }

  void stopListening() {
    if (_isListening) {
      _channel.invokeMethod('stopVoiceRecognition');
      _isListening = false;
    }
  }

  bool get isListening => _isListening;
}
