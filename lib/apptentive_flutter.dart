import 'dart:async';

import 'package:flutter/services.dart';

// FIXME: java-doc comment
enum LogLevel { verbose, debug, info, warn, error }

// FIXME: java-doc comment
class ApptentiveTermsAndConditions {
  final String? bodyText;
  final String? linkText;
  final String? linkURL;

  ApptentiveTermsAndConditions({this.bodyText, this.linkText, this.linkURL});
}

// FIXME: java-doc comment
class ApptentiveConfiguration {
  final String apptentiveKey;
  final String apptentiveSignature;
  final LogLevel logLevel;
  final bool shouldEncryptStorage;
  final bool shouldSanitizeLogMessages;
  final bool troubleshootingModeEnabled;
  final bool shouldCollectAndroidIdOnPreOreoTargets;
  final ApptentiveTermsAndConditions? surveyTermsAndConditions;

  ApptentiveConfiguration({required this.apptentiveKey, required this.apptentiveSignature,
    this.logLevel = LogLevel.info,
    this.shouldEncryptStorage = false,
    this.shouldSanitizeLogMessages = true,
    this.troubleshootingModeEnabled = true,
    this.shouldCollectAndroidIdOnPreOreoTargets = true,
    this.surveyTermsAndConditions});
}

enum PushProvider { apptentive, amazon, parse, urban_airship }

typedef SurveyFinishedCallback = void Function(bool completed);
typedef AuthenticationFailedCallback = void Function(String reason);

class ApptentiveFlutter {
  static final MethodChannel _channel = const MethodChannel('apptentive_flutter')
      ..setMethodCallHandler(_nativeCallback);

  static SurveyFinishedCallback? surveyFinishedCallback;
  static AuthenticationFailedCallback? authenticationFailedCallback;

  static Future<dynamic> _nativeCallback(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'onSurveyFinished':
        bool completed = methodCall.arguments["completed"];
        surveyFinishedCallback?.call(completed);
        return null;
      case 'onAuthenticationFailed':
        String reason = methodCall.arguments["reason"];
        authenticationFailedCallback?.call(reason);
        return null;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  static Future<bool> register(ApptentiveConfiguration configuration) async {
    final bool registered = await _channel.invokeMethod('register', {
      "configuration" : _packConfiguration(configuration)
    });
    return registered;
  }

  static Future<bool> engage({required String eventName, Map<String, dynamic>? customData}) async {
    final bool engaged = await _channel.invokeMethod('engage', {
      "event_name" : eventName,
      "custom_data": customData,
    });
    return engaged;
  }

  static Future<bool> canShowInteraction({required String eventName}) async {
    final bool engaged = await _channel.invokeMethod('canShowInteraction', {
      "event_name" : eventName
    });
    return engaged;
  }

  static Future<bool> showMessageCenter({Map<String, dynamic>? customData}) async {
    final bool showed = await _channel.invokeMethod('showMessageCenter', customData);
    return showed;
  }

  static Future<bool> setPersonName({required String name}) async {
    final bool showed = await _channel.invokeMethod('setPersonName', {
      "name" : name
    });
    return showed;
  }

  static Future<bool> setPersonEmail({required String email}) async {
    final bool showed = await _channel.invokeMethod('setPersonEmail', {
      "email" : email
    });
    return showed;
  }

  static Future<bool> addCustomPersonData({required String key, required dynamic value}) async {
    final bool successful = await _channel.invokeMethod('addCustomPersonData', {
      "key" : key,
      "value" : value,
    });
    return successful;
  }

  static Future<bool> removeCustomPersonData({required String key}) async {
    final bool successful = await _channel.invokeMethod('removeCustomPersonData', {
      "key" : key
    });
    return successful;
  }

  static Future<bool> addCustomDeviceData({required String key, required dynamic value}) async {
    final bool successful = await _channel.invokeMethod('addCustomDeviceData', {
      "key" : key,
      "value" : value,
    });
    return successful;
  }

  static Future<bool> removeCustomDeviceData({required String key}) async {
    final bool successful = await _channel.invokeMethod('removeCustomDeviceData', {
      "key" : key
    });
    return successful;
  }

  static Future<bool> login({required String token}) async {
    final bool successful = await _channel.invokeMethod('login', {
      "token" : token
    });
    return successful;
  }

  static Future<bool> setPushNotificationIntegration({required PushProvider provider, required String token}) async {
    final bool successful = await _channel.invokeMethod('setPushNotificationIntegration', {
      "push_provider" : provider.toString(),
      "token" : token
    });
    return successful;
  }

  static Map _packConfiguration(ApptentiveConfiguration configuration) {
    return {
      "key": configuration.apptentiveKey,
      "signature": configuration.apptentiveSignature,
      "log_level": configuration.logLevel.toString(),
      "should_encrypt_storage": configuration.shouldEncryptStorage,
      "should_sanitize_log_messages": configuration.shouldSanitizeLogMessages,
      "troubleshooting_mode_enabled": configuration.troubleshootingModeEnabled,
      "should_collect_android_id_on_pre_oreo_targets": configuration.shouldCollectAndroidIdOnPreOreoTargets,
      "terms_and_conditions": _packTermsAndConditions(configuration.surveyTermsAndConditions)
    };
  }

  static Map _packTermsAndConditions(ApptentiveTermsAndConditions? conditions) {
    if (conditions != null) {
      return {
        "body_text": conditions.bodyText,
        "link_text": conditions.linkText,
        "link_url": conditions.linkURL,
      };
    }

    return {};
  }
}