import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QualtricsDigitalFlutterPlugin {
  static const MethodChannel _channel = MethodChannel('qualtrics_digital_flutter_plugin');

  Future<Map<String, String>> initializeProject(String brandId, String projectId) async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod('initializeProject', <String, dynamic>{"brandId": brandId, "projectId": projectId});
    return result.cast<String, String>();
  }

  Future<Map<String, String>> initializeProjectWithExtRefId(String brandId, String projectId, String extRefId) async {
    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('initializeProjectWithExtRefId', <String, dynamic>{"brandId": brandId, "projectId": projectId, "extRefId": extRefId});
    return result.cast<String, String>();
  }

  Future<Map<String, Map<String, String>>> evaluateProject() async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod('evaluateProject');
    Map<String, Map<String, String>> evaluateProjectResult = HashMap();
    result.forEach((key, value) {
      Map<dynamic, dynamic> targetingResult = result[key];
      evaluateProjectResult[key] = targetingResult.cast<String, String>();
    });

    return evaluateProjectResult.cast<String, Map<String, String>>();
  }

  Future<bool> display() async {
    var displayResult = await _channel.invokeMethod('display');
    return displayResult;
  }

  Future<Map<String, String>> evaluateIntercept(String interceptId) async {
    final Map<dynamic, dynamic> evaluateInterceptResult = await _channel.invokeMethod('evaluateIntercept', <String, dynamic>{"interceptId": interceptId});
    return evaluateInterceptResult.cast<String, String>();
  }

  Future<bool> displayIntercept(String interceptId) async {
    var displayResult = await _channel.invokeMethod('displayIntercept', <String, dynamic>{"interceptId": interceptId});
    return displayResult;
  }

  Future<bool> displayTarget(String targetUrl) async {
    var displayResult = await _channel.invokeMethod('displayTarget', <String, dynamic>{"targetUrl": targetUrl});
    return displayResult;
  }

  Future<void> setLogLevel(String logLevel) async {
    await _channel.invokeMethod("setLogLevel", <String, String>{"logLevel": logLevel});
  }

  Future<void> registerViewVisit(String viewName) async {
    await _channel.invokeMethod("registerViewVisit", <String, String>{"viewName": viewName});
  }

  Future<void> resetTimer() async {
    await _channel.invokeMethod("resetTimer");
  }

  Future<void> resetViewCounter() async {
    await _channel.invokeMethod("resetViewCounter");
  }

  Future<void> setString(String key, String value) async {
    await _channel.invokeMethod("setString", <String, String>{"key": key, "value": value});
  }

  Future<void> setNumber(String key, double value) async {
    await _channel.invokeMethod("setNumber", <String, dynamic>{"key": key, "value": value});
  }

  Future<void> setDateTime(String key) async {
    await _channel.invokeMethod("setDateTime", <String, String>{"key": key});
  }

  Future<bool> qualify(BuildContext context) async {
    final String displayResult = await _channel.invokeMethod('qualify');
    return displayResult == 'true';
  }
}
