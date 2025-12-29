import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool isCameraReady = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );

<<<<<<< HEAD
    await _controller!.initialize();
=======
    await _controller!.initialize(); 
>>>>>>> 32b6d689484653ba9381b238060274118f3aaa31

    setState(() {
      isCameraReady = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isCameraReady
          ? CameraPreview(_controller!)
          : Center(child: CircularProgressIndicator()),
    );
  }
}