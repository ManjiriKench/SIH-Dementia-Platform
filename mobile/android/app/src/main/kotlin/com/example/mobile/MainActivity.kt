package com.example.mobile

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import kotlin.math.PI
import kotlin.math.exp
import kotlin.math.sin

class MainActivity : FlutterActivity(), TextToSpeech.OnInitListener {
    private val TTS_CHANNEL = "com.example.mobile/tts"
    private val AUDIO_CHANNEL = "com.example.mobile/audio"
    private var tts: TextToSpeech? = null
    private var isTtsReady = false

    // Melody Synthesizer State
    private var audioTrack: AudioTrack? = null
    @Volatile
    private var isMelodyPlaying = false
    private var melodyThread: Thread? = null

    override fun getRenderMode(): RenderMode {
        return RenderMode.texture
    }

    private fun ensureTts() {
        if (tts == null) {
            tts = TextToSpeech(applicationContext, this)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // TTS Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TTS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "speak" -> {
                    val text = call.argument<String>("text") ?: ""
                    val rate = call.argument<Double>("rate") ?: 0.85
                    val lang = call.argument<String>("language") ?: "en"

                    ensureTts()

                    if (isTtsReady && text.isNotEmpty()) {
                        when (lang) {
                            "hi" -> tts?.language = Locale("hi", "IN")
                            "as" -> {
                                val setLangResult = tts?.setLanguage(Locale("as", "IN"))
                                if (setLangResult == TextToSpeech.LANG_MISSING_DATA || setLangResult == TextToSpeech.LANG_NOT_SUPPORTED) {
                                    tts?.language = Locale("hi", "IN")
                                }
                            }
                            else -> tts?.language = Locale.ENGLISH
                        }
                        tts?.setSpeechRate(rate.toFloat())
                        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "smriti_tts_id")
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "stop" -> {
                    tts?.stop()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Native Audio Channel for Peaceful Melodies
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    val songIndex = call.argument<Int>("songIndex") ?: 0
                    startPeacefulMelody(songIndex)
                    result.success(true)
                }
                "stop" -> {
                    stopPeacefulMelody()
                    result.success(true)
                }
                "pause" -> {
                    stopPeacefulMelody()
                    result.success(true)
                }
                "isPlaying" -> {
                    result.success(isMelodyPlaying)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startPeacefulMelody(songIndex: Int) {
        stopPeacefulMelody()
        isMelodyPlaying = true

        melodyThread = Thread {
            val sampleRate = 22050
            val minBufSize = AudioTrack.getMinBufferSize(
                sampleRate,
                AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            )

            val track = try {
                AudioTrack.Builder()
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .build()
                    )
                    .setAudioFormat(
                        AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setSampleRate(sampleRate)
                            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                            .build()
                    )
                    .setBufferSizeInBytes(minBufSize.coerceAtLeast(sampleRate * 2))
                    .setTransferMode(AudioTrack.MODE_STREAM)
                    .build()
            } catch (e: Exception) {
                isMelodyPlaying = false
                return@Thread
            }

            audioTrack = track
            try {
                track.play()
            } catch (e: Exception) {
                isMelodyPlaying = false
                return@Thread
            }

            // Frequencies for Raga Bhupali (Song 0: Flute) and Sitar Chimes (Song 1)
            val notes = if (songIndex == 0) {
                // Gentle Indian Bamboo Flute sequence (Sa, Re, Ga, Pa, Dha, Sa')
                doubleArrayOf(261.63, 293.66, 329.63, 392.00, 440.00, 392.00, 329.63, 293.66, 261.63)
            } else {
                // Peaceful Sitar / Rabindra style melody
                doubleArrayOf(329.63, 392.00, 440.00, 523.25, 440.00, 392.00, 349.23, 329.63, 261.63)
            }

            var noteIdx = 0
            while (isMelodyPlaying) {
                val freq = notes[noteIdx % notes.size]
                val noteDurationSec = 1.4
                val numSamples = (sampleRate * noteDurationSec).toInt()
                val samples = ShortArray(numSamples)

                for (i in 0 until numSamples) {
                    val t = i.toDouble() / sampleRate
                    // Smooth bell / flute envelope (gentle attack, soft release)
                    val envelope = if (t < 0.15) {
                        t / 0.15
                    } else {
                        exp(-2.2 * (t - 0.15))
                    }
                    // Fundamental + subtle warm 2nd harmonic
                    val wave = 0.75 * sin(2.0 * PI * freq * t) + 0.25 * sin(4.0 * PI * freq * t)
                    val sampleVal = (wave * envelope * 0.45 * Short.MAX_VALUE).toInt()
                    samples[i] = sampleVal.coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
                }

                if (!isMelodyPlaying) break
                track.write(samples, 0, samples.size)

                // Gentle 250ms breathing gap between notes
                val silenceSamples = ShortArray((sampleRate * 0.25).toInt())
                if (!isMelodyPlaying) break
                track.write(silenceSamples, 0, silenceSamples.size)

                noteIdx++
            }

            try {
                track.stop()
                track.release()
            } catch (_: Exception) {}
        }
        melodyThread?.isDaemon = true
        melodyThread?.start()
    }

    private fun stopPeacefulMelody() {
        isMelodyPlaying = false
        try {
            audioTrack?.pause()
            audioTrack?.flush()
            audioTrack?.stop()
        } catch (_: Exception) {}
        melodyThread?.interrupt()
        melodyThread = null
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            tts?.language = Locale.ENGLISH
            isTtsReady = true
        }
    }

    override fun onDestroy() {
        stopPeacefulMelody()
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
}
