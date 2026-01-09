import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:sign_buddy/app_state.dart';

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
  static final LightColor = AppState.LightColor;
  static final DarkColor = AppState.DarkColor;
  CameraController? _cameraController;
  Interpreter? _interpreter;
  List<CameraDescription>? _cameras;

  bool isCameraReady = false;
  bool isProcessingFrame = false;
  bool hasError = false;

  static const int inputSize = 224;
  String predictionLabel = "Initializing...";
  double confidence = 0.0;
  String errorMessage = "";

  // Performance optimization
  int _frameCount = 0;
  static const int _frameSkip = 3; // Process every 3rd frame
  DateTime _lastProcessTime = DateTime.now();

  final List<String> labels = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
    'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U',
    'V', 'W', 'X', 'Y', 'Z',
    'DEL', 'SPACE', 'NOTHING'
  ];

  @override
  void initState() {
    super.initState();
    initCameraAndModel();
  }

  Future<void> initCameraAndModel() async {
    setState(() {
      predictionLabel = "Getting cameras...";
    });

    // 1️⃣ Get available cameras
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
      debugPrint("❌ Error getting cameras: $e");
      setState(() {
        hasError = true;
        errorMessage = "Camera access denied or unavailable";
        predictionLabel = errorMessage;
      });
      return;
    }

    // 2️⃣ Initialize camera controller
    setState(() {
      predictionLabel = "Initializing camera...";
    });

    try {
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.low, // ⚡ Changed to low for better performance
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        isCameraReady = true;
        predictionLabel = "Camera ready! Loading model...";
      });

      debugPrint("✅ Camera initialized successfully");
    } catch (e) {
      debugPrint("❌ Camera init failed: $e");
      setState(() {
        hasError = true;
        errorMessage = "Failed to initialize camera: ${e.toString()}";
        predictionLabel = errorMessage;
      });
      return;
    }

    // 3️⃣ Load TFLite model (optional - comment out if model not ready)
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/ccn_model.tflite',
      );

      debugPrint("✅ Model loaded successfully");
      debugPrint("Input shape: ${_interpreter!.getInputTensor(0).shape}");
      debugPrint("Output shape: ${_interpreter!.getOutputTensor(0).shape}");

      if (!mounted) return;

      setState(() {
        predictionLabel = "Ready! Tap to start detection";
      });

    } catch (e) {
      debugPrint("⚠️ Model load failed (this is OK for testing): $e");
      // Don't set hasError - we can still show camera
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

    // Start image stream only when user taps
    try {
      _cameraController!.startImageStream(_onCameraFrame);
    } catch (e) {
      debugPrint("❌ Failed to start image stream: $e");
      setState(() {
        predictionLabel = "Failed to start detection: $e";
      });
    }
  }

  void _onCameraFrame(CameraImage image) {
    // Skip frames for performance
    _frameCount++;
    if (_frameCount % _frameSkip != 0) {
      return;
    }

    if (isProcessingFrame || _interpreter == null) return;

    // Throttle processing to max 10 FPS
    final now = DateTime.now();
    if (now.difference(_lastProcessTime).inMilliseconds < 100) {
      return;
    }
    _lastProcessTime = now;

    isProcessingFrame = true;

    // Process frame asynchronously to avoid lag
    Future.microtask(() async {
      if (!mounted) {
        isProcessingFrame = false;
        return;
      }

      try {
        // Convert camera image to model input
        final input = await _preprocessCameraImage(image);

        // Get output shape from model
        final outputShape = _interpreter!.getOutputTensor(0).shape;
        final numClasses = outputShape[1];

        // Prepare output buffer
        final output = List.filled(numClasses, 0.0).reshape([1, numClasses]);

        // Run inference
        _interpreter!.run(input, output);

        // Get prediction
        final predictions = output[0] as List<double>;
        final maxIndex = predictions.indexOf(predictions.reduce(max));
        final maxConfidence = predictions[maxIndex];

        if (mounted) {
          setState(() {
            if (maxIndex < labels.length) {
              predictionLabel = labels[maxIndex];
            } else {
              predictionLabel = "Class $maxIndex";
            }
            confidence = maxConfidence;
          });
        }
      } catch (e) {
        debugPrint("Inference error: $e");
      } finally {
        isProcessingFrame = false;
      }
    });
  }

  // Convert CameraImage to model input format (OPTIMIZED)
  Future<List<List<List<List<double>>>>> _preprocessCameraImage(CameraImage image) async {
    try {
      // Convert YUV420 to RGB (optimized)
      final imgLib = _convertYUV420ToImageOptimized(image);

      // Resize to model input size
      final resized = img.copyResize(
        imgLib,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.nearest, // ⚡ Faster than linear
      );

      // Convert to normalized tensor [1, 224, 224, 3]
      final inputTensor = List.generate(
        1,
            (_) => List.generate(
          inputSize,
              (y) => List.generate(
            inputSize,
                (x) {
              final pixel = resized.getPixel(x, y);
              // Normalize to [0, 1]
              return [
                pixel.r / 255.0,
                pixel.g / 255.0,
                pixel.b / 255.0,
              ];
            },
          ),
        ),
      );

      return inputTensor;
    } catch (e) {
      debugPrint("Image preprocessing error: $e");
      return _createDummyInput();
    }
  }

  // Optimized YUV420 to RGB conversion (samples every 2nd pixel)
  img.Image _convertYUV420ToImageOptimized(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    // Sample at lower resolution for speed
    final sampleWidth = width ~/ 2;
    final sampleHeight = height ~/ 2;

    final img.Image image = img.Image(width: sampleWidth, height: sampleHeight);

    final yPlane = cameraImage.planes[0];
    final uPlane = cameraImage.planes[1];
    final vPlane = cameraImage.planes[2];

    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    // Sample every 2nd pixel for performance
    for (int y = 0; y < sampleHeight; y++) {
      for (int x = 0; x < sampleWidth; x++) {
        final srcX = x * 2;
        final srcY = y * 2;

        final yIndex = srcY * width + srcX;
        final uvIndex = (srcY ~/ 2) * uvRowStride + (srcX ~/ 2) * uvPixelStride;

        final yValue = yBuffer[yIndex];
        final uValue = uBuffer[uvIndex];
        final vValue = vBuffer[uvIndex];

        // YUV to RGB conversion
        final r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
        final g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
            .clamp(0, 255)
            .toInt();
        final b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return image;
  }

  // Keep original for fallback
  img.Image _convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final img.Image image = img.Image(width: width, height: height);

    final yPlane = cameraImage.planes[0];
    final uPlane = cameraImage.planes[1];
    final vPlane = cameraImage.planes[2];

    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * width + x;
        final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final yValue = yBuffer[yIndex];
        final uValue = uBuffer[uvIndex];
        final vValue = vBuffer[uvIndex];

        // YUV to RGB conversion
        final r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
        final g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
            .clamp(0, 255)
            .toInt();
        final b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return image;
  }

  List<List<List<List<double>>>> _createDummyInput() {
    return List.generate(
      1,
          (_) => List.generate(
        inputSize,
            (_) => List.generate(
          inputSize,
              (_) => List.generate(
            3,
                (_) => Random().nextDouble() * 2 - 1,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ?  LightColor:DarkColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: isDark ?   LightColor : DarkColor),
        title: Text("CNN Object Detection",style: TextStyle(color: isDark ?   LightColor:DarkColor),),
        backgroundColor: isDark ?DarkColor:LightColor,
        elevation: 0,
      ),
      body: hasError
          ? _buildErrorView()
          : isCameraReady
          ? _buildCameraView()
          : _buildLoadingView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ?  LightColor: DarkColor,
          ),
          const SizedBox(height: 20),
          Text(
            predictionLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  hasError = false;
                  predictionLabel = "Retrying...";
                });
                initCameraAndModel();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera preview
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(_cameraController!),
        ),

        // Prediction overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  predictionLabel.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      "Confidence: ",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${(confidence * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: confidence > 0.5
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: confidence,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    confidence > 0.5
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Start button (tap to begin detection)
        if (!isProcessingFrame && predictionLabel.contains("Tap to start"))
          Center(
            child: ElevatedButton.icon(
              onPressed: startDetection,
              icon: const Icon(Icons.play_arrow),
              label: Text("Start Detection",style: TextStyle(color: isDark ?  DarkColor:LightColor),),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ?  LightColor:DarkColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ),

        // Status indicator
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isProcessingFrame
                  ? Colors.green
                  : Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isProcessingFrame ? "LIVE" : "IDLE",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}