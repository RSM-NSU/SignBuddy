
package com.example.sign_buddy

import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import android.util.Log
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker.HandLandmarkerOptions
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.Delegate
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File

class MediaPipeChannel(private val context: Context, flutterEngine: FlutterEngine) {

    private var handLandmarker: HandLandmarker? = null

    init {
        try {
            context.assets.open("hand_landmarker.task")
            Log.d("MP_DEBUG", "Model FOUND")
        } catch (e: Exception) {
            Log.e("MP_DEBUG", "Model NOT FOUND")
        }

        setupLandmarker()

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "sign_buddy/mediapipe"
        ).setMethodCallHandler { call, result ->
            if (call.method == "detectLandmarks") {
                val bytes  = call.argument<ByteArray>("bytes")!!
                val width  = call.argument<Int>("width")!!
                val height = call.argument<Int>("height")!!
                result.success(processFrame(bytes, width, height))
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setupLandmarker() {
        val modelFile = File(context.cacheDir, "hand_landmarker.task")
        if (!modelFile.exists()) {
            context.assets.open("hand_landmarker.task").use { input ->
                modelFile.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
        }
        Log.d("MP_DEBUG", "Model path: ${modelFile.absolutePath}")  // fix string template too

        val options = HandLandmarkerOptions.builder()
            .setBaseOptions(
                BaseOptions.builder()
                    .setModelAssetPath(modelFile.absolutePath)  // ← THIS is the fix
                    .setDelegate(Delegate.CPU)
                    .build()
            )
            .setNumHands(1)
            .setMinHandDetectionConfidence(0.5f)
            .setRunningMode(RunningMode.IMAGE)
            .build()

        handLandmarker = HandLandmarker.createFromOptions(context, options)
    }

    private fun processFrame(bytes: ByteArray, width: Int, height: Int): List<Double>? {
        val yuvImage = YuvImage(bytes, ImageFormat.NV21, width, height, null)
        val out = ByteArrayOutputStream()
        yuvImage.compressToJpeg(Rect(0, 0, width, height), 80, out)
        val bitmap = BitmapFactory.decodeByteArray(out.toByteArray(), 0, out.size())

        val mpImage = BitmapImageBuilder(bitmap).build()
        val result  = handLandmarker?.detect(mpImage) ?: return null

        if (result.landmarks().isEmpty()) return null

        val flat = mutableListOf<Double>()
        result.landmarks()[0].forEach { lm ->
            flat.add(lm.x().toDouble())
            flat.add(lm.y().toDouble())
            flat.add(lm.z().toDouble())
        }
        return flat  // 63 values
    }
}