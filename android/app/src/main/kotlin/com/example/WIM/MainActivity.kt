package com.example.WIM

import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity(){
    private val CHANNEL: String = "com.example.android_id/android"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                if (call.method == "getAndroidId") {
                    val androidId: String = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                    if (androidId != null) {
                        result.success(androidId)
                    } else {
                        result.error("UNAVAILABLE", "ANDROID_ID not available.", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

}
