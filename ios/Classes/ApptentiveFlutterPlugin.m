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
      NSLog(@"Apptentive: Unknown log level: %@", logLevelValue);
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

  // Set distribution information
  configuration.distributionName = @"Flutter";
  configuration.distributionVersion = @"5.7.1-rc.6";

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
@property (strong, nonatomic) NSData* deviceToken;

@end

@implementation ApptentiveFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:@"apptentive_flutter"
            binaryMessenger:[registrar messenger]];
  ApptentiveFlutterPlugin* instance = [[ApptentiveFlutterPlugin alloc] initWithChannel:channel];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
  self = [super init];

  if (self) {
    _channel = channel;
    // Register to grab new device/push token
    [[UIApplication sharedApplication] registerForRemoteNotifications];
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
  } else if ([@"getUnreadMessageCount" isEqualToString:call.method]) {
    [self handleGetUnreadMessageCount:call result: result];
  } else if ([@"registerListeners" isEqualToString:call.method]) {
    [self handleRegisterListeners:call result: result];
  } else if ([@"requestPushPermissions" isEqualToString:call.method]) {
    [self handleRequestPushPermissions:call result: result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)handleRegisterCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  ApptentiveConfiguration *configuration = unpackConfiguration(call.arguments[@"configuration"]);
  [Apptentive registerWithConfiguration:configuration];
  result(@YES);
}

- (void)handleShowMessageCenterCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *customData = call.arguments;
  if (![self isRegistered]){
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

// Set notification observers
- (void)handleRegisterListeners:(FlutterMethodCall*)call result:(FlutterResult)result {
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
}

- (void)handleEngageCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString *event = call.arguments[@"event_name"];
  NSDictionary *customData = fromNullable(call.arguments[@"custom_data"]);
  if (![self isRegistered]){
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
  if (![self isRegistered]){
    NSLog(@"Apptentive is not initialized, cannot show any interactions for event: %@", event);
    result(@NO);
    return;
  }
  [Apptentive.shared queryCanShowInteractionForEvent:event completion:^(BOOL canShowInteraction) {
      result([NSNumber numberWithBool:canShowInteraction]);
  }];
}

- (void)handleSetPersonNameCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if (![self isRegistered]){
    NSLog(@"Apptentive is not initialized, cannot set person name.");
    result(@NO);
    return;
  }
  NSString *name = call.arguments[@"name"];
  [Apptentive.shared setPersonName:name];
  result(@YES);
}

- (void)handleSetPersonEmailCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if (![self isRegistered]){
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
  // Convert the push provider into an integer using the util method
  NSInteger pushProvider = [self parsePushProvider:call.arguments[@"push_provider"]];
  // Call native register method with saved device token if token is not null
  if (_deviceToken != NULL) {
    [Apptentive.shared setPushNotificationIntegration:pushProvider withDeviceToken:_deviceToken];
    result(@YES);
  } else {
    result(@NO);
  }
}

- (NSInteger)parsePushProvider:(NSString*) pushProvider {
  if ([pushProvider containsString:@"apptentive"]) {
    return ApptentivePushProviderApptentive;
  }
  if ([pushProvider containsString:@"amazon"]) {
    return ApptentivePushProviderAmazonSNS;
  }
  if ([pushProvider containsString:@"parse"]) {
    return ApptentivePushProviderParse;
  }
  if ([pushProvider containsString:@"urban_airship"]) {
    return ApptentivePushProviderUrbanAirship;
  }
  [NSException raise:@"Apptentive Error: Unknown push provider" format:@"Push provider %@ is invalid", pushProvider];
  return -1;
}

- (void)handleGetUnreadMessageCount:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSNumber* count = [NSNumber numberWithInteger:Apptentive.shared.unreadMessageCount];
  result(count);
}

- (void)handleRequestPushPermissions:(FlutterMethodCall*)call result:(FlutterResult)result {
  UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
  [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings* _Nonnull settings) {
    switch (settings.authorizationStatus) {
      // End consumer has not seen permission dialog, show it
      case UNAuthorizationStatusNotDetermined: {
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
          if (granted) {
            [[UIApplication sharedApplication] registerForRemoteNotifications];
          }
        }];
        break;
      }
      // End consumer already accepted, register for remote notifications
      case UNAuthorizationStatusAuthorized: {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
      }
      default:
        break;
    }
  }];
}

- (void)getUnreadMessageCount:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSNumber* count = [NSNumber numberWithInteger:Apptentive.shared.unreadMessageCount];
  result(count);
}

- (void)getUnreadMessageCount:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSNumber* count = [NSNumber numberWithInteger:Apptentive.shared.unreadMessageCount];
  result(count);
}

// Notification Functions

- (void)messageCenterUnreadCountChangedNotification:(NSNotification *)notification {
  [self.channel invokeMethod:@"onUnreadMessageCountChanged"
        arguments:@{
          @"count" : fromNullable(notification.userInfo[@"count"]),
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

// Because Apptentive.shared is not the delegate, pass data into its internal functions for push handling
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
  [Apptentive.shared userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
}

// Because Apptentive.shared is not the delegate, pass data into its internal functions for push handling
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
  [Apptentive.shared userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
}

// Save the device token after registering for remote notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    self.deviceToken = deviceToken;
}

// Tell Native Apptentive to handle the notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result)) completionHandler {
  [Apptentive.shared didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

// Log the error if registering deviceCustomDataRemoverTester notifications failed
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"Apptentive Error: Failed to register for remote notifications with error: %@", [error localizedDescription]);
}

@end
