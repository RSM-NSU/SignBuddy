package com.example.sign_buddy

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {

    private lateinit var mediaPipeChannel: MediaPipeChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        mediaPipeChannel = MediaPipeChannel(
            context = this,
            flutterEngine = flutterEngine
        )
    }

    override fun onDestroy() {
        mediaPipeChannel.shutdown()
        super.onDestroy()
    }
}