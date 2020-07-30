package com.deeplearners.scribeplus

import androidx.annotation.NonNull;
import android.os.Bundle
import io.flutter.plugin.common.MethodChannel
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

import java.time.LocalDateTime
import java.io.IOException
import android.media.MediaRecorder
import android.os.Environment
import android.media.AudioFormat

class MainActivity: FlutterActivity() {
    private val CHANNEL = "scribeplus.sendstring"

    public val mediaRecorder = MediaRecorder()
    public var output = " "

    public val x = mediaRecorder?.setAudioSource(MediaRecorder.AudioSource.MIC)
    public val y = mediaRecorder?.setOutputFormat(AudioFormat.ENCODING_PCM_16BIT)
    public val z = mediaRecorder?.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
    public val a = mediaRecorder?.setAudioChannels(1)
    public val b = mediaRecorder?.setAudioEncodingBitRate(128000)
    public val c = mediaRecorder?.setAudioSamplingRate(48000)

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel( flutterEngine.getDartExecutor(), CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "callSendStringFun") {
                output = Environment.getExternalStorageDirectory().absolutePath + "/" + LocalDateTime.now() + ".mp3"
                mediaRecorder?.setOutputFile(output)
                showHelloFromFlutter(call.argument("arg"))
                val temp = sendString()
                result.success(temp)
            } else if(call.method == "stopRecord") {
                stopRecord()
                println("recording stoped")
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun sendString(): String {
        return output
    }

    private fun stopRecord() {
        try {
            Toast.makeText(this,"Stopped!", Toast.LENGTH_SHORT).show()
            mediaRecorder?.stop()
            mediaRecorder?.release()
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }

    private fun showHelloFromFlutter(argFromFlutter : String?){
        println("path^ ${output}")

        try {
            mediaRecorder?.prepare()
            mediaRecorder?.start()
//            state = true
            Toast.makeText(this, "Recording started!", Toast.LENGTH_SHORT).show()
        } catch (e: IllegalStateException) {
            e.printStackTrace()
        } catch (e: IOException) {
            e.printStackTrace()
        }

        Toast.makeText(this, argFromFlutter, Toast.LENGTH_SHORT).show()
    }
}
