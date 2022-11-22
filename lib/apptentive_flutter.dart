import 'package:alkami_core_dependencies/alkami_core_dependencies.dart';
import 'dart:async';


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

  ApptentiveConfiguration({required this.apptentiveKey, required this.apptentiveSignature,
    this.logLevel = LogLevel.info,
    this.shouldEncryptStorage = false,
    this.shouldSanitizeLogMessages = true,
    this.troubleshootingModeEnabled = true,
    this.shouldCollectAndroidIdOnPreOreoTargets = true,
    this.surveyTermsAndConditions,
    this.shouldShowInfoButton = true,
    this.enableDebugLogFile = true,
    this.gatherCarrierInfo = true});
}

enum PushProvider { apptentive, amazon, parse, urban_airship }

typedef SurveyFinishedCallback = void Function(bool completed);
typedef MessageCenterUnreadCountChangedNotification = void Function(int count);
typedef MessageSentNotification = void Function(String sentByUser);

class ApptentiveFlutter {
  static final MethodChannel _channel = const MethodChannel('apptentive_flutter')
      ..setMethodCallHandler(_nativeCallback);

  static SurveyFinishedCallback? surveyFinishedCallback;
  static MessageCenterUnreadCountChangedNotification? messageCenterUnreadCountChangedNotification;
  static MessageSentNotification? messageSentNotification;

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

  static Future<bool> setPushNotificationIntegration({required PushProvider provider, required String token}) async {
    final bool successful = await _channel.invokeMethod('setPushNotificationIntegration', {
      "push_provider" : provider.toString(),
      "token" : token
    });
    return successful;
  }

  static Future<int> getUnreadMessageCount() async {
    final int count = await _channel.invokeMethod('getUnreadMessageCount', {});
    return count;
  }

  static Future<bool> registerListeners() async {
    final bool successful = await _channel.invokeMethod('registerListeners', {});
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
      "terms_and_conditions": _packTermsAndConditions(configuration.surveyTermsAndConditions),
      "should_show_info_button": configuration.shouldShowInfoButton,
      "enable_debug_log_file": configuration.enableDebugLogFile,
      "gather_carrier_info": configuration.gatherCarrierInfo
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
