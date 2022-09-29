import 'dart:async';

import 'package:flutter/services.dart';

// Sets which level of logs will be printed by the Apptentive SDK
enum LogLevel { verbose, debug, info, warn, error }

// Apptentive Terms and Conditions used in the Apptentive Configuration
class ApptentiveTermsAndConditions {
  final String? bodyText;
  final String? linkText;
  final String? linkURL;

  ApptentiveTermsAndConditions({this.bodyText, this.linkText, this.linkURL});
}

// Configuration for registering the Apptentive SDK
// Filled with default values
class ApptentiveConfiguration {
  final String apptentiveKey;
  final String apptentiveSignature;
  final LogLevel logLevel;
  final bool shouldEncryptStorage;
  final bool shouldSanitizeLogMessages;
  final bool troubleshootingModeEnabled;
  final bool shouldCollectAndroidIdOnPreOreoTargets;
  final ApptentiveTermsAndConditions? surveyTermsAndConditions;
  final bool shouldShowInfoButton;
  final bool enableDebugLogFile;
  final bool gatherCarrierInfo;
  // final int ratingInteractionThrottleLength;
  // final String? customAppStoreURL;

  ApptentiveConfiguration({required this.apptentiveKey, required this.apptentiveSignature,
    this.logLevel = LogLevel.info,
    this.shouldEncryptStorage = false,
    this.shouldSanitizeLogMessages = true,
    this.troubleshootingModeEnabled = true,
    this.shouldCollectAndroidIdOnPreOreoTargets = true,
    this.surveyTermsAndConditions,
    this.shouldShowInfoButton = true,
    this.enableDebugLogFile = true,
    this.gatherCarrierInfo = true
    // this.ratingInteractionThrottleLength = 604800000,
    // this.customAppStoreURL = null
  });
}

enum PushProvider { apptentive, amazon, parse, urban_airship }

// Available callbacks
typedef SurveyFinishedCallback = void Function(bool completed);
typedef MessageCenterUnreadCountChangedNotification = void Function(int count);
typedef MessageSentNotification = void Function(String sentByUser);

// Plugin class
class ApptentiveFlutter {
  // Connect method channel and set callback handler
  static final MethodChannel _channel = const MethodChannel('apptentive_flutter')
      ..setMethodCallHandler(_nativeCallback);

  static SurveyFinishedCallback? surveyFinishedCallback;
  static MessageCenterUnreadCountChangedNotification? messageCenterUnreadCountChangedNotification;
  static MessageSentNotification? messageSentNotification;

  // Handle callbacks from Native
  static Future<dynamic> _nativeCallback(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'onSurveyFinished':
        bool completed = methodCall.arguments["completed"];
        surveyFinishedCallback?.call(completed);
        break;
      case 'onUnreadMessageCountChanged':
        int count = methodCall.arguments["count"];
        messageCenterUnreadCountChangedNotification?.call(count);
        break;
      case 'onMessageSent':
        await _channel.invokeMethod('requestPushPermissions', {});
        String sentByUser = methodCall.arguments["sentByUser"];
        messageSentNotification?.call(sentByUser);
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
    return null;
  }

  // Register the Apptentive SDK with the Apptentive Configuration
  static Future<bool> register(ApptentiveConfiguration configuration) async {
    final bool registered = await _channel.invokeMethod('register', {
      "configuration" : _packConfiguration(configuration),
      "distributionName" : "Flutter",
      "distributionVersion" : "6.0.3",
    });
    return registered;
  }

  // Engage an event and launch any valid interactions
  static Future<bool> engage({required String eventName}) async {
    final bool engaged = await _channel.invokeMethod('engage', {
      "event_name" : eventName,
    });
    return engaged;
  }

  // Returns true if an interaction can be shown on an event
  static Future<bool> canShowInteraction({required String eventName}) async {
    final bool engaged = await _channel.invokeMethod('canShowInteraction', {
      "event_name" : eventName
    });
    return engaged;
  }

  // Display the Message Center
  static Future<bool> showMessageCenter() async {
    final bool showed = await _channel.invokeMethod('showMessageCenter');
    return showed;
  }

  // Display the Message Center
  static Future<bool> canShowMessageCenter() async {
    final bool canShow = await _channel.invokeMethod('canShowMessageCenter');
    return canShow;
  }

  // Set person name
  static Future<bool> setPersonName({required String name}) async {
    final bool showed = await _channel.invokeMethod('setPersonName', {
      "name" : name
    });
    return showed;
  }

  // Set person email
  static Future<bool> setPersonEmail({required String email}) async {
    final bool showed = await _channel.invokeMethod('setPersonEmail', {
      "email" : email
    });
    return showed;
  }

  // Add custom person data
  // Key is a String
  // Value can be a String, int, double, or bool
  static Future<bool> addCustomPersonData({required String key, required dynamic value}) async {
    final bool successful = await _channel.invokeMethod('addCustomPersonData', {
      "key" : key,
      "value" : value,
    });
    return successful;
  }

  // Remove custom person data value at key
  static Future<bool> removeCustomPersonData({required String key}) async {
    final bool successful = await _channel.invokeMethod('removeCustomPersonData', {
      "key" : key
    });
    return successful;
  }

  // Add custom device data
  // Key is a String
  // Value can be a String, int, double, or bool
  static Future<bool> addCustomDeviceData({required String key, required dynamic value}) async {
    final bool successful = await _channel.invokeMethod('addCustomDeviceData', {
      "key" : key,
      "value" : value,
    });
    return successful;
  }

  // Remove custom device data value at key
  static Future<bool> removeCustomDeviceData({required String key}) async {
    final bool successful = await _channel.invokeMethod('removeCustomDeviceData', {
      "key" : key
    });
    return successful;
  }

  // Set push notification integration
  // Supported integrations defined by PushProvider enum
  static Future<bool> setPushNotificationIntegration({required PushProvider provider, required String token}) async {
    final bool successful = await _channel.invokeMethod('setPushNotificationIntegration', {
      "push_provider" : provider.toString(),
      "token" : token
    });
    return successful;
  }

  // Return the current unread message count from Message Center
  static Future<int> getUnreadMessageCount() async {
    final int count = await _channel.invokeMethod('getUnreadMessageCount', {});
    return count;
  }

  // Register callback listeners
  static Future<bool> registerListeners() async {
    final bool successful = await _channel.invokeMethod('registerListeners', {});
    return successful;
  }

  // Pack the Apptentive Configuration into a map object <String, Any>
  static Map _packConfiguration(ApptentiveConfiguration configuration) {
    return {
      "key": configuration.apptentiveKey,
      "signature": configuration.apptentiveSignature,
      "log_level": configuration.logLevel.toString(),
      "should_encrypt_storage": configuration.shouldEncryptStorage,
      "should_sanitize_log_messages": configuration.shouldSanitizeLogMessages,
      "troubleshooting_mode_enabled": configuration.troubleshootingModeEnabled,
      "terms_and_conditions": _packTermsAndConditions(configuration.surveyTermsAndConditions),
      "should_show_info_button": configuration.shouldShowInfoButton,
      "enable_debug_log_file": configuration.enableDebugLogFile,
      "gather_carrier_info": configuration.gatherCarrierInfo,
    };
  }

  // Pack the terms and conditions into a map object <String, Any>
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
