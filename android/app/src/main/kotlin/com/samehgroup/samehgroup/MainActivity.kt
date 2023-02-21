package com.samehgroup.samehgroup

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import android.widget.Toast
import android.content.Intent

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle


class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.samehgroup.samehgroup/khh"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "print") {
                val PrinterAdd = call.argument<String>("PrinterAdd")
                val ItemName = call.argument<String>("ItemName")
                val Price = call.argument<String>("Price")
                val Barcode = call.argument<String>("Barcode")
                val CopyCount = call.argument<String>("CopyCount")

                //Toast.makeText(applicationContext,aaa,Toast.LENGTH_SHORT).show()


                var launchIntent: Intent? = null

                launchIntent = applicationContext.getPackageManager()
                    .getLaunchIntentForPackage("com.masera.khh_barcodeprint")
                launchIntent?.putExtra("PrinterAdd", PrinterAdd)
                launchIntent?.putExtra("ItemName", ItemName)
                launchIntent?.putExtra("Price", Price)
                launchIntent?.putExtra("Barcode", Barcode)
                launchIntent?.putExtra("CopyCount", CopyCount)

                applicationContext.startActivity(launchIntent)


                //result.success(rand)
            } else {
                result.notImplemented()
            }
        }


    }
}
