import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:sign_buddy/lib/database/db_helper.dart' ;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:sign_buddy/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sign_buddy/services/landmark_service.dart';
import 'package:sign_buddy/services/label_encoder_service.dart';

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
  static final darkColor = AppState.darkColor;
  CameraController? _cameraController;
  Interpreter? _interpreter;
  List<CameraDescription>? _cameras;

  bool isCameraReady = false;
  bool isProcessingFrame = false;
  bool hasError = false;

  DatabaseHelper dbHelper = DatabaseHelper();
  String lastSavedPrediction = "";

  static const int inputSize = 224;

  String predictionLabel = "Initializing...";
  double confidence = 0.0;
  String errorMessage = "";

  String detectedText = "";

  bool isLastWasSpace = false;
  String lastPrediction = "";              // last detected letter
  DateTime lastAddedTime = DateTime.now(); // time control

  int _frameCount = 0;
  static const int _frameSkip = 3; // Process every 3rd frame
  DateTime _lastProcessTime = DateTime.now();

  final LabelEncoderService _labelEncoder = LabelEncoderService();


  @override
  void initState() {
    super.initState();
    dbHelper.createDatabase();
    _labelEncoder.loadFromIndexMap().then((_)=>initCameraAndModel());
  }

  Future<void> initCameraAndModel() async {
    setState(() {
      predictionLabel = "Getting cameras...";
    });

    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          hasError = true;
          errorMessage = "No cameras found on this device";
          predictionLabel = errorMessage;
        });
        return;
      }

      debugPrint("Found ${_cameras!.length} camera(s)");
    } catch (e) {
      debugPrint(" Error getting cameras: $e");
      setState(() {
        hasError = true;
        errorMessage = "Camera access denied or unavailable";
        predictionLabel = errorMessage;
      });
      return;
    }

    setState(() {
      predictionLabel = "Initializing camera...";
    });

    try {
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      debugPrint("Camera init DONE");
      if (!mounted) return;

      setState(() {
        isCameraReady = true;
        predictionLabel = "Camera ready! Loading model...";
      });

      debugPrint(" Camera initialized successfully");
    } catch (e) {
      debugPrint(" Camera init failed: $e");
      setState(() {
        hasError = true;
        errorMessage = "Failed to initialize camera: ${e.toString()}";
        predictionLabel = errorMessage;
      });
      return;
    }

    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/ccn_model.tflite',
      );

      debugPrint(" Model loaded successfully");
      debugPrint("Input shape: ${_interpreter!.getInputTensor(0).shape}");
      debugPrint("Output shape: ${_interpreter!.getOutputTensor(0).shape}");

      if (!mounted) return;

      setState(() {
        predictionLabel = "Ready! Tap to start detection";
      });

    } catch (e) {
      debugPrint(" Model load failed (this is OK for testing): $e");
      setState(() {
        predictionLabel = "Camera ready (no model loaded)";
      });
    }
  }

  void startDetection() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      predictionLabel = "Running detection...";
    });

    try {
      _cameraController!.startImageStream(_onCameraFrame);
    } catch (e) {
      debugPrint(" Failed to start image stream: $e");
      setState(() {
        predictionLabel = "Failed to start detection: $e";
      });
    }
  }

  void _onCameraFrame(CameraImage image) {
    _frameCount++;
    if (_frameCount % _frameSkip != 0) return;
    if (isProcessingFrame || _interpreter == null) return;

    final now = DateTime.now();
    if (now.difference(_lastProcessTime).inMilliseconds < 100) return;
    _lastProcessTime = now;
    isProcessingFrame = true;

    Future.microtask(() async {
      if (!mounted) { isProcessingFrame = false; return; }

      try {
        // Get 63 landmark values from MediaPipe
        final landmarks = await LandmarkService.extractLandmarks(image);

        if (landmarks == null) {
          setState(() { predictionLabel = "No hand detected"; confidence = 0.0; });
          return;
        }

        // Input shape is now [1, 63] — not [1, 224, 224, 3]
        final input = [landmarks];

        final outputShape  = _interpreter!.getOutputTensor(0).shape;
        final numClasses   = outputShape[1];
        final output       = List.filled(numClasses, 0.0).reshape([1, numClasses]);

        _interpreter!.run(input, output);

        final predictions  = output[0] as List<double>;
        final maxIndex     = predictions.indexOf(predictions.reduce(max));
        final maxConfidence = predictions[maxIndex];
        final newPrediction = _labelEncoder.decode(maxIndex);

        if (mounted) {
          setState(() {
            predictionLabel = newPrediction;
            confidence      = maxConfidence;
          });

          // ---- everything below is unchanged from your original code ----
          final user = FirebaseAuth.instance.currentUser;
          if (user != null &&
              ((maxConfidence > 0.7 &&
                  newPrediction != "NOTHING" &&
                  newPrediction != "SPACE") ||
                  (newPrediction == "NOTHING" || newPrediction == "SPACE"))) {

            final now = DateTime.now();
            if (newPrediction == lastPrediction &&
                now.difference(lastAddedTime).inMilliseconds < 800) {return;}

            lastPrediction = newPrediction;
            lastAddedTime  = now;

            if (newPrediction == "DEL") {
              if (detectedText.isNotEmpty){
                detectedText = detectedText.substring(0, detectedText.length - 1);}
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
      } catch (e) {
        debugPrint('Inference error: $e');
      } finally {
        isProcessingFrame = false;
      }
    });
  }


  // 🔹 STOP FUNCTION
  void stopDetection() async {

    if (_cameraController != null) {
      await _cameraController!.stopImageStream();
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
    _interpreter?.close();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final availableHeight = screenHeight - appBarHeight - statusBarHeight - bottomPadding - 8;

    return Scaffold(
      backgroundColor: isDark ?  darkColor : lightColor,

      appBar: AppBar(
        backgroundColor: isDark ? darkColor : lightColor,
        foregroundColor: AppState.isDark.value ? lightColor:darkColor,
        title: Text(
          "Sign Language Translator",
          style: TextStyle(color: isDark ? lightColor : darkColor),
        ),
      ),

      body: SafeArea(
        child: hasError
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
              )
            ],
          ),
        )

            : !isCameraReady
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
                    color: isDark ?
                    lightColor : darkColor),
              ),
            ],
          ),
        )

            : Column(
          children: [

            // 🔹 CAMERA AREA
            SizedBox(
              height: availableHeight * 0.65,
              child: Stack(
                children: [

                  // CAMERA PREVIEW
                  SizedBox.expand(child: CameraPreview(_cameraController!)),

                  // RESULT area
                  Positioned(
                    bottom: 18,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.black26,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // LIVE / IDLE INDICATOR
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

            // DETECTED TEXT CONTAINER
            Container(
              width: double.infinity,
              height: availableHeight * 0.35,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? lightColor : darkColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  const SizedBox(height: 10),

                  //  FULL SENTENCE
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isDark
                            ? Colors.white.withAlpha(50)
                            : Colors.black.withAlpha(100),
                      ),
                        child: SingleChildScrollView(
                          child: Text(
                            detectedText.trim().isEmpty
                                ? "Prediction will appear here"
                                : detectedText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.black : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),



                  /// buttons stop and clear
                  // Spacer(),
                  Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      ElevatedButton(
                        onPressed: startDetection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppState.darkColor
                              : AppState.lightColor,
                          foregroundColor: isDark
                              ? AppState.lightColor
                              : AppState.darkColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 12),
                        ),
                        child: const Text("Start"),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            detectedText = "";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppState.darkColor
                              : AppState.lightColor,
                          foregroundColor: isDark
                              ? AppState.lightColor
                              : AppState.darkColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: const Text("CLEAR"),
                      ),

                      ElevatedButton(
                        onPressed: stopDetection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppState.darkColor
                              : AppState.lightColor,
                          foregroundColor: isDark
                              ? AppState.lightColor
                              : AppState.darkColor,
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

          ],
        ),
      ),
    );
  }
}