package com.example.smart_parking

import android.media.MediaPlayer
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.smart_parking/audio"
    private var sfxPlayer: MediaPlayer? = null
    private var inGamePlayer: MediaPlayer? = null
    private var clawsPlayer: MediaPlayer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Memaksa Hardware Acceleration (GPU Device) pada level Window Native Android
        window.setFlags(
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
        )
    }

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
                    try {
                        val rawName = call.argument<String>("sound") ?: "start"
                        val normalized = rawName.lowercase().replace("-", "").replace("_", "")
                        var resId = resources.getIdentifier(normalized, "raw", packageName)
                        if (resId == 0) {
                            resId = resources.getIdentifier(rawName.lowercase().replace("-", "_"), "raw", packageName)
                        }
                        if (resId == 0) {
                            resId = resources.getIdentifier(rawName.lowercase(), "raw", packageName)
                        }
                        if (resId != 0) {
                            sfxPlayer?.stop()
                            sfxPlayer?.release()
                            sfxPlayer = MediaPlayer.create(this, resId)
                            sfxPlayer?.setOnCompletionListener { mp ->
                                mp.release()
                                sfxPlayer = null
                            }
                            sfxPlayer?.start()
                            result.success(true)
                        } else {
                            result.error("NOT_FOUND", "Resource $rawName not found", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "stopRawSound" -> {
                    try {
                        sfxPlayer?.stop()
                        sfxPlayer?.release()
                        sfxPlayer = null
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "saveImageToGallery" -> {
                    try {
                        val bytes = call.argument<ByteArray>("bytes")
                        val fileName = call.argument<String>("fileName") ?: "ParkSmart_Receipt_${System.currentTimeMillis()}.png"
                        if (bytes == null) {
                            result.error("INVALID_ARGS", "Byte array is null", null)
                            return@setMethodCallHandler
                        }

                        val contentResolver = applicationContext.contentResolver
                        val contentValues = android.content.ContentValues().apply {
                            put(android.provider.MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                            put(android.provider.MediaStore.MediaColumns.MIME_TYPE, "image/png")
                            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                                put(android.provider.MediaStore.MediaColumns.RELATIVE_PATH, android.os.Environment.DIRECTORY_PICTURES + "/ParkSmart")
                                put(android.provider.MediaStore.MediaColumns.IS_PENDING, 1)
                            }
                        }

                        val uri = contentResolver.insert(android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                        if (uri != null) {
                            contentResolver.openOutputStream(uri)?.use { stream ->
                                stream.write(bytes)
                                stream.flush()
                            }

                            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                                contentValues.clear()
                                contentValues.put(android.provider.MediaStore.MediaColumns.IS_PENDING, 0)
                                contentResolver.update(uri, contentValues, null, null)
                            } else {
                                // Kirim broadcast media scanner untuk Android lama
                                val intent = android.content.Intent(android.content.Intent.ACTION_MEDIA_SCANNER_SCAN_FILE).apply {
                                    data = uri
                                }
                                sendBroadcast(intent)
                            }
                            result.success(true)
                        } else {
                            result.error("INSERT_FAILED", "Failed to create MediaStore entry", null)
                        }
                    } catch (e: Exception) {
                        result.error("SAVE_FAILED", e.localizedMessage, null)
                    }
                }
                "openNetworkSettings" -> {
                    try {
                        val intent = android.content.Intent(android.provider.Settings.ACTION_WIRELESS_SETTINGS).apply {
                            flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val intent = android.content.Intent(android.provider.Settings.ACTION_WIFI_SETTINGS).apply {
                                flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e2: Exception) {
                            try {
                                val intent = android.content.Intent(android.provider.Settings.ACTION_SETTINGS).apply {
                                    flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
                                }
                                startActivity(intent)
                                result.success(true)
                            } catch (e3: Exception) {
                                result.error("OPEN_SETTINGS_FAILED", e3.localizedMessage, null)
                            }
                        }
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
