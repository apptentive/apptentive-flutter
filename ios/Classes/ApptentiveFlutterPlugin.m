#import "ApptentiveFlutterPlugin.h"

@implementation ApptentiveFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"apptentive_flutter"
            binaryMessenger:[registrar messenger]];
  ApptentiveFlutterPlugin* instance = [[ApptentiveFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"register" isEqualToString:call.method]) {
    [self handleRegisterCall:call result: result];
  } else if ([@"showMessageCenter" isEqualToString:call.method]) {
    [self handleShowMessageCenterCall:call result: result];
  } else if ([@"engage" isEqualToString:call.method]) {
    [self handleEngageCall:call result: result];
  } else if ([@"canShowInteraction" isEqualToString:call.method]) {
    [self handleCanShowInteractionCall:call result: result];
  } else if ([@"setPersonName" isEqualToString:call.method]) {
    [self handleSetPersonNameCall:call result: result];
  } else if ([@"setPersonEmail" isEqualToString:call.method]) {
    [self handleSetPersonEmailCall:call result: result];
  } else if ([@"addCustomPersonData" isEqualToString:call.method]) {
    [self handleAddCustomPersonDataCall:call result: result];
  } else if ([@"removeCustomPersonData" isEqualToString:call.method]) {
    [self handleRemoveCustomPersonDataCall:call result: result];
  } else if ([@"addCustomDeviceData" isEqualToString:call.method]) {
    [self handleAddCustomDeviceDataCall:call result: result];
  } else if ([@"removeCustomDeviceData" isEqualToString:call.method]) {
    [self handleRemoveCustomDeviceDataCall:call result: result];
  } else if ([@"login" isEqualToString:call.method]) {
    [self handleLoginCall:call result: result];
  } else if ([@"logout" isEqualToString:call.method]) {
    [self handleLogoutCall:call result: result];
  } else if ([@"setPushNotificationIntegration" isEqualToString:call.method]) {
    [self handleSetPushNotificationIntegrationCall:call result: result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)handleRegisterCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

- (void)handleShowMessageCenterCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

- (void)handleEngageCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

- (void)handleCanShowInteractionCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

- (void)handleSetPersonNameCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

- (void)handleSetPersonEmailCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

- (void)handleAddCustomPersonDataCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

- (void)handleRemoveCustomPersonDataCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

- (void)handleAddCustomDeviceDataCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

- (void)handleRemoveCustomDeviceDataCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

- (void)handleLoginCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

- (void)handleLogoutCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

- (void)handleSetPushNotificationIntegrationCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

@end
