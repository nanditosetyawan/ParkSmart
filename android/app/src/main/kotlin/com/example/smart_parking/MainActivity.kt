package com.example.smart_parking

import android.media.MediaPlayer
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.smart_parking/audio"
    private var sfxPlayer: MediaPlayer? = null
    private var inGamePlayer: MediaPlayer? = null
    private var clawsPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playStartSound" -> {
                    try {
                        stopInGameSound()
                        sfxPlayer?.release()
                        sfxPlayer = null

                        val isBonus = call.argument<Boolean>("isBonus") ?: false

                        val startResId = resources.getIdentifier("start", "raw", packageName)
                        if (startResId != 0) {
                            sfxPlayer = MediaPlayer.create(this, startResId)
                            sfxPlayer?.setOnCompletionListener { mp ->
                                mp.release()
                                sfxPlayer = null
                                // Otomatis mulai memutar musik in-game sesudah start.mp3 selesai:
                                // Mode bonus -> car_bonusmode.mp3
                                // Mode biasa -> ingamecar.mp3
                                startInGameSound(loop = true, isBonus = isBonus)
                            }
                            sfxPlayer?.start()
                            result.success(true)
                        } else {
                            startInGameSound(loop = true, isBonus = isBonus)
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "startInGameSound" -> {
                    try {
                        val isBonus = call.argument<Boolean>("isBonus") ?: false
                        startInGameSound(loop = true, isBonus = isBonus)
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
                        // Pastikan musik in-game berhenti SEBELUM die.mp3 berbunyi
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
                "startClawsMusic" -> {
                    try {
                        startClawsMusic(loop = true)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "stopClawsMusic" -> {
                    stopClawsMusic()
                    result.success(true)
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

    private fun startInGameSound(loop: Boolean = true, isBonus: Boolean = false) {
        try {
            inGamePlayer?.release()
            inGamePlayer = null

            // Jika mode bonus, gunakan car_bonusmode.mp3
            // Jika mode biasa, gunakan ingamecar.mp3
            val targetSound = if (isBonus) "car_bonusmode" else "ingamecar"
            var resId = resources.getIdentifier(targetSound, "raw", packageName)
            if (resId == 0 && isBonus) {
                resId = resources.getIdentifier("car_bonus_mode", "raw", packageName)
            }
            if (resId == 0) {
                resId = resources.getIdentifier("ingamecar", "raw", packageName)
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

    private fun startClawsMusic(loop: Boolean = true) {
        try {
            clawsPlayer?.stop()
            clawsPlayer?.release()
            clawsPlayer = null

            var resId = resources.getIdentifier("musiccrawls", "raw", packageName)
            if (resId == 0) {
                resId = resources.getIdentifier("music_crawls", "raw", packageName)
            }
            if (resId != 0) {
                clawsPlayer = MediaPlayer.create(this, resId)
                clawsPlayer?.isLooping = loop
                clawsPlayer?.start()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun stopClawsMusic() {
        try {
            clawsPlayer?.stop()
            clawsPlayer?.release()
            clawsPlayer = null
        } catch (e: Exception) {
            clawsPlayer = null
        }
    }

    private fun stopAllSounds() {
        stopInGameSound()
        stopClawsMusic()
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
