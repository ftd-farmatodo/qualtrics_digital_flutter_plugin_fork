package com.qualtrics.flutter.qualtrics_digital_flutter_plugin

import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import com.qualtrics.digital.IQualtricsProjectEvaluationCallback
import com.qualtrics.digital.Qualtrics
import com.qualtrics.digital.QualtricsLogLevel
import com.qualtrics.digital.TargetingResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** QualtricsDigitalFlutterPlugin */
class QualtricsDigitalFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var _result: MethodChannel.Result
    private lateinit var context: Context
    private var binding: ActivityPluginBinding? = null
    private var flutterSDKProperty = "Qualtrics_IS_FLUTTER"

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "qualtrics_digital_flutter_plugin")
        channel.setMethodCallHandler(this)
        this.context = flutterPluginBinding.applicationContext
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.binding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.binding = binding
    }

    override fun onDetachedFromActivity() {
        this.binding = null
    }

    @RequiresApi(Build.VERSION_CODES.N)
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        when(call.method) {
            "initializeProject" -> handleInitializeProject(call, result)
            "initializeProjectWithExtRefId" -> handleInitializeProjectWithExtRefId(call, result)
            "evaluateProject" -> handleEvaluateProject(call, result)
            "display" -> handleDisplay(call, result)
            "evaluateIntercept" -> handleEvaluateIntercept(call, result)
            "displayIntercept" -> handleDisplayIntercept(call, result)
            "displayTarget" -> handleDisplayTarget(call, result)
            "setLogLevel" -> handleSetLogLevel(call, result)
            "registerViewVisit" -> handleRegisterViewVisit(call)
            "resetTimer" -> Qualtrics.instance().resetTimer()
            "resetViewCounter" -> Qualtrics.instance().resetViewCounter()
            "setString" -> handleSetString(call)
            "setNumber" -> handleSetNumber(call)
            "setDateTime" -> handleSetDateTime(call)
            "qualify" -> {
                _result = result
                handleQualify()
            }
            else ->  result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    @RequiresApi(Build.VERSION_CODES.N)
    private fun handleInitializeProject(@NonNull call: MethodCall, @NonNull result: Result) {
        var initOutput: MutableMap<String, String> = mutableMapOf();
        Qualtrics.instance().initializeProject(call.argument<String>("brandId"),
                call.argument<String>("projectId"),
                this.context) { initializationResults ->
            run {
                initializationResults.forEach { interceptId, initResult ->
                    initOutput[interceptId] = initResult.passed().toString();
                }
                Qualtrics.instance().properties.setString(flutterSDKProperty, "true")
                result.success(initOutput);
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.N)
    private fun handleInitializeProjectWithExtRefId(@NonNull call: MethodCall, @NonNull result: Result) {
        Qualtrics.instance().setLogLevel(QualtricsLogLevel.INFO);
        var initOutput: MutableMap<String, String> = mutableMapOf();
        Qualtrics.instance().initializeProject(call.argument<String>("brandId"),
                call.argument<String>("projectId"),
                call.argument<String>("extRefId"),
                this.context) { initializationResults ->
            run {
                initializationResults.forEach { interceptId, initResult ->
                    initOutput[interceptId] = initResult.passed().toString();
                }
                Qualtrics.instance().properties.setString(flutterSDKProperty, "true")
                result.success(initOutput);
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.N)
    private fun handleEvaluateProject(@NonNull call: MethodCall, @NonNull result: Result) {
        var evaluateProjectOutput: MutableMap<String, MutableMap<String, String>> = mutableMapOf();
        Qualtrics.instance().evaluateProject { evaluateProjectResult ->
            run {
                evaluateProjectResult.forEach { interceptId, targetingResult ->
                    var evaluationResult: MutableMap<String, String> = mutableMapOf()
                    evaluationResult["passed"] = targetingResult.passed().toString()
                    evaluationResult["creativeType"] = if (targetingResult.creativeType == null) "null" else targetingResult.creativeType.name
                    evaluationResult["surveyUrl"] = if (targetingResult.surveyUrl == null) "null" else targetingResult.surveyUrl
                    evaluationResult["error"] = if (targetingResult.error == null)  "null" else  targetingResult.error.toString()
                    evaluateProjectOutput[interceptId] = evaluationResult
                }
                result.success(evaluateProjectOutput)
            }
        }
    }

    private fun handleDisplay(@NonNull call: MethodCall, @NonNull result: Result) {
        var displayed = Qualtrics.instance().display(binding?.activity)
        result.success(displayed);
    }

    private fun handleDisplayTarget(@NonNull call: MethodCall, @NonNull result: Result) {
        var targetUrl = call.argument<String>("targetUrl")
        var displayed = Qualtrics.instance().displayTarget(binding?.activity, targetUrl)
        result.success(displayed)
    }

    private fun handleEvaluateIntercept(@NonNull call: MethodCall, @NonNull result: Result) {
        var evaluateInterceptResult: MutableMap<String, String> = mutableMapOf()
        var interceptToBeEvaluated = call.argument<String>("interceptId")
        Qualtrics.instance().evaluateIntercept(interceptToBeEvaluated) {
            targetingResult -> run {
                evaluateInterceptResult["interceptId"] = targetingResult.interceptID
                evaluateInterceptResult["surveyUrl"] = if (targetingResult.surveyUrl == null) "null" else targetingResult.surveyUrl
                evaluateInterceptResult["passed"] = targetingResult.passed().toString()
                evaluateInterceptResult["creativeType"] = if (targetingResult.creativeType == null) "null" else targetingResult.creativeType.name
                evaluateInterceptResult["error"] = if (targetingResult.error == null)  "null" else  targetingResult.error.toString()
                result.success(evaluateInterceptResult)
            }
        }
    }

    private fun handleDisplayIntercept(@NonNull call: MethodCall, @NonNull result: Result) {
        var displayed = Qualtrics.instance().displayIntercept(binding?.activity, call.argument("interceptId"))
        result.success(displayed)
    }

    private fun handleSetLogLevel(@NonNull call: MethodCall, @NonNull result: Result) {
        var logLevel = call.argument<String>("logLevel")
        when (logLevel) {
            "info" -> Qualtrics.instance().setLogLevel(QualtricsLogLevel.INFO)
            "none" -> Qualtrics.instance().setLogLevel(QualtricsLogLevel.NONE)
            else -> result.notImplemented()
        }
        result.success("Log level set successfully")
    }

    private fun handleRegisterViewVisit(@NonNull call: MethodCall) {
        var viewName = call.argument<String>("viewName")
        Qualtrics.instance().registerViewVisit(viewName)
    }

    private fun handleSetString(@NonNull call: MethodCall) {
        var key = call.argument<String>("key")
        var value = call.argument<String>("value")
        Qualtrics.instance().properties.setString(key, value)
    }

    private fun handleSetNumber(@NonNull call: MethodCall) {
        var key = call.argument<String>("key")
        var value = call.argument<Double>("value")
        if (value != null) {
            Qualtrics.instance().properties.setNumber(key, value)
        }
    }

    private fun handleSetDateTime(@NonNull call: MethodCall) {
        var key = call.argument<String>("key")
        Qualtrics.instance().properties.setDateTime(key)
    }
    private fun handleQualify(){
        Qualtrics.instance().evaluateProject(QsCallback())
    }
    private inner class QsCallback: IQualtricsProjectEvaluationCallback {
        override fun run(p0: MutableMap<String, TargetingResult>?) {
            if (p0 != null) {
                p0.forEach { entry ->
                    if (entry.value.passed()) {
                        if(entry.value.creativeType.name=="MobileEmbeddedFeedback"){
                            Qualtrics.instance().displayIntercept(binding?.activity, entry.key)
                            Qualtrics.instance().setEmbeddedFeedbackDialogCloseListener {
                                _result.success("true")
                            }
                        }else {
                            entry.value.recordImpression();
                            entry.value.recordClick();
                            Qualtrics.instance().displayTarget(binding?.activity, entry.value.surveyUrl);
                            _result.success("true")
                        }
                    }
                }
            }
        }
    }
}

