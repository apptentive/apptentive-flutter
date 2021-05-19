
import 'dart:async';

import 'package:flutter/services.dart';

class ApptentiveFlutter {
  static const MethodChannel _channel =
      const MethodChannel('apptentive_flutter');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
