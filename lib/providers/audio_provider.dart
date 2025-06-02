import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class AudioProvider with ChangeNotifier {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;
  String? _processedFilePath;
  double _pitchValue = 1.0;
  double _volumeValue = 1.0;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get recordedFilePath => _recordedFilePath;
  String? get processedFilePath => _processedFilePath;
  double get pitchValue => _pitchValue;
  double get volumeValue => _volumeValue;

  Future<void> initRecorder() async {
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future<void> startRecording() async {
    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/recording.aac';
      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );
      _isRecording = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      _recordedFilePath = await _recorder.stopRecorder();
      _isRecording = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> playOriginal() async {
    if (_recordedFilePath == null) return;

    await _player.openPlayer();
    await _player.startPlayer(
      fromURI: _recordedFilePath,
      whenFinished: () {
        _isPlaying = false;
        notifyListeners();
      },
    );
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> playProcessed() async {
    if (_processedFilePath == null) return;

    await _player.openPlayer();
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

  Future<void> processAudio() async {
    if (_recordedFilePath == null) return;

    final directory = await getTemporaryDirectory();
    _processedFilePath = '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.aac';

    String command = '-i "$_recordedFilePath" '
        '-af "asetrate=44100*$_pitchValue,atempo=1/$_pitchValue,volume=$_volumeValue" '
        '-y "$_processedFilePath"';

    int result = await _flutterFFmpeg.execute(command);
    if (result == 0) {
      debugPrint('Audio processing successful');
    } else {
      debugPrint('Audio processing failed with code $result');
    }
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

  Future<void> disposeAll() async {
    await _recorder.closeRecorder();
    await _player.closePlayer();
  }
}
