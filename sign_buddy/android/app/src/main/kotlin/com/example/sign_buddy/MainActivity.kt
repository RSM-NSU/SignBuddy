package com.example.sign_buddy

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MediaPipeChannel(
            context = this,
            flutterEngine = flutterEngine
        )
    }
}