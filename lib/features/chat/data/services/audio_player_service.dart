import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration? _duration;
  Duration _position = Duration.zero;

  bool get isPlaying => _isPlaying;
  Duration? get duration => _duration;
  Duration get position => _position;
  
  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;

  AudioPlayerService() {
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
    });

    _player.onDurationChanged.listen((duration) {
      _duration = duration;
    });

    _player.onPositionChanged.listen((position) {
      _position = position;
    });
  }

  Future<void> play(String path) async {
    try {
      await _player.play(DeviceFileSource(path));
      _isPlaying = true;
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
      _position = Duration.zero;
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _player.resume();
      _isPlaying = true;
    } catch (e) {
      print('Error resuming audio: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      print('Error seeking audio: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
