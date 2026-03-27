package com.finot

import android.app.Activity
import android.content.Intent
import android.speech.RecognizerIntent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.util.*

class VoiceRecognitionPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private var pendingResult: Result? = null
  private val REQUEST_CODE_SPEECH_INPUT = 1000

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.finot.voice_recognition")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "startVoiceRecognition" -> {
        pendingResult = result
        startVoiceRecognition()
      }
      "stopVoiceRecognition" -> {
        // Cancel any ongoing recognition
        pendingResult?.error("CANCELLED", "Voice recognition cancelled", null)
        pendingResult = null
        result.success(null)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun startVoiceRecognition() {
    if (activity == null) {
      pendingResult?.error("NO_ACTIVITY", "No activity available", null)
      pendingResult = null
      return
    }

    try {
      val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
      intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
      intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "am-ET") // Amharic language code
      intent.putExtra(RecognizerIntent.EXTRA_PROMPT, "እባክዎ ይናገሩ...")
      activity?.startActivityForResult(intent, REQUEST_CODE_SPEECH_INPUT)
    } catch (e: Exception) {
      pendingResult?.error("RECOGNITION_ERROR", e.message, null)
      pendingResult = null
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == REQUEST_CODE_SPEECH_INPUT) {
      if (resultCode == Activity.RESULT_OK && data != null) {
        val result = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
        if (result != null && result.isNotEmpty()) {
          pendingResult?.success(result[0])
        } else {
          pendingResult?.error("NO_RESULT", "No speech recognized", null)
        }
      } else {
        pendingResult?.error("RECOGNITION_FAILED", "Speech recognition failed", null)
      }
      pendingResult = null
      return true
    }
    return false
  }
}