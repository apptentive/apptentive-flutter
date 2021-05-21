package com.apptentive.apptentive_flutter;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.apptentive.android.sdk.Apptentive;
import com.apptentive.android.sdk.ApptentiveConfiguration;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import static com.apptentive.apptentive_flutter.PluginUtils.unpackConfiguration;

/** ApptentiveFlutterPlugin */
public class ApptentiveFlutterPlugin implements FlutterPlugin, MethodCallHandler {
  private static final String ERROR_CODE_NO_APPLICATION = "100";
  private static final String ERROR_CODE_ARGUMENT_ERROR = "200";

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  /**
   * Current application object
   */
  private @Nullable Application application;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "apptentive_flutter");
    channel.setMethodCallHandler(this);

    application = (Application) flutterPluginBinding.getApplicationContext();
    Apptentive.registerCallbacks(application);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("register")) {
      register(call, result);
    } else if (call.method.equals("showMessageCenter")) {
      showMessageCenter(call, result);
    } else if (call.method.equals("engage")) {
      engage(call, result);
    } else if (call.method.equals("canShowInteraction")) {
      canShowInteraction(call, result);
    } else if (call.method.equals("setPersonName")) {
      setPersonName(call, result);
    } else if (call.method.equals("setPersonEmail")) {
      setPersonEmail(call, result);
    } else if (call.method.equals("addCustomPersonData")) {
      addCustomPersonData(call, result);
    } else if (call.method.equals("removeCustomPersonData")) {
      removeCustomPersonData(call, result);
    } else if (call.method.equals("addCustomDeviceData")) {
      addCustomDeviceData(call, result);
    } else if (call.method.equals("removeCustomDeviceData")) {
      removeCustomDeviceData(call, result);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  //region Methods

  private void register(@NonNull MethodCall call, @NonNull Result result) {
    if (application == null) {
      result.error(ERROR_CODE_NO_APPLICATION, "Unable to register Apptentive SDK", null); // TODO: provide a better error details
      return;
    }

    @SuppressWarnings("unchecked")
    ApptentiveConfiguration configuration = unpackConfiguration((Map<String, Object>) call.argument("configuration"));
    Apptentive.register(application, configuration);
    result.success(true);
  }

  private void engage(@NonNull MethodCall call, @NonNull final Result result) {
    final String event = call.argument("event_name");
    final Map<String, Object> customData = call.argument("custom_data");

    if (application == null) {
      result.error(ERROR_CODE_NO_APPLICATION, "Unable to engage event: " + event, null); // TODO: provide a better error details
      return;
    }

    Apptentive.engage(application, event, new Apptentive.BooleanCallback() {
      @Override
      public void onFinish(boolean engaged) {
        result.success(engaged);
      }
    }, customData);
  }

  private void canShowInteraction(@NonNull MethodCall call, @NonNull final Result result) {
    if (application == null) {
      result.error(ERROR_CODE_NO_APPLICATION, "Unable to check in interaction can be shown", null); // TODO: provide a better error details
      return;
    }

    final String event = call.argument("event_name");
    Apptentive.queryCanShowInteraction(event, new Apptentive.BooleanCallback() {
      @Override
      public void onFinish(boolean showed) {
        result.success(showed);
      }
    });
  }

  private void showMessageCenter(@NonNull MethodCall call, @NonNull final Result result) {
    if (application == null) {
      result.error(ERROR_CODE_NO_APPLICATION, "Unable to show message center", null); // TODO: provide a better error details
      return;
    }

    @SuppressWarnings("unchecked")
    final Map<String, Object> customData = (Map<String, Object>) call.arguments;

    Apptentive.showMessageCenter(application, new Apptentive.BooleanCallback() {
        @Override
        public void onFinish(boolean showed) {
            result.success(showed);
        }
    }, customData);
  }

  private void setPersonName(@NonNull MethodCall call, @NonNull final Result result) {
    final String name = call.argument("name");
    Apptentive.setPersonName(name);
    result.success(true);
  }

  private void setPersonEmail(@NonNull MethodCall call, @NonNull final Result result) {
    final String email = call.argument("email");
    Apptentive.setPersonEmail(email);
    result.success(true);
  }

  private void addCustomPersonData(@NonNull MethodCall call, @NonNull final Result result) {
    final String key = call.argument("key");
    final Object value = call.argument("value");
    if (value instanceof String || value == null) {
      Apptentive.addCustomPersonData(key, (String) value);
    } else if (value instanceof Boolean) {
      Apptentive.addCustomPersonData(key, (Boolean) value);
    } else if (value instanceof Number) {
      Apptentive.addCustomPersonData(key, (Number) value);
    } else {
      result.error(
        ERROR_CODE_ARGUMENT_ERROR,
        "Unable to add custom person data for key '" + key + "': unexpected type " + value.getClass(),
        null
      );
      return;
    }
    result.success(true);
  }

  private void removeCustomPersonData(@NonNull MethodCall call, @NonNull final Result result) {
    final String key = call.argument("key");
    Apptentive.removeCustomPersonData(key);
    result.success(true);
  }

  private void addCustomDeviceData(@NonNull MethodCall call, @NonNull final Result result) {
    final String key = call.argument("key");
    final Object value = call.argument("value");
    if (value instanceof String || value == null) {
      Apptentive.addCustomDeviceData(key, (String) value);
    } else if (value instanceof Boolean) {
      Apptentive.addCustomDeviceData(key, (Boolean) value);
    } else if (value instanceof Number) {
      Apptentive.addCustomDeviceData(key, (Number) value);
    } else {
      result.error(
              ERROR_CODE_ARGUMENT_ERROR,
              "Unable to add custom device data for key '" + key + "': unexpected type " + value.getClass(),
              null
      );
      return;
    }
    result.success(true);
  }

  private void removeCustomDeviceData(@NonNull MethodCall call, @NonNull final Result result) {
    final String key = call.argument("key");
    Apptentive.removeCustomDeviceData(key);
    result.success(true);
  }

  //endregion
}
