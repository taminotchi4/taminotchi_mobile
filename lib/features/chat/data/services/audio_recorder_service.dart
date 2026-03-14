import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  Timer? _amplitudeTimer;
  final List<double> _amplitudeData = [];

  List<double> get amplitudeData => List.unmodifiable(_amplitudeData);

  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      return true;
    }
    
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  Future<bool> startRecording() async {
    try {
      if (!await hasPermission()) {
        return false;
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/audio_$timestamp.m4a';
      _recordingStartTime = DateTime.now();
      _amplitudeData.clear();

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      // Start collecting amplitude data for waveform
      _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        final amplitude = await _recorder.getAmplitude();
        if (amplitude.current > -160) {
          // Normalize amplitude to 0-1 range
          final normalized = (amplitude.current + 160) / 160;
          _amplitudeData.add(normalized.clamp(0.0, 1.0));
        }
      });

      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  Future<({String? path, Duration? duration, List<double> waveform})> stopRecording() async {
    try {
      _amplitudeTimer?.cancel();
      _amplitudeTimer = null;

      final path = await _recorder.stop();
      final duration = _recordingStartTime != null 
          ? DateTime.now().difference(_recordingStartTime!)
          : null;
      
      final waveform = List<double>.from(_amplitudeData);
      _amplitudeData.clear();
      _recordingStartTime = null;

      return (path: path, duration: duration, waveform: waveform);
    } catch (e) {
      print('Error stopping recording: $e');
      return (path: null, duration: null, waveform: <double>[]);
    }
  }

  Future<void> cancelRecording() async {
    try {
      _amplitudeTimer?.cancel();
      _amplitudeTimer = null;
      _amplitudeData.clear();
      _recordingStartTime = null;

      await _recorder.stop();
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error canceling recording: $e');
    }
  }

  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  void dispose() {
    _amplitudeTimer?.cancel();
    _recorder.dispose();
  }
}
