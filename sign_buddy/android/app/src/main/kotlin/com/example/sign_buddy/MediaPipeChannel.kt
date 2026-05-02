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
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

class MediaPipeChannel(private val context: Context, flutterEngine: FlutterEngine) {

    private var handLandmarker: HandLandmarker? = null
    @Volatile private var isReady = false
    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private val isProcessing = AtomicBoolean(false)

    init {
        // Setup MediaPipe on background thread
        executor.execute {
            try {
                setupLandmarker("models/hand_landmarker.task")
                isReady = true
                Log.d("MP_DEBUG", "MediaPipe ready")
            } catch (e: Exception) {
                Log.e("MP_DEBUG", "MediaPipe setup failed: ${e.message}")
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "sign_buddy/mediapipe"
        ).setMethodCallHandler { call, result ->
            if (call.method == "detectLandmarks") {
                val bytes  = call.argument<ByteArray>("bytes")!!
                val width  = call.argument<Int>("width")!!
                val height = call.argument<Int>("height")!!

                // Drop frame if still processing previous one
                if (!isProcessing.compareAndSet(false, true)) {
                    Log.d("MP_DEBUG", "Frame dropped - still processing")
                    result.success(null)
                    return@setMethodCallHandler
                }

                executor.execute {
                    val landmarks = processFrame(bytes, width, height)
                    isProcessing.set(false)
                    android.os.Handler(android.os.Looper.getMainLooper()).post {
                        result.success(landmarks)
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setupLandmarker(modelPath: String) {

        val cm = context.getSystemService(Context.CAMERA_SERVICE) as android.hardware.camera2.CameraManager
        val cameraId = cm.cameraIdList[0] // 0 = back camera
        val chars = cm.getCameraCharacteristics(cameraId)
        val sensorOrientation = chars.get(android.hardware.camera2.CameraCharacteristics.SENSOR_ORIENTATION)
        Log.d("MP_DEBUG", "Sensor orientation: $sensorOrientation")

        val options = HandLandmarkerOptions.builder()
            .setBaseOptions(
                BaseOptions.builder()
                    .setModelAssetPath(modelPath)
                    .setDelegate(Delegate.CPU)
                    .build()
            )
            .setNumHands(1)
            .setMinHandDetectionConfidence(0.3f)
            .setMinHandPresenceConfidence(0.3f)
            .setMinTrackingConfidence(0.3f)
            .setRunningMode(RunningMode.IMAGE)
            .build()

        handLandmarker = HandLandmarker.createFromOptions(context, options)
    }

    private fun processFrame(bytes: ByteArray, width: Int, height: Int): List<Double>? {
        Log.d("MP_DEBUG", "Frame: ${width}x${height}")


        if (handLandmarker == null || !isReady) {
            Log.d("MP_DEBUG", "MediaPipe not ready yet")
            return null
        }

        val yuvImage = YuvImage(bytes, ImageFormat.NV21, width, height, null)
        val out = ByteArrayOutputStream()
        yuvImage.compressToJpeg(Rect(0, 0, width, height), 80, out)
        val bitmap = BitmapFactory.decodeByteArray(out.toByteArray(), 0, out.size())

        val matrix = android.graphics.Matrix()
        matrix.postRotate(90f)
        val rotatedBitmap = android.graphics.Bitmap.createBitmap(
            bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true
        )

        val mpImage = BitmapImageBuilder(rotatedBitmap).build()
        val result  = handLandmarker?.detect(mpImage) ?: return null

        val flat = if (result.landmarks().isEmpty()) {
            Log.d("MP_DEBUG", "No hand landmarks detected")
            null
        } else {
            val list = mutableListOf<Double>()
            result.landmarks()[0].forEach { lm ->
                list.add(lm.x().toDouble())
                list.add(lm.y().toDouble())
                list.add(lm.z().toDouble())
            }
            Log.d("MP_DEBUG", "Landmarks detected: ${result.landmarks().size}")
            list
        }

        bitmap.recycle()
        rotatedBitmap.recycle()
        return flat
    }

    fun shutdown() {
        executor.shutdown()
        handLandmarker?.close()
    }
}