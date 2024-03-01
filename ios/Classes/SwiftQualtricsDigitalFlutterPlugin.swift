import Flutter
import UIKit
import Qualtrics

public class SwiftQualtricsDigitalFlutterPlugin: NSObject, FlutterPlugin {
    var flutterSDKProperty = "Qualtrics_IS_FLUTTER"
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "qualtrics_digital_flutter_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftQualtricsDigitalFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initializeProject":
            handleInitializeProject(call, result: result)
            break
        case "initializeProjectWithExtRefId":
            handleInitializeProjectWithExtRefId(call, result: result)
            break
        case "evaluateProject":
            handleEvaluateProject(call, result: result)
            break
        case "evaluateIntercept":
            handleEvaluateIntercept(call, result: result)
            break
        case "display":
            handleDisplay(call, result: result)
            break
        case "displayIntercept":
            handleDisplayIntercept(call, result: result)
            break
        case "displayTarget":
            handleDisplayTarget(call, result: result)
            break
        case "setNumber":
            handleSetNumber(call)
            break
        case "setString":
            handleSetString(call)
            break
        case "setDateTime":
            handleSetDateTime(call)
            break
        case "registerViewVisit":
            handleRegisterViewVisit(call)
            break
        case "resetTimer":
            Qualtrics.shared.resetTimer()
            break
        case "resetViewCounter":
            Qualtrics.shared.resetViewCounter()
            break
        case "qualify":
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                result("false")
                return
            }
            Qualtrics.shared.evaluateProject { (targetingResults) in
                for (_, targetResult) in targetingResults {
                    if targetResult.passed() {
                        if(targetResult.getCreativeType()=="MobileEmbeddedFeedback"){
                            _ = Qualtrics.shared.display(viewController: rootViewController)
                            Qualtrics.shared.setEmbeddedFeedbackDialogCloseListener(listener: {
                                result("true")
                            })
                        }else{
                            if targetResult.passed(), let url = targetResult.getSurveyUrl() {
                                Qualtrics.shared.displayTarget(targetViewController: rootViewController, targetUrl: url ?? "")
                                result("true")
                            }
                        }
                    }
                }
            }
        default:
            result("Error")
        }
    }
    func handleInitializeProject(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let data = call.arguments as? Dictionary<String, Any>
        let brandId = data?["brandId"] as? String
        let projectId = data?["projectId"] as? String
        var initResultDict: [String:String] = [:]
        Qualtrics.shared.properties.setString(string: flutterSDKProperty, for: "true")
        Qualtrics.shared.initializeProject(brandId: brandId!, projectId:projectId!) { initializationResults in
            for (interceptId, initResult) in initializationResults {
                initResultDict[interceptId] = String(initResult.passed())
            }
            result(initResultDict)
        }
    }
    func handleInitializeProjectWithExtRefId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let data = call.arguments as? Dictionary<String, Any>
        let brandId = data?["brandId"] as? String
        let projectId = data?["projectId"] as? String
        let extRefId = data?["extRefId"] as? String
        var initResultDict: [String:String] = [:]
        Qualtrics.shared.properties.setString(string: flutterSDKProperty, for: "true")
        Qualtrics.shared.initializeProject(brandId: brandId!, projectId:projectId!, extRefId: extRefId) { initializationResults in
            for (interceptId, initResult) in initializationResults {
                initResultDict[interceptId] = String(initResult.passed())
            }
            result(initResultDict)
        }
    }
    func handleEvaluateProject(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        var evaluateProjectResult: [String:[String:String]] = [:]
        Qualtrics.shared.evaluateProject(completion: {(targetingResults: [String:TargetingResult]) -> Void in
            for(interceptId, targetingResult) in targetingResults {
                var individualResult: [String: String] = [:]
                individualResult["passed"] = String(targetingResult.passed())
                individualResult["surveyUrl"] = targetingResult.getSurveyUrl() != nil ? targetingResult.getSurveyUrl() : "null"
                individualResult["creativeType"] = targetingResult.getCreativeType() != nil ? targetingResult.getCreativeType() : "null"
                individualResult["error"] = targetingResult.getError() != nil ? targetingResult.getError().debugDescription : "null"
                evaluateProjectResult[interceptId] = individualResult
            }
            result(evaluateProjectResult)
        })
    }
    func handleEvaluateIntercept(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let data = call.arguments as? Dictionary<String, Any>
        let interceptId = data?["interceptId"] as? String
        var evaluateInterceptResult: [String:String] = [:]
        Qualtrics.shared.evaluateIntercept(for: interceptId ?? "", completion: {(targetingResult:TargetingResult) -> Void in
            evaluateInterceptResult["interceptId"] = interceptId
            evaluateInterceptResult["passed"] = String(targetingResult.passed())
            evaluateInterceptResult["surveyUrl"] = targetingResult.getSurveyUrl() != nil ? targetingResult.getSurveyUrl() : "null"
            evaluateInterceptResult["creativeType"] = targetingResult.getCreativeType() != nil ? targetingResult.getCreativeType() : "null"
            evaluateInterceptResult["error"] = targetingResult.getError() != nil ? targetingResult.getError().debugDescription : "null"
            result(evaluateInterceptResult)
        })
    }
    func handleDisplay(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            result(false)
            return
        }
        let displayResult = Qualtrics.shared.display(viewController: rootViewController)
        result(displayResult)
    }
    
    func handleDisplayIntercept(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            result(false)
            return
        }
        let data = call.arguments as? Dictionary<String, Any>
        let interceptId = data?["interceptId"] as? String
        let displayResult = Qualtrics.shared.displayIntercept(for: interceptId ?? "", viewController: rootViewController)
        result(displayResult)
    }
    
    func handleDisplayTarget(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            result(false)
            return
        }
        let data = call.arguments as? Dictionary<String, Any>
        let targetUrl = data?["targetUrl"] as? String
        Qualtrics.shared.displayTarget(targetViewController: rootViewController, targetUrl: targetUrl ?? "")
        result(true)
    }
    
    func handleRegisterViewVisit(_ call: FlutterMethodCall) {
        let data = call.arguments as? Dictionary<String, Any>
        let viewName = data?["viewName"] as? String
        Qualtrics.shared.registerViewVisit(viewName: viewName ?? "")
    }
    
    func handleSetString(_ call: FlutterMethodCall) {
        let data = call.arguments as? Dictionary<String, Any>
        let key = data?["key"] as? String
        let value = data?["value"] as? String
        Qualtrics.shared.properties.setString(string: value ?? "", for: key ?? "")
    }
    func handleSetNumber(_ call: FlutterMethodCall) {
        let data = call.arguments as? Dictionary<String, Any>
        let key = data?["key"] as? String
        let value = data?["value"] as? Double
        Qualtrics.shared.properties.setNumber(number: value ?? 0, for: key ?? "")
    }
    func handleSetDateTime(_ call: FlutterMethodCall) {
        let data = call.arguments as? Dictionary<String, Any>
        let key = data?["key"] as? String
        Qualtrics.shared.properties.setDateTime(for: key ?? "")
    }
}