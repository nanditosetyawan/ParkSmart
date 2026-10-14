package com.example.smart_parking

import android.media.MediaPlayer
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.smart_parking/audio"
    private var sfxPlayer: MediaPlayer? = null
    private var inGamePlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playStartSound" -> {
                    try {
                        stopInGameSound()
                        sfxPlayer?.release()
                        sfxPlayer = null

                        val startResId = resources.getIdentifier("start", "raw", packageName)
                        if (startResId != 0) {
                            sfxPlayer = MediaPlayer.create(this, startResId)
                            sfxPlayer?.setOnCompletionListener { mp ->
                                mp.release()
                                sfxPlayer = null
                                // Otomatis mulai memutar inGameCar.mp3 (loop) sesudah start.mp3 selesai
                                startInGameSound(loop = true)
                            }
                            sfxPlayer?.start()
                            result.success(true)
                        } else {
                            // Fallback jika start.mp3 tidak ditemukan, langsung mainkan inGameCar.mp3
                            startInGameSound(loop = true)
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "startInGameSound" -> {
                    try {
                        startInGameSound(loop = true)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "stopInGameSound" -> {
                    stopInGameSound()
                    result.success(true)
                }
                "playGameOverSound" -> {
                    try {
                        // Pastikan inGameCar.mp3 berhenti SEBELUM die.mp3 berbunyi
                        stopInGameSound()
                        sfxPlayer?.release()
                        sfxPlayer = null

                        val dieResId = resources.getIdentifier("die", "raw", packageName)
                        if (dieResId != 0) {
                            sfxPlayer = MediaPlayer.create(this, dieResId)
                            sfxPlayer?.setOnCompletionListener { mp ->
                                mp.release()
                                sfxPlayer = null
                            }
                            sfxPlayer?.start()
                            result.success(true)
                        } else {
                            result.error("NOT_FOUND", "die.mp3 not found", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "stopAllSounds" -> {
                    stopAllSounds()
                    result.success(true)
                }
                "playRawSound" -> {
                    val rawName = call.argument<String>("sound") ?: "start"
                    val normalized = rawName.lowercase().replace("-", "").replace("_", "")
                    val resId = resources.getIdentifier(normalized, "raw", packageName)
                    if (resId != 0) {
                        val mp = MediaPlayer.create(this, resId)
                        mp?.setOnCompletionListener { it.release() }
                        mp?.start()
                        result.success(true)
                    } else {
                        result.error("NOT_FOUND", "Resource $rawName not found", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startInGameSound(loop: Boolean = true) {
        try {
            inGamePlayer?.release()
            inGamePlayer = null

            // Mendukung nama resource ingamecar di res/raw
            var resId = resources.getIdentifier("ingamecar", "raw", packageName)
            if (resId == 0) {
                resId = resources.getIdentifier("ingame_car", "raw", packageName)
            }
            if (resId != 0) {
                inGamePlayer = MediaPlayer.create(this, resId)
                inGamePlayer?.isLooping = loop
                inGamePlayer?.start()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun stopInGameSound() {
        try {
            inGamePlayer?.stop()
            inGamePlayer?.release()
            inGamePlayer = null
        } catch (e: Exception) {
            inGamePlayer = null
        }
    }

    private fun stopAllSounds() {
        stopInGameSound()
        try {
            sfxPlayer?.stop()
            sfxPlayer?.release()
            sfxPlayer = null
        } catch (e: Exception) {
            sfxPlayer = null
        }
    }

    override fun onDestroy() {
        stopAllSounds()
        super.onDestroy()
    }
}
