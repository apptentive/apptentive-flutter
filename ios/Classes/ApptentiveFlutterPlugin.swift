import Flutter
import UIKit
import ApptentiveKit
import PhotosUI

public class ApptentiveFlutterPlugin: NSObject, FlutterApplicationLifeCycleDelegate, FlutterPlugin {

  private static let errorCode = "Apptentive Error"
  private var observation: NSKeyValueObservation?
  private let channel: FlutterMethodChannel

  // Register the method channel and plugin instance
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "apptentive_flutter", binaryMessenger: registrar.messenger())
    let instance = ApptentiveFlutterPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
  }

  // Handle the flutter method call, delegating it based on the method name
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "register": handleRegisterCall(call, result)
    case "engage": handleEngageCall(call, result)
    case "showMessageCenter": handleShowMessageCenter(call, result)
    case "canShowMessageCenter": handleCanShowMessageCenterCall(call, result)
    case "getUnreadMessageCount": handleGetUnreadMessageCount(call, result)
    case "setPersonName": handleSetPersonNameCall(call, result)
    case "setPersonEmail": handleSetPersonEmailCall(call, result)
    case "addCustomPersonData": handleAddCustomPersonDataCall(call, result)
    case "removeCustomPersonData": handleRemoveCustomPersonDataCall(call, result)
    case "addCustomDeviceData": handleAddCustomDeviceDataCall(call, result)
    case "removeCustomDeviceData": handleRemoveCustomDeviceDataCall(call, result)
    case "canShowInteraction": handleCanShowInteractionCall(call, result)
    case "setPushNotificationIntegration": handleSetPushNotificationIntegrationCall(call, result)
    case "registerListeners": handleRegisterListenersCall(call, result)
    case "sendAttachmentText": handleSendAttachmentTextCall(call, result)
    case "login": handleLoginCall(call, result)
    case "logout": handleLogoutCall(result)
    default: result(FlutterMethodNotImplemented)
    }
  }

  init(channel: FlutterMethodChannel) {
    self.channel = channel

    super.init()
  }

  deinit {
    self.observation?.invalidate()

    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - App Lifecycle Delegate Methods

  public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
    return Apptentive.shared.didReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
  }

  public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Apptentive.shared.setRemoteNotificationDeviceToken(deviceToken)
  }

  public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications with error: \(error.localizedDescription).")
  }

  public func applicationDidBecomeActive(_ application: UIApplication) {
    print("Application became active")
  }

  public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let _ = Apptentive.shared.didReceveUserNotificationResponse(response, withCompletionHandler: completionHandler)
  }

  public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let _ = Apptentive.shared.willPresent(notification, withCompletionHandler: completionHandler)
  }

  // MARK: - Apptentive Plugin Methods

  // Register the Apptentive iOS SDK
  private func handleRegisterCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let callArguments = call.arguments as? [String: Any] else {
      return result(FlutterError.init(code: Self.errorCode, message: "Expected array of strings for arguments.", details: nil))
    }

    // Get and set distribution information
    guard let distributionName = callArguments["distributionName"] as? String,
          let distributionVersion = callArguments["distributionVersion"] as? String
    else {
      return result(FlutterError.init(code: Self.errorCode, message: "Internal Apptentive Error: Missing distribution information", details: nil))
    }

    Apptentive.shared.distributionName = distributionName
    Apptentive.shared.distributionVersion = distributionVersion

    guard let (logLevel, appCredentials, apiBaseURL) = self.unpackConfiguration(callArguments["configuration"]) else {
      return result(FlutterError.init(code: Self.errorCode, message: "Missing or invalid app credentials (key/signature)", details: "Configuration is \(callArguments["configuration"] ?? "missing")"))
    }

    ApptentiveLogger.logLevel = logLevel
    let region = apiBaseURL.flatMap { ApptentiveKit.Apptentive.Region(apiBaseURL: $0) } ?? .us

    // Register Apptentive using credentials
    Apptentive.shared.register(with: appCredentials, region:region, completion: { (completionResult) -> Void in
      switch completionResult {
      case .success:
          result(true)
      case .failure(let error):
        result(FlutterError.init(code: Self.errorCode, message: "Apptentive SDK failed to register.", details: error.localizedDescription))
      }
    })
  }

  // Engage an Apptentive event with even_name, launching any valid interactions tied to the event
  private func handleEngageCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let callArguments = call.arguments as? [String: String], let eventName = callArguments["event_name"] else {
      return result(FlutterError.init(code: Self.errorCode, message: "Expected String for event name.", details: nil))
    }
    Apptentive.shared.engage(event: .init(name: eventName), from: nil, completion: { (completionResult) -> Void in
        switch completionResult {
        case .success(let success):
            result(success)
        case .failure(let error):
          result(FlutterError.init(code: Self.errorCode, message: "Apptentive event \(eventName) failed to engage.", details: error.localizedDescription))
        }
    })
  }

  // Show Message Center
  private func handleShowMessageCenter(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    Apptentive.shared.presentMessageCenter(from: nil, completion: { (completionResult) -> Void in
        switch completionResult {
        case .success(let launchedMessageCenter):
            result(launchedMessageCenter)
        case .failure(let error):
          result(FlutterError.init(code: Self.errorCode, message: "Message Center failed to present.", details: error.localizedDescription))
        }
    })
  }

  // Get the number of unread messages in Message Center
  private func handleGetUnreadMessageCount(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    result(Apptentive.shared.unreadMessageCount)
  }

  // Set person name
  private func handleSetPersonNameCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let callArguments = call.arguments as? [String: String] else {
      return result(FlutterError.init(code: Self.errorCode, message: "Expected String for person name.", details: nil))
    }

    Apptentive.shared.personName = callArguments["name"]
    result(true)
  }

  // Set person email
  private func handleSetPersonEmailCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let callArguments = call.arguments as? [String: String] else {
      return result(FlutterError.init(code: Self.errorCode, message: "Expected String for person email.", details: nil))
    }

    Apptentive.shared.personEmailAddress = callArguments["email"]
    result(true)
  }

  // Add person custom data based on key string and value of type bool, number, or string
  private func handleAddCustomPersonDataCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let (key, value) = self.convertCustomDataArguments(call.arguments) else {
      return result(FlutterError.init(code: Self.errorCode, message: "Expected String for person custom data key; Bool, Int, Double, Float or String for value.", details: nil))
    }

    Apptentive.shared.personCustomData[key] = value
    result(true)
  }

  // Remove person custom data based on key string
  private func handleRemoveCustomPersonDataCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let callArguments = call.arguments as? [String: String], let key = callArguments["key"] else {
      return result(FlutterError.init(code: Self.errorCode, message: "Expected String for person custom data key to remove.", details: nil))
    }

    Apptentive.shared.personCustomData[key] = nil
    result(true)
  }

  // Add device custom data based on key string and value of type bool, number, or string
  private func handleAddCustomDeviceDataCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let (key, value) = self.convertCustomDataArguments(call.arguments) else {
      return result(FlutterError.init(code: Self.errorCode, message: "Expected String for device custom data key; Bool, Int, Double, Float or String for value.", details: nil))
    }

    Apptentive.shared.deviceCustomData[key] = value
    result(true)
  }

  // Remove device custom data based on key string
  private func handleRemoveCustomDeviceDataCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let callArguments = call.arguments as? [String: String], let key = callArguments["key"] else {
      return result(FlutterError.init(code: Self.errorCode, message: "Expected String for custom data key to remove.", details: nil))
    }

    Apptentive.shared.deviceCustomData[key] = nil
    result(true)
  }

  // Can if an event can trigger an interaction
  private func handleCanShowInteractionCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let callArguments = call.arguments as? [String: String], let eventName = callArguments["event_name"] else {
      return result(FlutterError.init(code: Self.errorCode, message: "Expected String for event name.", details: nil))
    }

    Apptentive.shared.canShowInteraction(event: .init(name: eventName), completion: { (completionResult) -> Void in
        switch completionResult {
        case .success(let success):
            result(success)
        case .failure(let error):
          result(FlutterError.init(code: Self.errorCode, message: "Failed to check event \(eventName)", details: error.localizedDescription))
        }
    })
  }

  private func handleCanShowMessageCenterCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    print("Can Show Message Center method is not implemented.")
    result(true)
  }

  private func handleSetPushNotificationIntegrationCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    print("Push notification integration set automatically via FlutterApplicationLifeCycleDelegate.")

    UNUserNotificationCenter.current().getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .notDetermined:
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
          if granted {
            DispatchQueue.main.async {
              UIApplication.shared.registerForRemoteNotifications()
            }
          } else {
            print("Push authorization was not granted: \(error?.localizedDescription ?? "no error").")
          }
        }

      case .authorized:
        UIApplication.shared.registerForRemoteNotifications()

      default:
        print("Push authorization status is not authorized.")
        break
      }
    }
  }

  // Register Apptentive listeners
  private func handleRegisterListenersCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    self.observation = Apptentive.shared.observe(\.unreadMessageCount, options: [.new]) { _, change in
      self.channel.invokeMethod("onUnreadMessageCountChanged", arguments: ["count": change.newValue])
    }

    NotificationCenter.default.addObserver(self, selector: #selector(eventEngaged(notification:)), name: Notification.Name.apptentiveEventEngaged, object: nil)
  }

  private func handleSendAttachmentTextCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
      guard let callArguments = call.arguments as? [String: String], let message = callArguments["message"] else {
        return result(FlutterError.init(code: Self.errorCode, message: "Expected String for hidden message body.", details: nil))
      }

      Apptentive.shared.sendAttachment(message)
      result(true)
  }

  private func handleLoginCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let callArguments = call.arguments as? [String: String], let token = callArguments["token"] else {
      return result(FlutterError.init(code: Self.errorCode, message: "Expected String for token.", details: nil))
    }
    Apptentive.shared.logIn(with: token,
        completion: { (completionResult) -> Void in
              switch completionResult {
              case .success:
                  result(true)
              case .failure(let error):
                result(FlutterError.init(code: Self.errorCode, message: "Apptentive SDK failed to login.", details: error.localizedDescription))
              }
          })
    result(true)
  }

  private func handleLogoutCall(_ result: @escaping FlutterResult) {
    Apptentive.shared.logOut()
    result(true)
  }


  @objc func eventEngaged(notification: Notification) {
    guard let userInfo = notification.userInfo as? [String: String],
          let event = userInfo["eventType"]
    else {
      print("Invalid user info on event engaged notification.")
      return
    }

    switch event {
    case "com.apptentive#Survey#submit":
      self.channel.invokeMethod("onSurveyFinished", arguments: ["completed": true])

    case "com.apptentive#Survey#cancel", "com.apptentive#Survey#cancel_partial":
      self.channel.invokeMethod("onSurveyFinished", arguments: ["completed": false])

    case "com.apptentive#MessageCenter#sent":
      let sentByUser = true // TODO: get this info from event somehow.
      self.channel.invokeMethod("onMessageSent", arguments: ["sentByUser": sentByUser])

    default:
      break

    }
  }

  // MARK: - Utility Methods

  // Set ApptentiveLogger log level

  /// Sets the log level for the Apptentive SDK.
  /// - Parameter logLevel: The severity of messages that will be logged.
  private func convertLogLevel(logLevel: String?) -> LogLevel {
    switch logLevel {
    case "LogLevel.verbose": return .debug
    case "LogLevel.debug": return .info
    case "LogLevel.info": return .notice
    case "LogLevel.warn": return .warning
    case "LogLevel.error": return .critical
    case .none:
      print("")
      return .notice
    case .some(let unknownLevel):
      print("Apptentive Unknown log level: \(unknownLevel). Using .notice by default.")
      return .notice
    }
  }

  private func unpackConfiguration(_ configuration: Any?) -> (LogLevel, Apptentive.AppCredentials, URL?)? {
    guard let configuration = configuration as? [String: Any],
          let key = configuration["key"] as? String,
          let signature = configuration["signature"] as? String
    else {
      print("Missing App Credentials (key/signature) in configuration!")
      return nil
    }

    let logLevel = configuration["log_level"] as? String
    let apiBaseURL = (configuration["api_base_url"] as? String).flatMap { URL(string: $0) }
    return (self.convertLogLevel(logLevel: logLevel), .init(key: key, signature: signature), apiBaseURL)
  }

  private func convertCustomDataArguments(_ callArguments: Any?) -> (String, CustomDataCompatible)? {
    guard let callArguments = callArguments as? [String: Any],
          let value = callArguments["value"],
          let key = callArguments["key"] as? String else {
      return nil
    }

    switch value {
    case let bool as Bool:
      return (key, bool)
    case let int as Int:
      return (key, int)
    case let double as Double:
      return (key, double)
    case let float as Float:
      return (key, float)
    case let string as String:
      return (key, string)
    default:
      return nil
    }
  }
}
