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

class ApptentiveFlutter {
  static const MethodChannel _channel =
      const MethodChannel('apptentive_flutter');

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
