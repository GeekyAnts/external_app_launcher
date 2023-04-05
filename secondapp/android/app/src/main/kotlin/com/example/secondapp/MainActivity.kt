package com.example.secondapp

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.example.secondapp/platform"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

   val channel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
channel.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
    if (call.method == "getInitialIntent") {
        val data = handleIntent(intent)
        result.success(data)
    } else {
        result.notImplemented()
    }
}
  }


    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

   private fun handleIntent(intent: Intent): String? {
    if (intent?.extras != null) {
        val data = intent.extras?.getString("data")
        data?.let {
            Log.d("MainActivity", "Received data: $data")
            return data
        }
    }
    return null
}

}