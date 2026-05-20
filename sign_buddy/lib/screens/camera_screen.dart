import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:sign_buddy/lib/database/db_helper.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:sign_buddy/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sign_buddy/services/landmark_service.dart';
import 'package:sign_buddy/services/label_encoder_service.dart';

enum DetectionMode { alphabet, word }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool isDark = AppState.isDark.value;
  static final lightColor = AppState.lightColor;
  static final darkColor  = AppState.darkColor;

  CameraController?        _cameraController;
  List<CameraDescription>? _cameras;

  Interpreter? _alphabetInterpreter;
  Interpreter? _wordInterpreter;

  Interpreter? get _interpreter =>
      _detectionMode == DetectionMode.alphabet
          ? _alphabetInterpreter
          : _wordInterpreter;

  final LabelEncoderService _alphabetLabelEncoder = LabelEncoderService();
  final LabelEncoderService _wordLabelEncoder     = LabelEncoderService();

  LabelEncoderService get _labelEncoder =>
      _detectionMode == DetectionMode.alphabet
          ? _alphabetLabelEncoder
          : _wordLabelEncoder;

  DetectionMode _detectionMode = DetectionMode.alphabet;

  bool   isCameraReady     = false;
  bool   isProcessingFrame = false;
  bool   hasError          = false;

  DatabaseHelper dbHelper = DatabaseHelper();

  String predictionLabel = "Initializing...";
  double confidence      = 0.0;
  String errorMessage    = "";
  String detectedText    = "";

  bool     isLastWasSpace = false;
  String   lastPrediction = "";
  DateTime lastAddedTime  = DateTime.now();

  int      _frameCount      = 0;
  static const int _frameSkip = 3;
  DateTime _lastProcessTime = DateTime.now();

  static const List<String> _wordLabels = [
    "AXE1", "BACKPACK1", "BASKETBALL1", "BEE1", "BELT1", "BITE1",
    "BREAKFAST1", "CHRISTMAS1", "DARK1", "DEAF1", "DECIDE1", "DEMAND1",
    "DEVELOP1", "DOG1", "EDIT1", "ELEVATOR1", "FINE1", "FLOAT1",
    "HALLOWEEN1", "HURDLE/TRIP1", "LUNCH1", "MEAT1", "MECHANIC1",
    "NOON1", "PARTY1", "PATIENT2", "RIVER1", "ROCKINGCHAIR1",
    "SHAVE1", "WHATFOR1"
  ];

  @override
  void initState() {
    super.initState();
    dbHelper.createDatabase();
    _init();
  }

  Future<void> _init() async {
    try {
      await _alphabetLabelEncoder.loadFromIndexMap();
    } catch (e) {
      debugPrint("Alphabet label load failed: $e");
      setState(() {
        hasError     = true;
        errorMessage = "labels.json missing or invalid";
      });
      return;
    }
    _wordLabelEncoder.loadFromList(_wordLabels);
    await initCameraAndModel();
  }

  Future<void> initCameraAndModel() async {
    setState(() { predictionLabel = "Getting cameras..."; });

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          hasError        = true;
          errorMessage    = "No cameras found on this device";
          predictionLabel = errorMessage;
        });
        return;
      }
    } catch (e) {
      setState(() {
        hasError        = true;
        errorMessage    = "Camera access denied or unavailable";
        predictionLabel = errorMessage;
      });
      return;
    }

    setState(() { predictionLabel = "Initializing camera..."; });

    try {
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        isCameraReady   = true;
        predictionLabel = "Camera ready! Loading models...";
      });
    } catch (e) {
      setState(() {
        hasError        = true;
        errorMessage    = "Failed to initialize camera: ${e.toString()}";
        predictionLabel = errorMessage;
      });
      return;
    }

    try {
      _alphabetInterpreter = await Interpreter.fromAsset(
        'assets/models/sign_buddy_model.tflite',
      );
      debugPrint("Alphabet model loaded ✓");
    } catch (e) {
      debugPrint("Alphabet model load failed: $e");
    }

    try {
      _wordInterpreter = await Interpreter.fromAsset(
        'assets/models/asl_alphabet_model.tflite',
      );
      debugPrint("Word model loaded ✓");
    } catch (e) {
      debugPrint("Word model load failed: $e");
    }

    if (!mounted) return;
    setState(() { predictionLabel = "Ready! Tap Start to begin"; });
  }

  void _onToggleMode(bool isWordMode) async {
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
    }
    setState(() {
      _detectionMode  = isWordMode ? DetectionMode.word : DetectionMode.alphabet;
      detectedText    = "";
      predictionLabel = _detectionMode == DetectionMode.alphabet
          ? "ASL Alphabet mode — Tap Start"
          : "Word Level mode — Tap Start";
      lastPrediction  = "";
      isLastWasSpace  = false;
    });
  }

  void startDetection() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (_interpreter == null) {
      setState(() { predictionLabel = "Model not loaded yet. Please wait."; });
      return;
    }
    setState(() { predictionLabel = "Running detection..."; });
    try {
      _cameraController!.startImageStream(_onCameraFrame);
    } catch (e) {
      setState(() { predictionLabel = "Failed to start: $e"; });
    }
  }

  void _onCameraFrame(CameraImage image) {
    _frameCount++;
    if (_frameCount % _frameSkip != 0) return;
    if (isProcessingFrame || _interpreter == null) return;

    final now = DateTime.now();
    if (now.difference(_lastProcessTime).inMilliseconds < 100) return;
    _lastProcessTime  = now;
    isProcessingFrame = true;

    Future.microtask(() async {
      if (!mounted) { isProcessingFrame = false; return; }
      try {
        final landmarks = await LandmarkService.extractLandmarks(image);

        if (landmarks == null) {
          setState(() { predictionLabel = "No hand detected"; confidence = 0.0; });
          return;
        }

        final input       = [landmarks];
        final outputShape = _interpreter!.getOutputTensor(0).shape;
        final numClasses  = outputShape[1];
        final output      = List.filled(numClasses, 0.0).reshape([1, numClasses]);

        _interpreter!.run(input, output);

        final predictions   = output[0] as List<double>;
        final maxIndex      = predictions.indexOf(predictions.reduce(max));
        final maxConfidence = predictions[maxIndex];
        final newPrediction = _labelEncoder.decode(maxIndex);

        if (mounted) {
          setState(() {
            predictionLabel = newPrediction;
            confidence      = maxConfidence;
          });
          if (_detectionMode == DetectionMode.word) {
            _handleWordPrediction(newPrediction, maxConfidence);
          } else {
            _handleAlphabetPrediction(newPrediction, maxConfidence);
          }
        }
      } catch (e) {
        debugPrint('Inference error: $e');
      } finally {
        isProcessingFrame = false;
      }
    });
  }

  void _handleAlphabetPrediction(String newPrediction, double maxConfidence) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if ((maxConfidence > 0.7 &&
        newPrediction != "NOTHING" &&
        newPrediction != "SPACE") ||
        newPrediction == "NOTHING" ||
        newPrediction == "SPACE") {
      final now = DateTime.now();
      if (newPrediction == lastPrediction &&
          now.difference(lastAddedTime).inMilliseconds < 800) return;
      lastPrediction = newPrediction;
      lastAddedTime  = now;
      if (newPrediction == "DEL") {
        if (detectedText.isNotEmpty) {
          detectedText = detectedText.substring(0, detectedText.length - 1);
        }
        isLastWasSpace = false;
      } else if (newPrediction == "SPACE") {
        if (!isLastWasSpace && detectedText.isNotEmpty) {
          detectedText  += " ";
          isLastWasSpace = true;
        }
      } else if (newPrediction == "NOTHING") {
        return;
      } else {
        detectedText   += newPrediction;
        isLastWasSpace  = false;
      }
      setState(() {});
    }
  }

  void _handleWordPrediction(String newPrediction, double maxConfidence) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (maxConfidence < 0.7) return;
    final now = DateTime.now();
    if (newPrediction == lastPrediction &&
        now.difference(lastAddedTime).inMilliseconds < 1500) return;
    lastPrediction = newPrediction;
    lastAddedTime  = now;
    final cleanWord = newPrediction.replaceAll(RegExp(r'\d+$'), '');
    setState(() {
      detectedText = detectedText.isEmpty ? cleanWord : "$detectedText $cleanWord";
    });
  }

  void stopDetection() async {
    try {
      if (_cameraController != null &&
          _cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
    } catch (e) {
      debugPrint('Stop stream error: $e');
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && detectedText.trim().isNotEmpty) {
      await dbHelper.insertHistory(
        user.uid,
        detectedText,
        DateTime.now().toIso8601String(),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _alphabetInterpreter?.close();
    _wordInterpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWordMode = _detectionMode == DetectionMode.word;

    return Scaffold(
      backgroundColor: isDark ? darkColor : lightColor,

      appBar: AppBar(
        backgroundColor: isDark ? darkColor : lightColor,
        foregroundColor: isDark ? lightColor : darkColor,
        title: Text(
          "Sign Language Translator",
          style: TextStyle(color: isDark ? lightColor : darkColor),
        ),
        actions: [
          // ── TOGGLE: ABC / Word ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ABC",
                style: TextStyle(
                  color: !isWordMode ? Colors.blue : (isDark ? lightColor : darkColor),
                  fontWeight: !isWordMode ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Switch(
                value: isWordMode,
                onChanged: _onToggleMode,
                activeColor:        Colors.blue,
                inactiveThumbColor: Colors.blue,
                activeTrackColor:   Colors.blue.withOpacity(0.4),
                inactiveTrackColor: Colors.blue.withOpacity(0.4),
              ),
              const SizedBox(width: 4),
              Text(
                "Word",
                style: TextStyle(
                  color: isWordMode ? Colors.blue : (isDark ? lightColor : darkColor),
                  fontWeight: isWordMode ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),

      body: SafeArea(
        child: hasError

        // ── ERROR ──
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 60),
              const SizedBox(height: 10),
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: initCameraAndModel,
                child: const Text("Retry"),
              ),
            ],
          ),
        )

            : !isCameraReady

        // ── LOADING ──
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: isDark ? lightColor : darkColor,
              ),
              const SizedBox(height: 15),
              Text(
                predictionLabel,
                style: TextStyle(
                    color: isDark ? lightColor : darkColor),
              ),
            ],
          ),
        )

        // ── MAIN ──
            : Column(
          children: [

            // MODE BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: isWordMode
                  ? Colors.green.withOpacity(0.15)
                  : Colors.blue.withOpacity(0.15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isWordMode ? Icons.text_fields : Icons.abc,
                    size: 18,
                    color: isWordMode ? Colors.green : Colors.blue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isWordMode ? "Word Level Mode" : "ASL Alphabet Mode",
                    style: TextStyle(
                      color: isWordMode ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // CAMERA AREA
            Expanded(
              flex: 62,
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: CameraPreview(_cameraController!),
                  ),

                  // Confidence overlay
                  Positioned(
                    bottom: 18,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.black26,
                      child: Text(
                        "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),

                  // LIVE / IDLE badge
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isProcessingFrame
                            ? Colors.green
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isProcessingFrame ? "LIVE" : "IDLE",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // BOTTOM PANEL
            Expanded(
              flex: 38,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                color: isDark ? darkColor : lightColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    const SizedBox(height: 6),

                    // Detected text box
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isDark ? lightColor : darkColor,
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            detectedText.trim().isEmpty
                                ? predictionLabel
                                : detectedText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? darkColor : lightColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        ElevatedButton(
                          onPressed: startDetection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? lightColor : darkColor,
                            foregroundColor: isDark ? darkColor : lightColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 12),
                          ),
                          child: const Text("Start"),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            setState(() { detectedText = ""; });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? lightColor : darkColor,
                            foregroundColor: isDark ? darkColor : lightColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text("CLEAR"),
                        ),

                        ElevatedButton(
                          onPressed: stopDetection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? lightColor : darkColor,
                            foregroundColor: isDark ? darkColor : lightColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text("STOP"),
                        ),

                      ],
                    ),

                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}