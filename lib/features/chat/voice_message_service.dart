import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'chat_platform_file.dart';

class VoiceRecordingResult {
  final String path;
  final double durationSeconds;
  final List<double> waveform;

  const VoiceRecordingResult({
    required this.path,
    required this.durationSeconds,
    required this.waveform,
  });
}

class VoiceMessageService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _recordingPath;
  String? _playingId;
  StreamSubscription<Amplitude>? _ampSub;
  final List<double> _samples = [];

  String? get playingId => _playingId;

  Future<bool> ensureMicPermission() async {
    if (kIsWeb) return false;
    if (await _recorder.hasPermission()) return true;
    final status = await Permission.microphone.request();
    if (status.isGranted) return true;
    return _recorder.hasPermission();
  }

  Future<bool> startRecording() async {
    if (kIsWeb) return false;
    final allowed = await ensureMicPermission();
    if (!allowed) return false;

    final dir = await getTemporaryDirectory();
    _recordingPath =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _samples.clear();

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _recordingPath!,
    );

    _ampSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 120))
        .listen((amp) {
      final normalized = ((amp.current + 45) / 45).clamp(0.12, 1.0);
      _samples.add(normalized);
    });

    return true;
  }

  List<double> _normalizeWaveform(List<double> raw) {
    if (raw.isEmpty) {
      return List.generate(28, (i) => 0.25 + (i % 4) * 0.1);
    }
    const target = 28;
    if (raw.length == target) return raw;
    if (raw.length < target) {
      return List.generate(target, (i) {
        final src = (i / target * raw.length).floor().clamp(0, raw.length - 1);
        return raw[src];
      });
    }
    final step = raw.length / target;
    return List.generate(target, (i) {
      final idx = (i * step).floor().clamp(0, raw.length - 1);
      return raw[idx];
    });
  }

  Future<VoiceRecordingResult?> stopRecording() async {
    if (kIsWeb) return null;
    await _ampSub?.cancel();
    _ampSub = null;

    final path = await _recorder.stop();
    final filePath = path ?? _recordingPath;
    if (filePath == null || filePath.isEmpty) return null;

    if (!chatLocalFileExists(filePath)) return null;

    final probe = AudioPlayer();
    await probe.setSource(DeviceFileSource(filePath));
    final duration = await probe.getDuration();
    await probe.dispose();

    final seconds = (duration?.inMilliseconds ?? 0) / 1000.0;
    if (seconds < 0.5) {
      chatDeleteLocalFile(filePath);
      return null;
    }

    return VoiceRecordingResult(
      path: filePath,
      durationSeconds: seconds,
      waveform: _normalizeWaveform(_samples),
    );
  }

  Future<void> cancelRecording() async {
    if (kIsWeb) return;
    await _ampSub?.cancel();
    _ampSub = null;
    try {
      await _recorder.stop();
    } catch (_) {}
    if (_recordingPath != null) {
      chatDeleteLocalFile(_recordingPath);
    }
    _recordingPath = null;
    _samples.clear();
  }

  Future<void> togglePlayback({
    required String messageId,
    required String path,
    required void Function(bool playing) onStateChanged,
  }) async {
    if (kIsWeb || !chatLocalFileExists(path)) {
      onStateChanged(false);
      return;
    }

    if (_playingId == messageId) {
      await _player.stop();
      _playingId = null;
      onStateChanged(false);
      return;
    }

    await _player.stop();
    _playingId = messageId;
    onStateChanged(true);

    await _player.play(DeviceFileSource(path));
    _player.onPlayerComplete.first.then((_) {
      if (_playingId == messageId) {
        _playingId = null;
        onStateChanged(false);
      }
    });
  }

  Future<void> stopPlayback() async {
    await _player.stop();
    _playingId = null;
  }

  void dispose() {
    _ampSub?.cancel();
    _recorder.dispose();
    _player.dispose();
  }
}
