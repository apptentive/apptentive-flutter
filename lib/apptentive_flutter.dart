import 'dart:async';

import 'apptentive_terms_and_conditions.dart';
import 'apptentive_configuration.dart';

import 'package:flutter/services.dart';

class ApptentiveFlutter {
  static const MethodChannel _channel =
      const MethodChannel('apptentive_flutter');

  static Future<bool> register(ApptentiveConfiguration configuration) async {
    final bool registered = await _channel.invokeMethod('register', _packConfiguration(configuration));
    return registered;
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
