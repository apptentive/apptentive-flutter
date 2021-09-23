#import "ApptentiveFlutterPlugin.h"

#import "ApptentiveMain.h"

inline static _Nullable id fromNullable(_Nullable id value) {
  return [value isKindOfClass:[NSNull class]] ? nil : value;
}

static BOOL parseLogLevel(NSString *value, ApptentiveLogLevel *outResult) {
  if ([@"LogLevel.verbose" isEqualToString:value]) {
    if (outResult) *outResult = ApptentiveLogLevelVerbose;
    return YES;
  }
  if ([@"LogLevel.debug" isEqualToString:value]) {
    if (outResult) *outResult = ApptentiveLogLevelDebug;
    return YES;
  }
  if ([@"LogLevel.info" isEqualToString:value]) {
    if (outResult) *outResult = ApptentiveLogLevelInfo;
    return YES;
  }
  if ([@"LogLevel.warn" isEqualToString:value]) {
    if (outResult) *outResult = ApptentiveLogLevelWarn;
    return YES;
  }
  if ([@"LogLevel.error" isEqualToString:value]) {
    if (outResult) *outResult = ApptentiveLogLevelError;
    return YES;
  }

  return NO;
}

static ApptentiveConfiguration *unpackConfiguration(NSDictionary *info) {
  NSString *apptentiveKey = info[@"key"];
  NSString *apptentiveSignature = info[@"signature"];
  ApptentiveConfiguration *configuration = [ApptentiveConfiguration configurationWithApptentiveKey:apptentiveKey apptentiveSignature:apptentiveSignature];

  // log level
  ApptentiveLogLevel logLevel;
  NSString *logLevelValue = fromNullable(info[@"log_level"]);
  if (logLevelValue != nil) {
    if (parseLogLevel(logLevelValue, &logLevel)) {
      configuration.logLevel = logLevel;
    } else {
      NSLog(@"Unknown log level: %@", logLevelValue);
    }
  }

  // Sanitize Log Messages
  id shouldSanitizeLogMessages = fromNullable(info[@"should_sanitize_log_messages"]);
  if (shouldSanitizeLogMessages != nil) {
    configuration.shouldSanitizeLogMessages = [shouldSanitizeLogMessages boolValue];
  }

  // Show Info Button
  id shouldShowInfoButton = fromNullable(info[@"should_show_info_button"]);
  if (shouldShowInfoButton != nil) {
    configuration.showInfoButton = [shouldShowInfoButton boolValue];
  }

  // Enable Debug Log File
  id enableDebugLogFile = fromNullable(info[@"enable_debug_log_file"]);
  if (enableDebugLogFile != nil) {
    configuration.enableDebugLogFile = [enableDebugLogFile boolValue];
  }

  // Gather Carrier Info
  id gatherCarrierInfo = fromNullable(info[@"gather_carrier_info"]);
  if (gatherCarrierInfo != nil) {
    configuration.gatherCarrierInfo = [gatherCarrierInfo boolValue];
  }

  // Terms and conditions
  id termsAndConditionsPacked = fromNullable(info[@"terms_and_conditions"]);
  if (termsAndConditionsPacked != nil) {
    // Unpack
    NSString *bodyText = fromNullable(termsAndConditionsPacked[@"body_text"]);
    NSString *linkText = fromNullable(termsAndConditionsPacked[@"link_text"]);
    NSURL *linkUrl = fromNullable(termsAndConditionsPacked[@"link_url"]);
    TermsAndConditions *termsAndConditions = [[TermsAndConditions alloc] initWithBodyText:bodyText linkText:linkText linkURL:linkUrl];
    configuration.surveyTermsAndConditions = termsAndConditions;
  }

  return configuration;
}

@interface NSNumber (ApptentiveBoolean)

- (BOOL)apptentive_isBoolean;

@end

@implementation NSNumber (ApptentiveBoolean)

- (BOOL)apptentive_isBoolean {
    CFTypeID boolID = CFBooleanGetTypeID();
    CFTypeID numID = CFGetTypeID((__bridge CFTypeRef)(self));
    return numID == boolID;
}

@end

@interface ApptentiveFlutterPlugin ()

@property (strong, nonatomic) FlutterMethodChannel* channel;

@end

@implementation ApptentiveFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:@"apptentive_flutter"
            binaryMessenger:[registrar messenger]];
  ApptentiveFlutterPlugin* instance = [[ApptentiveFlutterPlugin alloc] initWithChannel:channel];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
  self = [super init];

  if (self) {
    _channel = channel;
  }

  return self;
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
  ApptentiveConfiguration *configuration = unpackConfiguration(call.arguments[@"configuration"]);
  [Apptentive registerWithConfiguration:configuration];

  // Set notification listeners
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCenterUnreadCountChangedNotification:) name:ApptentiveMessageCenterUnreadCountChangedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveySentNotification:) name:ApptentiveSurveySentNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyCancelledNotification:) name:ApptentiveSurveyCancelledNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageSentNotification:) name:ApptentiveMessageSentNotification object:nil];

  [Apptentive.shared setAuthenticationFailureCallback:^void (ApptentiveAuthenticationFailureReason reason, NSString *errorMessage) {
    [self.channel invokeMethod:@"onAuthenticationFailed"
          arguments:@{
            @"reason": fromNullable(@(reason)),
            @"errorMessage": fromNullable(errorMessage),
          }
    ];
  }];

  result(@YES);
}

- (void)handleShowMessageCenterCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *customData = call.arguments;
  if (!isRegistered){
    NSLog(@"Apptentive is not initialized, cannot show Message Center.");
    result(@NO);
    return;
  }
  [Apptentive.shared presentMessageCenterFromViewController:nil
                                             withCustomData:customData
                                                 completion:^(BOOL presented) {
    result([NSNumber numberWithBool:presented]);
  }];
}

- (void)handleEngageCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *event = call.arguments[@"event_name"];
  NSDictionary *customData = fromNullable(call.arguments[@"custom_data"]);
  if (!isRegistered){
    NSLog(@"Apptentive is not initialized, cannot engage event: %@", event);
    result(@NO);
    return;
  }
  [Apptentive.shared engage:event
             withCustomData:customData
         fromViewController:nil
                 completion:^(BOOL engaged) {
    result([NSNumber numberWithBool:engaged]);
  }];
}

- (void)handleCanShowInteractionCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *event = call.arguments[@"event_name"];
  if (!isRegistered){
    NSLog(@"Apptentive is not initialized, cannot show any interactions for event: %@", event);
    result(@NO);
    return;
  }
  [Apptentive.shared queryCanShowInteractionForEvent:event completion:^(BOOL canShowInteraction) {
      result([NSNumber numberWithBool:canShowInteraction]);
  }];
}

- (void)handleSetPersonNameCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if (!isRegistered){
    NSLog(@"Apptentive is not initialized, cannot set person name.", event);
    result(@NO);
    return;
  }
  NSString *name = call.arguments[@"name"];
  [Apptentive.shared setPersonName:name];
  result(@YES);
}

- (void)handleSetPersonEmailCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if (!isRegistered){
    NSLog(@"Apptentive is not initialized, cannot set person email.");
    result(@NO);
    return;
  }
  NSString *email = call.arguments[@"email"];
  [Apptentive.shared setPersonEmailAddress:email];
  result(@YES);
}

- (void)handleAddCustomPersonDataCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *key = call.arguments[@"key"];
  id value = fromNullable(call.arguments[@"value"]);
  if ([value isKindOfClass:[NSString class]] || value == nil) {
    [Apptentive.shared addCustomPersonDataString:value withKey:key];
    result(@YES);
  } else if ([value isKindOfClass:[NSNumber class]]) {
    if ([value apptentive_isBoolean]) {
      [Apptentive.shared addCustomPersonDataBool:[value boolValue] withKey:key];
    } else {
      [Apptentive.shared addCustomPersonDataNumber:value withKey:key];
    }
    result(@YES);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)handleRemoveCustomPersonDataCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *key = call.arguments[@"key"];
  [Apptentive.shared removeCustomPersonDataWithKey:key];
  result(@YES);
}

- (void)handleAddCustomDeviceDataCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *key = call.arguments[@"key"];
  id value = fromNullable(call.arguments[@"value"]);
  if ([value isKindOfClass:[NSString class]] || value == nil) {
    [Apptentive.shared addCustomDeviceDataString:value withKey:key];
    result(@YES);
  } else if ([value isKindOfClass:[NSNumber class]]) {
    if ([value apptentive_isBoolean]) {
      [Apptentive.shared addCustomDeviceDataBool:[value boolValue] withKey:key];
    } else {
      [Apptentive.shared addCustomDeviceDataNumber:value withKey:key];
    }
    result(@YES);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)handleRemoveCustomDeviceDataCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *key = call.arguments[@"key"];
  [Apptentive.shared removeCustomDeviceDataWithKey:key];
  result(@YES);
}

- (void)handleLoginCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *token = call.arguments[@"token"];
  [Apptentive.shared logInWithToken:token
                         completion:^(BOOL success, NSError * _Nonnull error) {
    result([NSNumber numberWithBool:success]);
  }];
}

- (void)handleLogoutCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  [Apptentive.shared logOut];
  result(@YES);
}

- (void)handleSetPushNotificationIntegrationCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

// Notification Functions

- (void)messageCenterUnreadCountChangedNotification:(NSNotification *)notification {
  [self.channel invokeMethod:@"onUnreadMessageCountChanged"
        arguments:@{
          @"unreadMessages" : fromNullable(notification.userInfo[@"count"]),
        }
  ];
}

- (void)surveySentNotification:(NSNotification *)notification {
  [self.channel invokeMethod:@"onSurveyFinished"
        arguments:@{
          @"completed" : @YES,
        }
  ];
}

- (void)surveyCancelledNotification:(NSNotification *)notification {
    [self.channel invokeMethod:@"onSurveyFinished"
          arguments:@{
            @"completed" : @NO,
          }
    ];
}

- (void)messageSentNotification:(NSNotification *)notification {
  NSString * sentByUser = notification.userInfo[@"sentByUser"];
    if(!sentByUser) {
        sentByUser = @"";
    }
  [self.channel invokeMethod:@"onMessageSent"
        arguments:@{
          @"sentByUser" : sentByUser,
        }
  ];
}

- (void)onAuthenticationFailed:(NSString *)reason errorMessage:(NSString *)errorMessage {
  [self.channel invokeMethod:@"onAuthenticationFailed"
        arguments:@{
          @"reason": reason,
          @"errorMessage": errorMessage,
        }
  ];
}

- (BOOL)isRegistered {
  return Apptentive.shared.apptentiveKey != nil && Apptentive.shared.apptentiveSignature != nil;
}

@end
