import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class AudioProvider with ChangeNotifier {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;
  String? _processedFilePath;
  double _pitchValue = 0.8; // Default deeper pitch
  double _volumeValue = 1.5; // Default boosted volume

  // Getters
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  double get pitchValue => _pitchValue;
  double get volumeValue => _volumeValue;

  Future<void> initRecorder() async {
    await _recorder.openRecorder();
    await _player.openPlayer();
  }

  Future<void> startRecording() async {
    try {
      await FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'recording_channel',
          channelName: 'Voice Recording',
        ),
      );
      
      final directory = await getTemporaryDirectory();
      _recordedFilePath = '${directory.path}/recording.aac';
      
      await _recorder.startRecorder(
        toFile: _recordedFilePath,
        codec: Codec.aacADTS,
      );
      _isRecording = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Recording error: $e');
    }
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
    _isRecording = false;
    notifyListeners();
    await FlutterForegroundTask.stop();
  }

  Future<void> processAudio() async {
    if (_recordedFilePath == null) return;

    final directory = await getTemporaryDirectory();
    _processedFilePath = '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.aac';

    final command = '-i "$_recordedFilePath" '
        '-af "asetrate=44100*$_pitchValue,atempo=1/$_pitchValue,volume=$_volumeValue" '
        '-y "$_processedFilePath"';

    await _flutterFFmpeg.execute(command);
    notifyListeners();
  }

  Future<void> playProcessed() async {
    if (_processedFilePath == null) return;
    
    await _player.startPlayer(
      fromURI: _processedFilePath,
      whenFinished: () {
        _isPlaying = false;
        notifyListeners();
      },
    );
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> stopPlaying() async {
    await _player.stopPlayer();
    _isPlaying = false;
    notifyListeners();
  }

  void setPitch(double value) {
    _pitchValue = value;
    notifyListeners();
  }

  void setVolume(double value) {
    _volumeValue = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }
}
