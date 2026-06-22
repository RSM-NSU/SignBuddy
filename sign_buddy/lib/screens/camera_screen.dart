import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sign_buddy/lib/database/db_helper.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:sign_buddy/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sign_buddy/services/landmark_service.dart';
import 'package:sign_buddy/services/label_encoder_service.dart';
import 'package:sign_buddy/services/llm_service.dart';

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
  final LlmService _llm = LlmService();
  bool _isProcessingLLM = false;

  // ── TTS (ADDED) ──
  final FlutterTts _flutterTts = FlutterTts();

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
  bool _isCooldown = false;

  static const int cooldownMs = 2000; // 2 seconds

  int      _frameCount      = 0;
  static const int _frameSkip = 5;
  DateTime _lastProcessTime = DateTime.now();

  // ── WORD MODEL FRAME BUFFER (ADDED) ──
  static const int _wordSequenceLength = 32;
  final List<List<double>> _frameBuffer = [];

  static const List<String> _wordLabels = [
    "5DOLLARS", "8HOUR", "ADDRESS", "ADVERTISE", "ALLOFSUDDEN", "ANYONE",
    "APPLE", "ARTICULATESIGN", "ASSEMBLY", "AUTISM1", "AXE1", "BABY2",
    "BACKOUT", "BACKPACK1", "BANDAGE", "BASEBALLCAP", "BASKET1", "BASKETBALL1",
    "BATTERY", "BEARD", "BED2", "BEE1", "BELIEVE1", "BELT1", "BISON",
    "BITE1", "BOTTLE", "BRAINSTORM", "BREAKFAST1", "BUBBLES", "BUCKLE1",
    "CAKE", "CALENDAR1", "CANCER1", "CAPTURE", "CARDS", "CARVE", "CAT3",
    "CATAPULT", "CATCH2", "CEMETERY", "CHEEK", "CHEER", "CHEESEGRATER",
    "CHEW1", "CHRISTMAS1", "CLOCK2", "CLOSE", "COMB2", "CONFUSED1", "COPY",
    "CORKSCREW1", "CROSS2", "CURTSEY1", "DARK1", "DAY", "DEAF1", "DECIDE1",
    "DECORATE2", "DEMAND1", "DEVELOP1", "DINNER1", "DOG1", "DOWNLOAD",
    "DOWNSIZE1", "DRAG1", "DRILL", "DROWN5", "DUCK2", "EACH", "EASY",
    "EAT1", "EDIT1", "EITHER", "ELEVATOR1", "EMPTY2", "ENOUGH", "ERUPT2",
    "FAIL", "FASCINATED", "FAST", "FEED1", "FILTER", "FINE1", "FLASHLIGHT4",
    "FLIP", "FLOAT1", "FOLLOW1", "FOND", "FOOL", "FOREIGNER1", "FRACTION",
    "GETINBED", "GLASS3", "GOODYGOODYSHOEOPPOSITE", "GRAMMAR", "GRENADE",
    "GUESS1", "GUN2", "HAIRDRYER2", "HALLOWEEN1", "HARDOFHEARING",
    "HELICOPTER2", "HELMET1", "HONOR", "HOPE", "HOSPITAL1", "HOW1",
    "HURDLE/TRIP1", "IMAGINE2", "IMPOSSIBLE", "INEPT", "INTRODUCE",
    "INTUITIVE", "ITALY", "JACKET3", "JEWELRY", "JEWISH", "JOKE", "JUMP",
    "KICK2", "KNIGHT1", "LATER", "LETTUCE1", "LICKENVELOPE2", "LOAD2",
    "LOCK1", "LOCK3", "LONGLINE", "LOSE", "LUNCH1", "MAGNET4", "MAGNIFY2",
    "MAIL1", "MAPLE", "MEACULPA", "MEAT1", "MECHANIC1", "MEDITATE3",
    "METAL", "METAPHOR", "MICROSCOPE1", "MICROSCOPE2", "MILK2", "MOUTH",
    "MOVIE1", "MYSELF", "NAILCLIPPER", "NIGHT1", "NOON1", "NOTINTERESTED",
    "OCTOPUS", "OFFEND", "OPENBOOK", "OTHER", "PARTY1", "PATIENT2", "PECK",
    "PEEKABOO", "PEG2", "PEG3", "PENNY", "PICK", "PIPE2", "POLICEMAN2",
    "PONDER", "POP3", "POP4", "PRESS", "PRICE", "PULLCONVINCE", "RABBIT2",
    "RAZOR2", "RECENT1", "REGULAR", "RESEARCH1", "RHINO2", "RHINO3",
    "RIGHT3", "RIVER1", "ROAST", "ROCKINGCHAIR1", "RUSSIA", "SAIL2",
    "SAMESAME", "SCARF2", "SCOOP", "SCREWDRIVER3", "SCROLLDOWN", "SCULPTURE",
    "SERVE1", "SHARK1", "SHARPEN2", "SHAVE1", "SHAVE3", "SHINY", "SHOCKED",
    "SINCE", "SINK", "SKATEBOARDING3", "SKI", "SLICE1", "SLIDE2",
    "SNOWBOARD", "SOCCER2", "SOCIETY", "SOMERSAULT1", "SOMERSAULT3",
    "SPECIAL1", "SPILL2", "SQUEEZE", "STACK4", "STAMP3", "STETHOSCOPE2",
    "STOP", "STRAIN1", "SUPERIOR", "SWEATER2", "SWEATPANTS", "SWEATSHIRT",
    "TAIL1", "TEACH1", "THEY1", "THINK", "THIRD1", "TICKLE", "TIEUP2",
    "TOMATO", "TRACTOR", "TRIANGLE", "TRIP1", "TWINS1", "TYPE1", "UNCLE",
    "UNDERGRADUATE", "UNDERWEAR1", "VIEW", "VLOG", "VOICE", "VOMIT",
    "WALK-TIGHTROPE-CL", "WANT1", "WASHMACHINE", "WHATFOR1", "WHILE",
    "WHISTLE2", "WHOLE", "WINDMILL3", "WRISTWATCH3", "ZEBRA"
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
        'assets/models/asl_250_unrolled.tflite',
      );
      debugPrint("Word model loaded ✓");
    } catch (e) {
      debugPrint("Word model load failed: $e");
    }

    if (!mounted) return;
    setState(() { predictionLabel = "Ready! Tap Start to begin"; });
  }
  void _onToggleMode(
      bool isWordMode,
      ) async {

    // Stop old speech
    await _flutterTts.stop();


    await _flutterTts.setLanguage(
      "en-US",
    );

    await _flutterTts.setEngine(
      "com.google.android.tts",
    );

    await _flutterTts.setSpeechRate(
      0.35,
    );

    await _flutterTts.setPitch(
      0.85,
    );

    await _flutterTts.setVolume(
      1.0,
    );

    if (_cameraController != null &&
        _cameraController!
            .value
            .isStreamingImages) {

      await _cameraController!
          .stopImageStream();
    }

    setState(() {

      _detectionMode =
      isWordMode
          ? DetectionMode.word
          : DetectionMode.alphabet;

      detectedText = "";

      predictionLabel =
      _detectionMode ==
          DetectionMode.alphabet
          ? "ASL Alphabet mode — Tap Start"
          : "Word Level mode — Tap Start";

      lastPrediction = "";

      isLastWasSpace = false;
    });

    // ── CLEAR FRAME BUFFER ON MODE SWITCH (ADDED) ──
    _frameBuffer.clear();

    // SPEAK MODE CHANGE

    if (isWordMode) {

      await _flutterTts.speak(
        "Word level model activated",
      );

    } else {

      await _flutterTts.speak(
        "Alphabet model activated",
      );
    }
  }

  void startDetection() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (_interpreter == null) {
      setState(() { predictionLabel = "Model not loaded yet. Please wait."; });
      return;
    }
    setState(() { predictionLabel = "Running detection..."; });
    try {
      _cameraController!.startImageStream(_giFrame);
    } catch (e) {
      setState(() { predictionLabel = "Failed to start: $e"; });
    }
  }

  void _onCameraFrame(CameraImage image) {
    _frameCount++;
    if (_frameCount % _frameSkip != 0) return;
    if (isProcessingFrame || _interpreter == null) return;

    final now = DateTime.now();
    if (now.difference(_lastProcessTime).inMilliseconds < 150) return;
    _lastProcessTime  = now;
    isProcessingFrame = true;

    Future.microtask(() async {
      if (!mounted) { isProcessingFrame = false; return; }
      try {

        // ── WORD MODE ──────────────────────────────────────────────────────────
        if (_detectionMode == DetectionMode.word) {
          final rawLandmarks = await LandmarkService.extractRawLandmarks(image);

          if (rawLandmarks == null) {
            setState(() { predictionLabel = "No hand detected"; confidence = 0.0; });
            return;
          }

          // Training layout: [left hand 0-62, right hand 63-125]
          // We treat the detected hand as right (dominant hand)
          final frame126 = List<double>.filled(126, 0.0);
          for (int i = 0; i < 63; i++) {
            frame126[63 + i] = rawLandmarks[i];
          }

          // Training normalization: subtract wrist (landmark 0) from each hand
          // Left hand is all zeros → no change needed
          // Right hand: subtract slots [63,64,65] (wrist x,y,z) from all 21 landmarks
          final rwx = frame126[63];
          final rwy = frame126[64];
          final rwz = frame126[65];
          for (int i = 0; i < 21; i++) {
            frame126[63 + i * 3]     -= rwx;
            frame126[63 + i * 3 + 1] -= rwy;
            frame126[63 + i * 3 + 2] -= rwz;
          }

          _frameBuffer.add(frame126);
          if (_frameBuffer.length > _wordSequenceLength) {
            _frameBuffer.removeAt(0);
          }

          if (_frameBuffer.length < _wordSequenceLength) {
            setState(() {
              predictionLabel = "Buffering... ${_frameBuffer.length}/$_wordSequenceLength";
            });
            return;
          }

          // add_velocity: concatenate [raw(126), frame_delta(126)] = 252 per frame
          // vel[0] = zeros (no previous frame), vel[i] = frame[i] - frame[i-1]
          final List<List<double>> input252 = List.generate(_wordSequenceLength, (i) {
            final vel = i == 0
                ? List<double>.filled(126, 0.0)
                : List.generate(126, (j) => _frameBuffer[i][j] - _frameBuffer[i - 1][j]);
            return [..._frameBuffer[i], ...vel]; // 252 features
          });

          final wordInput      = [input252]; // shape: [1, 32, 252] ✓
          final wordOutShape   = _interpreter!.getOutputTensor(0).shape;
          final wordNumClasses = wordOutShape[1];
          final wordOutput     = [List<double>.filled(wordNumClasses, 0.0)];

          _interpreter!.run(wordInput, wordOutput);

          final wordPredictions   = wordOutput[0];
          final wordMaxIndex      = wordPredictions.indexOf(wordPredictions.reduce(max));
          final wordMaxConfidence = wordPredictions[wordMaxIndex];
          final wordNewPrediction = _labelEncoder.decode(wordMaxIndex);

          if (mounted) {
            setState(() {
              predictionLabel = wordNewPrediction;
              confidence      = wordMaxConfidence;
            });
            _handleWordPrediction(wordNewPrediction, wordMaxConfidence);
          }
          return;
        }

        // ── ALPHABET MODE (completely unchanged) ───────────────────────────────
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
          _handleAlphabetPrediction(newPrediction, maxConfidence);
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
      if (_isCooldown) return;

      if (newPrediction == lastPrediction &&
          now.difference(lastAddedTime).inMilliseconds < cooldownMs) return;
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

      _isCooldown = true;

      Future.delayed(
        const Duration(milliseconds: cooldownMs),
            () {
          _isCooldown = false;
        },
      );    }
  }

  void _handleWordPrediction(String newPrediction, double maxConfidence) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (maxConfidence < 0.45) return;
    final now = DateTime.now();
    if (_isCooldown) return;

    if (newPrediction == lastPrediction &&
        now.difference(lastAddedTime).inMilliseconds < cooldownMs) return;
    lastPrediction = newPrediction;
    lastAddedTime  = now;
    final cleanWord = newPrediction.replaceAll(RegExp(r'\d+$'), '');
    setState(() {
      detectedText = detectedText.isEmpty
          ? cleanWord
          : "$detectedText $cleanWord";
    });

    _isCooldown = true;

    Future.delayed(
      const Duration(milliseconds: cooldownMs),
          () {
        _isCooldown = false;
      },
    );
  }

  void stopDetection() async {
    // ── CLEAR FRAME BUFFER ON STOP (ADDED) ──
    _frameBuffer.clear();

    try {
      if (_cameraController != null &&
          _cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
    } catch (e) {
      debugPrint('Stop stream error: $e');
    }

    if (detectedText.trim().isNotEmpty) {
      setState(() {
        _isProcessingLLM = true;
      });
      final cleaned = await _llm.processTranslation(detectedText.trim());

      setState(() {
        detectedText     = cleaned;
        _isProcessingLLM = false;
      });

      // ── AUTO SPEAK after LLM done (ADDED) ──
      _speak();
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

  // ── SPEAK HELPER (ADDED) ──
  Future<void> _speak() async {
    if (detectedText.trim().isEmpty) return;

    await _flutterTts.stop();

    await _flutterTts.setLanguage("en-US");

    await _flutterTts.setEngine(
      "com.google.android.tts",
    );

    await _flutterTts.setSpeechRate(
      0.3,
    );

    await _flutterTts.setPitch(
      0.90,
    );

    await _flutterTts.setVolume(
      1.0,
    );

    await _flutterTts.awaitSpeakCompletion(true);

    await _flutterTts.speak(
      detectedText.trim(),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _alphabetInterpreter?.close();
    _wordInterpreter?.close();
    _flutterTts.stop(); // TTS CLEANUP aded
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
                        child: _isProcessingLLM
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: isDark ? darkColor : lightColor,
                              ),
                              const SizedBox(height: 0),
                              Text(
                                "Processing...",
                                style: TextStyle(
                                  color: isDark ? darkColor : lightColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                            : SingleChildScrollView(
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
                    Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: 8,
                      runSpacing: 8,
                      children: [

                        ElevatedButton(
                          onPressed: startDetection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? lightColor : darkColor,
                            foregroundColor: isDark ? darkColor : lightColor,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          child: const Text("Start"),
                        ),

                        ElevatedButton(
                          onPressed: () { setState(() { detectedText = ""; }); },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? lightColor : darkColor,
                            foregroundColor: isDark ? darkColor : lightColor,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          child: const Text("Clear"),
                        ),

                        ElevatedButton.icon(
                          onPressed: _isProcessingLLM ? null : _speak,
                          icon: const Icon(Icons.volume_up, size: 18),
                          label: const Text("Speak"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? lightColor : darkColor,
                            foregroundColor: isDark ? darkColor : lightColor,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),

                        ElevatedButton(
                          onPressed: _isProcessingLLM ? null : stopDetection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? lightColor : darkColor,
                            foregroundColor: isDark ? darkColor : lightColor,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          child: const Text("Stop"),
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