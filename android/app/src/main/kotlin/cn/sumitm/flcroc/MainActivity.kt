package cn.sumitm.flcroc

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "flcroc/qr_scanner",
                QrScannerViewFactory(flutterEngine.dartExecutor.binaryMessenger)
            )
    }
}
