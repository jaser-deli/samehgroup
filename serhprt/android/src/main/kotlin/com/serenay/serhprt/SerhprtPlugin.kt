package com.serenay.serhprt

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import HPRTAndroidSDK.HPRTPrinterHelper


/** SerhprtPlugin */
class SerhprtPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private var printHelper: HPRTPrinterHelper = HPRTPrinterHelper()

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var context: Context
    private lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel =
            MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "serhprt")
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.applicationContext
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "serhprt")
            channel.setMethodCallHandler(SerhprtPlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPlatformVersion") {

            result.success("Android ${android.os.Build.VERSION.RELEASE}")

        } else if (call.method.equals("connect")) {

            val name: String = call.argument<String>("name") as String
            val toothAddress: String = call.argument<String>("toothAddress") as String
            result.success(connect(name, toothAddress))

        } else if (call.method.equals("printBarcode")) {

            val tur: Int = call.argument<Int>("tur") as Int
            val barcode: String = call.argument<String>("barcode") as String
            val width: Int = call.argument<Int>("width") as Int
            val height: Int = call.argument<Int>("height") as Int
            val position: Int = call.argument<Int>("position") as Int
            val justification: Int = call.argument<Int>("justification") as Int
            result.success(printBarcode(tur, barcode, width, height, position, justification))

        } else if (call.method.equals("printAndFeed")) {

            val distance: Int = call.argument<Int>("distance") as Int
            result.success(printAndFeed(distance))

        } else if (call.method.equals("printText")) {

            //int alignment, bool isBold, bool isUnderline, bool isAntiWhite, int textsize, String data
            val alignment: Int = call.argument<Int>("alignment") as Int
            val isBold: Boolean = call.argument<Boolean>("isBold") as Boolean
            val isUnderline: Boolean = call.argument<Boolean>("isUnderline") as Boolean
            val isAntiWhite: Boolean = call.argument<Boolean>("isAntiWhite") as Boolean
            val textsize: Int = call.argument<Int>("textsize") as Int
            val data: String = call.argument<String>("data") as String
            result.success(printText(alignment, isBold, isUnderline, isAntiWhite, textsize, data))

        } else if (call.method.equals("isOpened")) {

            result.success(isOpened())

        } else {

            result.notImplemented()

        }
    }

    private fun connect(name: String, toothAddress: String): String {
        printHelper = HPRTPrinterHelper(activity, name)
        val intReturn = HPRTPrinterHelper.PortOpen("Bluetooth,$toothAddress")
        return intReturn.toString()
    }

    private fun printBarcode(
        tur: Int,
        barcode: String,
        width: Int,
        height: Int,
        position: Int,
        justification: Int
    ): String {
        val intReturn =
            HPRTPrinterHelper.PrintBarCode(tur, barcode, width, height, position, justification)
        return intReturn.toString()
    }

    private fun printText(
        alignment: Int,
        isBold: Boolean,
        isUnderline: Boolean,
        isAntiWhite: Boolean,
        textsize: Int,
        data: String
    ): String {
        val intReturn =
            HPRTPrinterHelper.PrintText(alignment, isBold, isUnderline, isAntiWhite, textsize, data)
        return intReturn.toString()
    }

    private fun printAndFeed(distance: Int): String {
        val intReturn = HPRTPrinterHelper.PrintAndFeed(distance)
        return intReturn.toString()
    }

    private fun isOpened(): Boolean {
        val result = HPRTPrinterHelper.IsOpened()
        return result
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }
}
