package com.apptentive.apptentive_flutter

// TODO test push notifications

import android.app.Application
import android.app.Activity
import com.apptentive.android.sdk.Apptentive
import com.apptentive.android.sdk.ApptentiveConfiguration
import com.apptentive.android.sdk.ApptentiveLog
import com.apptentive.android.sdk.module.engagement.interaction.model.TermsAndConditions
import io.flutter.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class ApptentiveFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

  // The MethodChannel that will communicate between Flutter and native Android
  // This local reference serves to register the plugin with the Flutter Engine
  // and unregister it when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  // Current Application object
  private var application: Application? = null

  // Current Activity object
  private var activity: Activity? = null

  // Result error code
  private const val ERROR_CODE: String = "Apptentive Error"



////////// LIFECYCLE METHODS



  // When plugin is attached, set and connect method channel
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "apptentive_flutter")
    channel.setMethodCallHandler(this)
    application = flutterPluginBinding.applicationContext as Application
  }

  // Set channel method handler to null when plugin is detached
  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) { channel.setMethodCallHandler(null) }

  // When plugin is attached to an Activity, register Apptentive Activity Callback
  override fun onAttachedToActivity(binding: ActivityPluginBinding) { activity = binding.activity }

  // When re-attached to activity, set current activity context and re-register Apptentive Activity Callback
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { activity = binding.activity }

  // When detached from activity, set current activity context to null
  override fun onDetachedFromActivity() { activity = null }

  // When detached from activity, set current activity context to null
  override fun onDetachedFromActivityForConfigChanges() { activity = null }

  // Delegate the method call to the proper method
  override fun onMethodCall(call: MethodCall, result: Result) {
    if (checkIfActivityIsNull(result)) { return }
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
      "handleRequestPushPermissions" -> { /* Only iOS. */ }
      else -> result.notImplemented()
    }
  }



  ////////// APPTENTIVE PLUGIN METHODS



  // Register the Apptentive SDK by creating an Apptentive Configuration
  private fun register(call: MethodCall, result: Result) {
    val configuration = unpackConfiguration(call.argument("configuration")!!)
    try {
      Apptentive.register(application!!, configuration)
      result.success(true)
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to register Apptentive instance.", e.toString())
    }
  }

  // Engage a Where Event, launching valid interactions
  private fun engage(call: MethodCall, result: Result) {
    val event: String? = call.argument("event_name")
    if (event == null) {
      result.error(ERROR_CODE,"Unable to call event: event name is null.", null)
      return
    }
    try {
      Apptentive.engage(activity, event) { result.success(it) }
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to engage event $event.", e.toString())
    }
  }

  // Show Message Center
  private fun showMessageCenter(result: Result) {
    try {
      Apptentive.showMessageCenter(activity) { result.success(it) }
    } catch(e: Exception) {
      result.error(ERROR_CODE, "Failed to present Message Center.", e.toString())
    }
  }

  // Check if Message Center can be shown
  private fun canShowMessageCenter(call: MethodCall, result: Result) {
    try {
      Apptentive.canShowMessageCenter() { result.success(it) }
    } catch(e: Exception) {
      result.error(ERROR_CODE, "Failed to check if Apptentive can launch Message Center.", e.toString())
    }
  }

  // Check if an interaction can be shown with the event name
  private fun canShowInteraction(call: MethodCall, result: Result) {
    val event: String? = call.argument("event_name")
    if (event == null) {
      result.error(ERROR_CODE,"Unable to call event: event name is null.", null)
      return
    }
    try {
      Apptentive.queryCanShowInteraction(event) { result.success(it) }
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to check if Apptentive interaction can be show on event $event.", e.toString())
    }
  }

  // Set person name
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

  // Set person email
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

  // Add custom person data with key/value pair
  // Key: String
  // Value: String, Number, or Boolean
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

  // Remove custom person data based on String key
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

  // Add custom device data with key/value pair
  // Key: String
  // Value: String, Number, or Boolean
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

  // Remove custom device data based on String key
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

  // Set the push notification integration using a push provider string and token
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
      Apptentive.setPushNotificationIntegration(pushProvider, token)
      result.success(true)
    } catch (e: Exception) {
      result.error(ERROR_CODE, "Failed to set Apptentive push provider.", e.toString())
    }
  }

  // Return the number of unread messages in Message Center
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
      Apptentive.setOnSurveyFinishedListener { channel.invokeMethod("onSurveyFinished", mapOf("completed" to it)) }
      Apptentive.addUnreadMessagesListener { channel.invokeMethod("onUnreadMessageCountChanged", mapOf("count" to it)) }
      result.success(true)
    } catch(e: Exception) {
      result.error(ERROR_CODE, "Failed to register Apptentive listeners.", e.toString())
    }
  }



  ////////// UTIL METHODS



  // Parse log level string into Apptentive LogLevel
  // Return ApptentiveLog.Level.INFO by default
  private fun parseLogLevel(logLevelStr: String): ApptentiveLog.Level {
    if (logLevelStr.contains("verbose")) return ApptentiveLog.Level.VERBOSE
    if (logLevelStr.contains("debug")) return ApptentiveLog.Level.DEBUG
    if (logLevelStr.contains("info")) return ApptentiveLog.Level.INFO
    if (logLevelStr.contains("warn")) return ApptentiveLog.Level.WARN
    if (logLevelStr.contains("error")) return ApptentiveLog.Level.ERROR
    Log.e("Apptentive Flutter", "Unknown log level: $logLevelStr. Log level is set to .INFO by default")
    return ApptentiveLog.Level.INFO
  }

  // Turn a Map into an Apptentive Configuration
  // Suppress unchecked cast from Any? to Map<String,String>?, since we know it will be that type
  @Suppress("UNCHECKED_CAST")
  private fun unpackConfiguration(configurationMap: Map<String, Any>): ApptentiveConfiguration {
    // Key/Sig
    val key = configurationMap["key"] as String
    val signature = configurationMap["signature"] as String
    // Optional parameters
    val logLevel = parseLogLevel(configurationMap["log_level"] as String)
    val shouldEncryptStorage = configurationMap["should_encrypt_storage"] as Boolean
    val shouldSanitizeLogMessages = configurationMap["should_sanitize_log_messages"] as Boolean
    val troubleshootingModeEnabled = configurationMap["troubleshooting_mode_enabled"] as Boolean
    // val shouldCollectAndroidIdOnPreOreoTargets = configurationMap["should_collect_android_id_on_pre_oreo_targets"] as Boolean
    val surveyTermsAndConditions: TermsAndConditions? = unpackTermsAndConditions(configurationMap["terms_and_conditions"] as Map<String, String>?)

    // Create ApptentiveConfiguration object
    val configuration = ApptentiveConfiguration(key,signature)

    // Set optional parameters
    configuration.logLevel = logLevel
    configuration.setShouldEncryptStorage(shouldEncryptStorage)
    configuration.setShouldSanitizeLogMessages(shouldSanitizeLogMessages)
    configuration.isTroubleshootingModeEnabled = troubleshootingModeEnabled

    // Only add terms and conditions if they were created
    if (surveyTermsAndConditions != null) {
      configuration.surveyTermsAndConditions = surveyTermsAndConditions
    }

    // Return created configuration
    return configuration
  }

  // If activity is null, place an error into result and return true
  // Otherwise put nothing in result, return false
  private fun checkIfActivityIsNull(result: Result): Boolean {
    if (activity != null) return false
    result.error(ERROR_CODE, "Unable to call Apptentive, plugin is not bound to an Activity.", null)
    return true
  }

  // Parse push provider, throw IllegalArgumentException if invalid pushProvider String
  // Values based on PushProvider enum in '../lib/apptentive_flutter.dart'
  private fun parsePushProvider(pushProvider: String): Int {
    if (pushProvider.contains("apptentive")) { return Apptentive.PUSH_PROVIDER_APPTENTIVE }
    if (pushProvider.contains("amazon")) { return Apptentive.PUSH_PROVIDER_AMAZON_AWS_SNS }
    if (pushProvider.contains("parse")) { return Apptentive.PUSH_PROVIDER_PARSE }
    if (pushProvider.contains("urban_airship")) { return Apptentive.PUSH_PROVIDER_URBAN_AIRSHIP }
    throw IllegalArgumentException("Unknown push provider: $pushProvider")
  }

  // Unpack terms and conditions map and return a TermsAndConditions object built with it
  // Return null if no terms and conditions map provided
  private fun unpackTermsAndConditions(termsAndConditions: Map<String, String>?): TermsAndConditions? {
    if (termsAndConditions == null || termsAndConditions.isEmpty()) { return null }
    val bodyText: String = termsAndConditions["body_text"] as String
    val linkText: String = termsAndConditions["link_text"] as String
    val linkURL: String = termsAndConditions["link_url"] as String
    return TermsAndConditions(bodyText, linkText, linkURL)
  }

}
