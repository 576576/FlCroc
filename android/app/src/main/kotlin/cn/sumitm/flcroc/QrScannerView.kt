package cn.sumitm.flcroc

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.content.pm.PackageManager
import android.graphics.ImageFormat
import android.util.Size
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.google.zxing.*
import com.google.zxing.common.HybridBinarizer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.*
import java.util.concurrent.Executors

/**
 * PlatformView that provides native CameraX + ZXing QR scanning.
 * Ported from croc-app's QrScannerScreen.kt / CameraPreview.
 */
class QrScannerView(
    private val context: Context,
    viewId: Int,
    messenger: BinaryMessenger,
    creationParams: Map<String, Any>?
) : PlatformView, MethodChannel.MethodCallHandler {

    // Use SURFACE_VIEW for reliable compositing with Flutter PlatformView
    private val previewView = PreviewView(context).apply {
        implementationMode = PreviewView.ImplementationMode.COMPATIBLE
    }
    private val channel = MethodChannel(messenger, "flcroc/qr_scanner_$viewId")
    private val analyzerExecutor = Executors.newSingleThreadExecutor()
    private var scanned = false
    private var cameraProvider: ProcessCameraProvider? = null

    // ZXing reader — QR only, TRY_HARDER, support inverted (white-on-black) QR codes
    private val qrReader = MultiFormatReader().apply {
        setHints(EnumMap<DecodeHintType, Any>(DecodeHintType::class.java).apply {
            put(DecodeHintType.POSSIBLE_FORMATS, listOf(BarcodeFormat.QR_CODE))
            put(DecodeHintType.TRY_HARDER, true)
            put(DecodeHintType.ALSO_INVERTED, true)
        })
    }

    init {
        channel.setMethodCallHandler(this)
        // Defer camera start until view is laid out
        previewView.post { startCamera() }
    }

    /**
     * Unwrap the context to find the underlying Activity (LifecycleOwner).
     * Flutter's PlatformView wraps the context, so we need to peel it back.
     */
    private fun findActivity(): Activity? {
        var ctx = context
        while (ctx is ContextWrapper) {
            if (ctx is Activity) return ctx
            ctx = ctx.baseContext
        }
        return null
    }

    private fun startCamera() {
        if (!hasCameraPermission()) {
            channel.invokeMethod("onError", mapOf(
                "errorCode" to "permissionDenied",
                "message" to "Camera permission denied"
            ))
            return
        }

        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            try {
                cameraProvider = cameraProviderFuture.get()
                bindCameraUseCases()
            } catch (e: Exception) {
                e.printStackTrace()
                channel.invokeMethod("onError", mapOf(
                    "errorCode" to "cameraError",
                    "message" to (e.message ?: "Camera initialization failed")
                ))
            }
        }, ContextCompat.getMainExecutor(context))
    }

    private fun bindCameraUseCases() {
        val provider = cameraProvider ?: return
        provider.unbindAll()

        val preview = Preview.Builder()
            .setTargetResolution(Size(1280, 720))
            .build()
            .also { it.surfaceProvider = previewView.surfaceProvider }

        val imageAnalysis = ImageAnalysis.Builder()
            .setTargetResolution(Size(1280, 720))
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .build()

        imageAnalysis.setAnalyzer(analyzerExecutor) { imageProxy ->
            if (scanned) {
                imageProxy.close()
                return@setAnalyzer
            }
            val result = decodeQrCode(imageProxy)
            imageProxy.close()

            val value = result?.text?.trim().orEmpty()
            if (value.isNotEmpty()) {
                scanned = true
                ContextCompat.getMainExecutor(context).execute {
                    channel.invokeMethod("onScan", mapOf("code" to value))
                }
            }
        }

        val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA
        // Unwrap to find the Activity for lifecycle binding
        val lifecycleOwner = findActivity() as? LifecycleOwner

        try {
            if (lifecycleOwner != null) {
                provider.bindToLifecycle(lifecycleOwner, cameraSelector, preview, imageAnalysis)
            } else {
                // Fallback: bind without lifecycle (stays active until unbindAll)
                provider.bindToLifecycle(
                    androidx.lifecycle.LifecycleRegistry(lifecycleOwner ?: return).also {
                        it.currentState = androidx.lifecycle.Lifecycle.State.RESUMED
                    },
                    cameraSelector, preview, imageAnalysis
                )
            }
        } catch (e: Exception) {
            e.printStackTrace()
            channel.invokeMethod("onError", mapOf(
                "errorCode" to "cameraError",
                "message" to (e.message ?: "Failed to start camera")
            ))
        }
    }

    // ── ZXing decoding (from croc-app) ──

    private fun decodeQrCode(image: ImageProxy): Result? {
        if (image.format != ImageFormat.YUV_420_888 || image.planes.isEmpty()) {
            return null
        }
        return try {
            val source = toQrLuminanceSource(image) ?: return null
            qrReader.decodeWithState(BinaryBitmap(HybridBinarizer(source)))
        } catch (_: NotFoundException) {
            null
        } finally {
            qrReader.reset()
        }
    }

    private fun toQrLuminanceSource(image: ImageProxy): PlanarYUVLuminanceSource? {
        val luminance = extractLuminanceBytes(image) ?: return null
        val w = image.width
        val h = image.height
        return when (image.imageInfo.rotationDegrees) {
            90 -> PlanarYUVLuminanceSource(rotate90(luminance, w, h), h, w, 0, 0, h, w, false)
            180 -> PlanarYUVLuminanceSource(rotate180(luminance), w, h, 0, 0, w, h, false)
            270 -> PlanarYUVLuminanceSource(rotate270(luminance, w, h), h, w, 0, 0, h, w, false)
            else -> PlanarYUVLuminanceSource(luminance, w, h, 0, 0, w, h, false)
        }
    }

    private fun extractLuminanceBytes(image: ImageProxy): ByteArray? {
        val plane = image.planes.firstOrNull() ?: return null
        val buffer = plane.buffer.duplicate().apply { rewind() }
        val rowStride = plane.rowStride
        val pixelStride = plane.pixelStride
        val w = image.width
        val h = image.height
        val data = ByteArray(w * h)

        if (pixelStride == 1 && rowStride == w) {
            buffer.get(data)
            return data
        }

        val rowBuffer = ByteArray(rowStride)
        var outputOffset = 0

        for (row in 0 until h) {
            val bytesToRead = minOf(rowStride, buffer.remaining())
            if (bytesToRead <= (w - 1) * pixelStride) return null
            buffer.get(rowBuffer, 0, bytesToRead)
            var inputOffset = 0
            repeat(w) {
                data[outputOffset++] = rowBuffer[inputOffset]
                inputOffset += pixelStride
            }
        }
        return data
    }

    // ── Rotation helpers ──

    private fun rotate90(data: ByteArray, width: Int, height: Int): ByteArray {
        val rotated = ByteArray(data.size)
        for (y in 0 until height) {
            for (x in 0 until width) {
                rotated[x * height + (height - 1 - y)] = data[y * width + x]
            }
        }
        return rotated
    }

    private fun rotate180(data: ByteArray): ByteArray {
        val rotated = ByteArray(data.size)
        for (i in data.indices) rotated[data.size - 1 - i] = data[i]
        return rotated
    }

    private fun rotate270(data: ByteArray, width: Int, height: Int): ByteArray {
        val rotated = ByteArray(data.size)
        for (y in 0 until height) {
            for (x in 0 until width) {
                rotated[(width - 1 - x) * height + y] = data[y * width + x]
            }
        }
        return rotated
    }

    // ── Permission ──

    private fun hasCameraPermission(): Boolean {
        return ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) ==
                PackageManager.PERMISSION_GRANTED
    }

    // ── PlatformView ──

    override fun getView() = previewView

    override fun dispose() {
        scanned = true
        analyzerExecutor.shutdown()
        cameraProvider?.unbindAll()
        cameraProvider = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                scanned = false
                startCamera()
                result.success(null)
            }
            "stop" -> {
                scanned = true
                cameraProvider?.unbindAll()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}

