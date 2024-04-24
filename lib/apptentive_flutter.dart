import 'dart:async';
import 'package:flutter/services.dart';

enum LogLevel { verbose, debug, info, warn, error }

class ApptentiveConfiguration {
  final String apptentiveKey;
  final String apptentiveSignature;
  final LogLevel logLevel;
  final bool shouldInheritAppTheme;
  final bool shouldEncryptStorage;
  final bool shouldSanitizeLogMessages;
  final String distributionName;
  final String distributionVersion;
  final int ratingInteractionThrottleLength;
  final String? customAppStoreURL;

  ApptentiveConfiguration({required this.apptentiveKey, required this.apptentiveSignature,
    this.logLevel = LogLevel.info,
    this.shouldInheritAppTheme = true,
    this.shouldEncryptStorage = false,
    this.shouldSanitizeLogMessages = true,
    this.distributionName = "Flutter",
    this.distributionVersion = "6.7.0",
    this.ratingInteractionThrottleLength = 604800000, // 1 week
    this.customAppStoreURL
  });
}

enum PushProvider { apptentive, amazon, parse, urban_airship }

// Available callbacks
typedef SurveyFinishedCallback = void Function(bool completed);
typedef MessageCenterUnreadCountChangedNotification = void Function(int count);
typedef MessageSentNotification = void Function(String sentByUser);
typedef AuthenticationFailedNotification = void Function(String errorMessage);

// Plugin class
class ApptentiveFlutter {
  // Connect method channel and set callback handler
  static final MethodChannel _channel = const MethodChannel('apptentive_flutter')
      ..setMethodCallHandler(_nativeCallback);

  static SurveyFinishedCallback? surveyFinishedCallback;
  static MessageCenterUnreadCountChangedNotification? messageCenterUnreadCountChangedNotification;
  static MessageSentNotification? messageSentNotification;
  static AuthenticationFailedNotification? authenticationFailedNotification;

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
      case 'onAuthenticationFailed':
        String errorMessage = methodCall.arguments["errorMessage"];
        authenticationFailedNotification?.call(errorMessage);
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
      "distributionVersion" : "6.1.2",
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

  // Unregister callback listeners
  static Future<bool> unregisterListeners() async {
    final bool successful = await _channel.invokeMethod('unregisterListeners', {});
    return successful;
  }

  static Future<bool> sendAttachmentText({required String message}) async {
    final bool successful = await _channel.invokeMethod('sendAttachmentText', {
      "message": message
    });
    return successful;
  }

  static Future<bool> isSDKRegistered() async {
    final bool registered = await _channel.invokeMethod('isSDKRegistered', {});
    return registered;
  }

  static Future<bool> login({required String token}) async {
    final bool successful = await _channel.invokeMethod('login', {
      "token": token
    });
    return successful;
  }

  static Future<bool> logout() async {
    final bool successful = await _channel.invokeMethod('logout', {});
    return successful;
  }

  static Future<bool> updateToken({required String token}) async {
    final bool successful = await _channel.invokeMethod('updateToken', {
      "token": token
    });
    return successful;
  }

  static Future<bool> setAuthenticationFailedListener() async {
    final bool successful = await _channel.invokeMethod('setAuthenticationFailedListener', {});
    return successful;
  }

  // Pack the Apptentive Configuration into a map object <String, Any>
  static Map _packConfiguration(ApptentiveConfiguration configuration) {
    return {
      "key": configuration.apptentiveKey,
      "signature": configuration.apptentiveSignature,
      "log_level": configuration.logLevel.toString(),
      "should_inherit_theme":configuration.shouldInheritAppTheme,
      "should_encrypt_storage": configuration.shouldEncryptStorage,
      "should_sanitize_log_messages": configuration.shouldSanitizeLogMessages,
      "rating_interaction_throttle_length": configuration.ratingInteractionThrottleLength,
      "custom_app_store_url": configuration.customAppStoreURL,
      "distribution_name": configuration.distributionName,
      "distribution_version": configuration.distributionVersion
    };
  }
}
