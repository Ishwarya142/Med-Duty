import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class CallMediaController extends ChangeNotifier {
  // ── Camera State ──────────────────────────────────────────────────────────
  List<CameraDescription> _availableCameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraLoading = false;
  bool _isFrontCamera = true;
  bool _cameraActive = true;
  String? _cameraError;

  // ── Audio / Microphone State ──────────────────────────────────────────────
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Amplitude>? _ampSubscription;
  Timer? _mockWaveTimer;
  bool _isMuted = false;
  bool _isMonitoringAudio = false;
  bool _isRecordingCall = false;
  String? _currentRecordingPath;

  double _currentAmplitude = 0.0; // 0.0 to 1.0
  List<double> _liveBars = [0.2, 0.35, 0.5, 0.7, 0.45, 0.3, 0.18];

  // Getters
  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized && _cameraController != null && _cameraController!.value.isInitialized;
  bool get isCameraLoading => _isCameraLoading;
  bool get isFrontCamera => _isFrontCamera;
  bool get cameraActive => _cameraActive;
  String? get cameraError => _cameraError;

  bool get isMuted => _isMuted;
  bool get isMonitoringAudio => _isMonitoringAudio;
  bool get isRecordingCall => _isRecordingCall;
  String? get currentRecordingPath => _currentRecordingPath;
  double get currentAmplitude => _currentAmplitude;
  List<double> get liveBars => List.unmodifiable(_liveBars);

  // ── Initialization ────────────────────────────────────────────────────────
  Future<void> initialize({bool withCamera = true, bool withAudio = true}) async {
    if (withCamera) {
      await initializeCamera();
    }
    if (withAudio) {
      await startAudioMonitoring();
    }
  }

  // ── Camera Methods ────────────────────────────────────────────────────────
  Future<void> initializeCamera() async {
    if (_isCameraLoading) return;
    _isCameraLoading = true;
    _cameraError = null;
    notifyListeners();

    try {
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted && !status.isLimited) {
          _cameraError = 'Camera permission was not granted.';
          _isCameraLoading = false;
          notifyListeners();
          return;
        }
      }

      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        _cameraError = 'No camera found on this device.';
        _isCameraLoading = false;
        notifyListeners();
        return;
      }

      final camera = _selectCamera(_isFrontCamera);
      await _initControllerWith(camera);
    } catch (e) {
      debugPrint('[CallMediaController] Camera initialization failed: $e');
      _cameraError = 'Failed to open camera: ${e.toString()}';
      _isCameraInitialized = false;
    } finally {
      _isCameraLoading = false;
      notifyListeners();
    }
  }

  CameraDescription _selectCamera(bool preferFront) {
    if (_availableCameras.isEmpty) throw StateError('No cameras available');
    final direction = preferFront ? CameraLensDirection.front : CameraLensDirection.back;
    final match = _availableCameras.where((c) => c.lensDirection == direction);
    if (match.isNotEmpty) return match.first;
    return _availableCameras.first;
  }

  Future<void> _initControllerWith(CameraDescription description) async {
    // Dispose old controller if any
    final oldController = _cameraController;
    if (oldController != null) {
      _cameraController = null;
      _isCameraInitialized = false;
      await oldController.dispose();
    }

    final newController = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false, // We monitor audio through AudioRecorder
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await newController.initialize();
      _cameraController = newController;
      _isCameraInitialized = true;
      _cameraError = null;
    } catch (e) {
      _cameraError = 'Could not start camera feed';
      _isCameraInitialized = false;
      await newController.dispose();
    }
    notifyListeners();
  }

  Future<void> switchCamera() async {
    if (_availableCameras.length < 2 || _isCameraLoading) return;
    _isFrontCamera = !_isFrontCamera;
    _isCameraLoading = true;
    notifyListeners();

    try {
      final camera = _selectCamera(_isFrontCamera);
      await _initControllerWith(camera);
    } catch (e) {
      debugPrint('[CallMediaController] Failed to switch camera: $e');
    } finally {
      _isCameraLoading = false;
      notifyListeners();
    }
  }

  void toggleCamera(bool active) {
    _cameraActive = active;
    notifyListeners();
  }

  // ── Audio / Mic Monitoring Methods ────────────────────────────────────────
  Future<void> startAudioMonitoring() async {
    if (_isMonitoringAudio) return;

    try {
      if (!kIsWeb) {
        final micStatus = await Permission.microphone.request();
        if (!micStatus.isGranted && !micStatus.isLimited) {
          debugPrint('[CallMediaController] Microphone permission denied');
          _startFallbackWaveform();
          return;
        }
      }

      final hasPerm = await _audioRecorder.hasPermission();
      if (!hasPerm) {
        debugPrint('[CallMediaController] Recorder permission denied');
        _startFallbackWaveform();
        return;
      }

      // Start recording to a live stream or buffer to monitor amplitude
      String path = '';
      if (!kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        path = '${tempDir.path}/live_call_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _isMonitoringAudio = true;

      // Listen to real-time audio amplitude
      _ampSubscription = _audioRecorder
          .onAmplitudeChanged(const Duration(milliseconds: 60))
          .listen((amp) {
        if (_isMuted) {
          _currentAmplitude = 0.0;
          _liveBars = List.filled(7, 0.12);
        } else {
          // amp.current ranges from roughly -50 dB (quiet) to 0 dB (loud)
          final normalized = ((amp.current + 48) / 48).clamp(0.08, 1.0);
          _currentAmplitude = normalized;
          _updateWaveformBars(normalized);
        }
        notifyListeners();
      });
    } catch (e) {
      debugPrint('[CallMediaController] Mic monitoring setup: $e');
      _startFallbackWaveform();
    }
    notifyListeners();
  }

  void _updateWaveformBars(double energy) {
    final rand = Random();
    final baseMultipliers = [0.35, 0.6, 0.85, 1.0, 0.75, 0.5, 0.3];
    _liveBars = List.generate(7, (i) {
      final jitter = (rand.nextDouble() * 0.3) - 0.15;
      final val = (energy * baseMultipliers[i] + jitter).clamp(0.1, 1.0);
      return val;
    });
  }

  void _startFallbackWaveform() {
    _isMonitoringAudio = true;
    _mockWaveTimer?.cancel();
    _mockWaveTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_isMuted) {
        _currentAmplitude = 0.0;
        _liveBars = List.filled(7, 0.1);
      } else {
        final rand = Random();
        final pulse = 0.25 + 0.35 * sin(DateTime.now().millisecondsSinceEpoch / 250).abs();
        _currentAmplitude = pulse;
        _liveBars = List.generate(7, (i) {
          return (pulse * (0.4 + rand.nextDouble() * 0.6)).clamp(0.12, 0.95);
        });
      }
      notifyListeners();
    });
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _currentAmplitude = 0.0;
      _liveBars = List.filled(7, 0.1);
    }
    notifyListeners();
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    if (_isMuted) {
      _currentAmplitude = 0.0;
      _liveBars = List.filled(7, 0.1);
    }
    notifyListeners();
  }

  // ── Call Recording (Clinical Voice Note) ───────────────────────────────────
  Future<String?> startClinicalRecording() async {
    if (_isRecordingCall) return null;
    try {
      final allowed = await _audioRecorder.hasPermission();
      if (!allowed) return null;

      String path = '';
      if (!kIsWeb) {
        final dir = await getTemporaryDirectory();
        path = '${dir.path}/clinical_call_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      // If we were already monitoring, stop monitoring recorder to switch to file recording
      if (_isMonitoringAudio) {
        await _ampSubscription?.cancel();
        await _audioRecorder.stop();
      }

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _isRecordingCall = true;
      _currentRecordingPath = path;

      _ampSubscription = _audioRecorder
          .onAmplitudeChanged(const Duration(milliseconds: 60))
          .listen((amp) {
        if (!_isMuted) {
          final normalized = ((amp.current + 48) / 48).clamp(0.08, 1.0);
          _currentAmplitude = normalized;
          _updateWaveformBars(normalized);
          notifyListeners();
        }
      });

      notifyListeners();
      return path;
    } catch (e) {
      debugPrint('[CallMediaController] Start recording error: $e');
      return null;
    }
  }

  Future<String?> stopClinicalRecording() async {
    if (!_isRecordingCall) return null;
    try {
      final recordedPath = await _audioRecorder.stop();
      _isRecordingCall = false;
      _currentRecordingPath = null;
      notifyListeners();

      // Resume regular audio monitoring
      startAudioMonitoring();
      return recordedPath;
    } catch (e) {
      debugPrint('[CallMediaController] Stop recording error: $e');
      _isRecordingCall = false;
      notifyListeners();
      return null;
    }
  }

  // ── Disposal ──────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _ampSubscription?.cancel();
    _mockWaveTimer?.cancel();
    try {
      _audioRecorder.dispose();
    } catch (_) {}
    try {
      _cameraController?.dispose();
    } catch (_) {}
    _cameraController = null;
    _isCameraInitialized = false;
    super.dispose();
  }
}
