package com.apptentive.apptentive_flutter

// TODO test push notifications

import android.app.Activity
import android.app.Application
import apptentive.com.android.feedback.*
import apptentive.com.android.feedback.model.EventNotification
import apptentive.com.android.feedback.model.MessageCenterNotification
import apptentive.com.android.util.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


@OptIn(InternalUseOnly::class)
class ApptentiveFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

  // The MethodChannel that will communicate between Flutter and native Android
  // This local reference serves to register the plugin with the Flutter Engine
  // and unregister it when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var application: Application
  private var activity: Activity? = null
  private val ERROR_CODE: String = "Apptentive Error"
  private var isApptentiveRegistered: Boolean = false


  private val activityInfo = object : ApptentiveActivityInfo {
    override fun getApptentiveActivityInfo(): Activity? {
      if (activity == null) {
        Log.e(LogTag("Flutter"), "Activity should not be null")
      }
      return activity
    }
  }

  //region lifecycle methods

  // When plugin is attached, set and connect method channel
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "apptentive_flutter")
    channel.setMethodCallHandler(this)
    application = flutterPluginBinding.applicationContext as Application
  }

  // Set channel method handler to null when plugin is detached
  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // When plugin is attached to an Activity, register Apptentive Activity Callback
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity

    if (isApptentiveRegistered) {
      Apptentive.registerApptentiveActivityInfoCallback(activityInfo)
    }
  }

  // When re-attached to activity, set current activity context and re-register Apptentive Activity Callback
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    Apptentive.registerApptentiveActivityInfoCallback(activityInfo)

    Log.d(LogTag("Flutter"), "register ApptentiveActivityInfoCallback on onReattachedToActivityForConfigChanges")
  }

  // When detached from activity, set current activity context to null
  override fun onDetachedFromActivity() {
    activity = null
    Apptentive.unregisterApptentiveActivityInfoCallback()

    Log.d(LogTag("Flutter"), "unregister ApptentiveActivityInfoCallback onDetachedFromActivity")
  }

  // When detached from activity, set current activity context to null
  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
    Apptentive.unregisterApptentiveActivityInfoCallback()

    Log.d(LogTag("Flutter"), "unregister ApptentiveActivityInfoCallback onDetachedFromActivity")
  }

  // Delegate the method call to the proper method
  override fun onMethodCall(call: MethodCall, result: Result) {
    if (checkIfActivityIsNull(result)) return
    else Apptentive.registerApptentiveActivityInfoCallback(activityInfo)

    when (call.method) {
      "register" -> register(call, result)
      "engage" -> engage(call, result)
      "showMessageCenter" -> showMessageCenter(result)
      "canShowMessageCenter" -> canShowMessageCenter(result)
      "canShowInteraction" -> canShowInteraction(call, result)
      "setPersonName" -> setPersonName(call, result)
      "setPersonEmail" -> setPersonEmail(call, result)
      "addCustomPersonData" -> addCustomPersonData(call, result)
      "removeCustomPersonData" -> removeCustomPersonData(call, result)
      "addCustomDeviceData" -> addCustomDeviceData(call, result)
      "removeCustomDeviceData" -> removeCustomDeviceData(call, result)
      "setPushNotificationIntegration" -> setPushNotificationIntegration(call, result)
      "getUnreadMessageCount" -> getUnreadMessageCount(result)
      "registerListeners" -> registerListeners(result)
      "unregisterListeners" -> unregisterListeners(result)
      "sendAttachmentText" -> sendAttachmentText(call, result)
      "handleRequestPushPermissions" -> { /* Only iOS. */ }
      else -> result.notImplemented()
    }
  }
// endregion

// region Apptentive plugin methods

  private fun register(call: MethodCall, result: Result) {
    val configuration = unpackConfiguration(call.argument("configuration")!!)
    try {
      Apptentive.register(application, configuration) { registerResult ->
        if (registerResult is RegisterResult.Success) {
          isApptentiveRegistered = true
          Log.d(LogTag("Flutter"), "register ApptentiveActivityInfoCallback")
          Apptentive.registerApptentiveActivityInfoCallback(activityInfo)
        }
        result.success(registerResult is RegisterResult.Success)
      }
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to register Apptentive instance.", e.toString())
    }
  }

  private fun engage(call: MethodCall, result: Result) {
    val event: String? = call.argument("event_name")
    if (event == null) {
      result.error(ERROR_CODE,"Unable to call event: event name is null.", null)
      return
    }
    try {
      Apptentive.engage(event) { engagementResult ->
        if (engagementResult is EngagementResult.InteractionShown) result.success(true)
        else result.success(false)
      }
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to engage event $event.", e.toString())
    }
  }

  // Show Message Center
  private fun showMessageCenter(result: Result) {
    try {
      Apptentive.showMessageCenter { result.success(it is EngagementResult.InteractionShown) }
    } catch(e: Exception) {
      result.error(ERROR_CODE, "Failed to present Message Center.", e.toString())
    }
  }

  // Check if Message Center can be shown
  private fun canShowMessageCenter(result: Result) {
    try {
      Apptentive.canShowMessageCenter { result.success(it) }
    } catch(e: Exception) {
      result.error(ERROR_CODE, "Failed to check if Apptentive can launch Message Center.", e.toString())
    }
  }

  private fun canShowInteraction(call: MethodCall, result: Result) {
    val event: String? = call.argument("event_name")
    if (event == null) {
      result.error(ERROR_CODE,"Unable to call event: event name is null.", null)
      return
    }
    try {
      val canShowInteraction = Apptentive.canShowInteraction(event)
      result.success(canShowInteraction)
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to check if Apptentive interaction can be show on event $event.", e.toString())
    }
  }

  private fun setPersonName(call: MethodCall, result: Result) {
    val name: String? = call.argument("name")
    if (name == null) {
      result.error(ERROR_CODE, "Failed to set person name with null value.", null)
      return
    }
    try {
      Apptentive.setPersonName(name)
      result.success(true)
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to set person name.", e.toString())
    }
  }

  private fun setPersonEmail(call: MethodCall, result: Result) {
    val email: String? = call.argument("email")
    if (email == null) {
      result.error(ERROR_CODE, "Failed to set person email with null value.", null)
      return
    }
    try {
      Apptentive.setPersonEmail(email)
      result.success(true)
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to set person email.", e.toString())
    }
  }

  private fun addCustomPersonData(call: MethodCall, result: Result) {
    val key: String? = call.argument("key")
    if (key == null) {
      result.error(ERROR_CODE, "Failed to add custom data with null key.", null)
      return
    }
    when (val value: Any? = call.argument("value")) {
      is Number -> Apptentive.addCustomPersonData(key, value)
      is Boolean -> Apptentive.addCustomPersonData(key, value)
      is String -> Apptentive.addCustomPersonData(key, value)
      else -> {
        // Unsupported type provided
        result.error(ERROR_CODE, "Unable to add custom person data for key $key: Unexpected type: ${value!!::class.simpleName}", null)
        return
      }
    }
    result.success(true)
  }

  private fun removeCustomPersonData(call: MethodCall, result: Result) {
    val key: String? = call.argument("key")
    if (key == null) {
      result.error(ERROR_CODE, "Failed to remove custom person data with null key.", null)
      return
    }
    try {
      Apptentive.removeCustomPersonData(key)
      result.success(true)
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to remove custom person data $key.", e.toString())
    }
  }

  private fun addCustomDeviceData(call: MethodCall, result: Result) {
    val key: String? = call.argument("key")
    if (key == null) {
      result.error(ERROR_CODE, "Failed to add custom data with null key.", null)
      return
    }
    when (val value: Any? = call.argument("value")) {
      is Number -> Apptentive.addCustomDeviceData(key, value)
      is Boolean -> Apptentive.addCustomDeviceData(key, value)
      is String -> Apptentive.addCustomDeviceData(key, value)
      else -> {
        // Unsupported type provided
        result.error(ERROR_CODE, "Unable to add custom device data for key $key: Unexpected type: ${value!!::class.simpleName}",null)
        return
      }
    }
    result.success(true)
  }

  private fun removeCustomDeviceData(call: MethodCall, result: Result) {
    val key: String? = call.argument("key")
    if (key == null) {
      result.error(ERROR_CODE, "Failed to remove custom device data with null key.", null)
      return
    }
    try {
      Apptentive.removeCustomDeviceData(key)
      result.success(true)
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to remove custom device data $key.", e.toString())
    }
  }

  private fun setPushNotificationIntegration(call: MethodCall, result: Result) {
    val pushProviderCode: String? = call.argument("push_provider")
    val token: String? = call.argument("token")
    if (token == null) {
      result.error(ERROR_CODE, "Unable to set push provider: Device token is null.", null)
      return
    }
    if (pushProviderCode == null ) {
      result.error(ERROR_CODE, "Unable to set push provider: Push provider code is null.", null)
      return
    }
    val pushProvider: Int = parsePushProvider(pushProviderCode)
    try {
      Apptentive.setPushNotificationIntegration(application, pushProvider, token)
      result.success(true)
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to set Apptentive push provider.", e.toString())
    }
  }

  private fun sendAttachmentText(call: MethodCall, result: Result) {
    val message: String? = call.argument("message")

    if (message == null || message.isEmpty()) {
      result.error(ERROR_CODE, "Unable to send the attachment text: The message body is null or empty", null)
      return
    }

    try {
      Apptentive.sendAttachmentText(message)
      result.success(true)
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to send attachment text", e.toString())
    }
  }

  private fun getUnreadMessageCount(result: Result) {
    try {
      val unreadMessages: Int = Apptentive.getUnreadMessageCount()
      result.success(unreadMessages)
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to check number of unread messages in Message Center.", e.toString())
    }
  }

  // Register listeners for native callbacks:
  private fun registerListeners(result: Result) {
    try {
      Apptentive.eventNotificationObservable.observe(::surveyFinishedObserver)
      Apptentive.messageCenterNotificationObservable.observe(::messageObserver)
      result.success(true)
    } catch(e: Exception) {
      result.error(ERROR_CODE, "Failed to register Apptentive listeners.", e.toString())
    }
  }

  private fun unregisterListeners(result: Result) {
    try {
      Apptentive.eventNotificationObservable.removeObserver(::surveyFinishedObserver)
      Apptentive.messageCenterNotificationObservable.removeObserver(::messageObserver)
      result.success(true)
    } catch(e: Exception) {
      result.error(ERROR_CODE, "Failed to unregister Apptentive listeners.", e.toString())
    }
  }

  private fun surveyFinishedObserver(notification: EventNotification?) {
    val name = notification?.name
    val interaction = notification?.interaction
    val vendor = notification?.vendor
    val interactionId = notification?.interactionId
    val notificationText = "Name: \"$name\". Vendor: \"$vendor\". " +
            "Interaction: \"$interaction\". Interaction ID: $interactionId"
    Log.d(LogTags.EVENT_NOTIFICATION, notificationText)
    when {
      interaction == "Survey" && name == "submit" ->
        activity?.runOnUiThread {
          channel.invokeMethod("onSurveyFinished", mapOf("completed" to true))
        }

      interaction == "Survey" && name == "cancel" || name == "cancel_partial" ->
        activity?.runOnUiThread {
          channel.invokeMethod("onSurveyFinished", mapOf("completed" to false))
        }
    }
  }

  private fun messageObserver(notification: MessageCenterNotification?) {
    val notificationText =
      "Can Show Message Center: ${notification?.canShowMessageCenter}. " +
              "Unread Message Count: ${notification?.unreadMessageCount}. " +
              "Person Name: ${notification?.personName}. " +
              "Person Email: ${notification?.personEmail}"

    Log.d(LogTags.MESSAGE_CENTER_NOTIFICATION, notificationText)
    if (notification?.unreadMessageCount != 0) {
      activity?.runOnUiThread {
        channel.invokeMethod("onUnreadMessageCountChanged", mapOf("count" to notification?.unreadMessageCount))
      }
    }
  }

  // endregion

  // region Utils

  private fun parseLogLevel(logLevelStr: String): LogLevel {
    return when {
        logLevelStr.contains("verbose") -> LogLevel.Verbose
        logLevelStr.contains("debug") -> LogLevel.Debug
        logLevelStr.contains("info") -> LogLevel.Info
        logLevelStr.contains("warn") -> LogLevel.Warning
        logLevelStr.contains("error") -> LogLevel.Error
        else -> {
          Log.w(LogTag("Flutter LogLevel"),
            "Unknown log level: $logLevelStr. Log level is set to .INFO by default")
          LogLevel.Info
        }
    }
  }

  // Turn a Map into an Apptentive Configuration
  @Suppress("UNCHECKED_CAST")
  private fun unpackConfiguration(configurationMap: Map<String, Any>): ApptentiveConfiguration {
    val key = configurationMap["key"] as String
    val signature = configurationMap["signature"] as String
    val logLevel = parseLogLevel(configurationMap["log_level"] as String)
    val shouldInheritAppTheme = configurationMap["should_inherit_theme"] as Boolean
    val shouldEncryptStorage = configurationMap["should_encrypt_storage"] as Boolean
    val shouldSanitizeLogMessages = configurationMap["should_sanitize_log_messages"] as Boolean
    val ratingInteractionThrottleLength = (configurationMap["rating_interaction_throttle_length"] as Int).toLong()
    val customAppStoreURL = configurationMap["custom_app_store_url"] as String?
    val distributionName = configurationMap["distribution_name"] as String
    val distributionVersion = configurationMap["distribution_version"] as String

    val configuration = ApptentiveConfiguration(key,signature)

    configuration.logLevel = logLevel
    configuration.shouldInheritAppTheme = shouldInheritAppTheme
    configuration.shouldEncryptStorage = shouldEncryptStorage
    configuration.shouldSanitizeLogMessages = shouldSanitizeLogMessages
    configuration.ratingInteractionThrottleLength = ratingInteractionThrottleLength
    configuration.customAppStoreURL = customAppStoreURL
    configuration.distributionName = distributionName
    configuration.distributionVersion = distributionVersion

    return configuration
  }

  private fun checkIfActivityIsNull(result: Result): Boolean {
    if (activity != null) return false
    result.error(ERROR_CODE, "Unable to call Apptentive, plugin is not bound to an Activity.", null)
    return true
  }

  // Values based on PushProvider enum in '../lib/apptentive_flutter.dart'
  private fun parsePushProvider(pushProvider: String): Int {
    when {
        pushProvider.contains("apptentive") -> { return Apptentive.PUSH_PROVIDER_APPTENTIVE }
        pushProvider.contains("amazon") -> { return Apptentive.PUSH_PROVIDER_AMAZON_AWS_SNS }
        pushProvider.contains("parse") -> { return Apptentive.PUSH_PROVIDER_PARSE }
        pushProvider.contains("urban_airship") -> { return Apptentive.PUSH_PROVIDER_URBAN_AIRSHIP }
        else -> throw IllegalArgumentException("Unknown push provider: $pushProvider")
    }
  }
  // endregion
}




