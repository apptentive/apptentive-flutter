package com.apptentive.apptentive_flutter;

import com.apptentive.android.sdk.Apptentive;
import com.apptentive.android.sdk.ApptentiveConfiguration;
import com.apptentive.android.sdk.ApptentiveLog.Level;
import com.apptentive.android.sdk.module.engagement.interaction.model.TermsAndConditions;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.Map;

final class PluginUtils {
    public static Map<String, Object> map(String key, Object value) {
        Map<String, Object> map = new HashMap<>();
        map.put(key, value);
        return map;
    }

    public static String getStackTrace(Throwable t) {
        Writer writer = new StringWriter();
        t.printStackTrace(new PrintWriter(writer));
        return writer.toString();
    }

    public static int parsePushProvider(String pushProvider) {
        if (pushProvider.contains("apptentive")) {
            return Apptentive.PUSH_PROVIDER_APPTENTIVE;
        }
        if (pushProvider.contains("amazon")) {
            return Apptentive.PUSH_PROVIDER_AMAZON_AWS_SNS;
        }
        if (pushProvider.contains("parse")) {
            return Apptentive.PUSH_PROVIDER_PARSE;
        }
        if (pushProvider.contains("urban_airship")) {
            return Apptentive.PUSH_PROVIDER_URBAN_AIRSHIP;
        }

        throw new IllegalArgumentException("Unknown push provider: " + pushProvider);
    }

    public static ApptentiveConfiguration unpackConfiguration(Map<String, Object> data) {
        final String apptentiveKey = (String) data.get("key");
        final String apptentiveSignature = (String) data.get("signature");
        final Level logLevel = parseLogLevel((String) data.get("log_level"));
        final Boolean shouldEncryptStorage = (Boolean) data.get("should_encrypt_storage");
        final Boolean shouldSanitizeLogMessages = (Boolean) data.get("should_sanitize_log_messages");
        final Boolean troubleshootingModeEnabled = (Boolean) data.get("troubleshooting_mode_enabled");
        final Boolean shouldCollectAndroidIdOnPreOreoTargets = (Boolean) data.get("should_collect_android_id_on_pre_oreo_targets");
        @SuppressWarnings("unchecked") final TermsAndConditions surveyTermsAndConditions = unpackTermsAndConditions((Map<String, Object>) data.get("terms_and_conditions"));

        final ApptentiveConfiguration configuration = new ApptentiveConfiguration(apptentiveKey, apptentiveSignature);

        if (!Level.UNKNOWN.equals(logLevel)) {
            configuration.setLogLevel(logLevel);
        }
        if (shouldEncryptStorage != null) {
            configuration.setShouldEncryptStorage(shouldEncryptStorage);
        }
        if (shouldSanitizeLogMessages != null) {
            configuration.setShouldSanitizeLogMessages(shouldSanitizeLogMessages);
        }
        if (troubleshootingModeEnabled != null) {
            configuration.setTroubleshootingModeEnabled(troubleshootingModeEnabled);
        }
        if (shouldCollectAndroidIdOnPreOreoTargets != null) {
            configuration.setShouldCollectAndroidIdOnPreOreoTargets(shouldCollectAndroidIdOnPreOreoTargets);
        }
        if (surveyTermsAndConditions != null) {
            configuration.setSurveyTermsAndConditions(surveyTermsAndConditions);
        }
        return configuration;
    }

    private static TermsAndConditions unpackTermsAndConditions(Map<String, Object> data) {
        if (data != null) {
            final String bodyText = (String) data.get("body_text");
            final String linkText = (String) data.get("link_text");
            final String linkURL = (String) data.get("link_url");
            return new TermsAndConditions(bodyText, linkText, linkURL);
        }

        return null;
    }

    private static Level parseLogLevel(String value) {
        if (value.contains("verbose")) return Level.VERBOSE;
        if (value.contains("debug")) return Level.DEBUG;
        if (value.contains("info")) return Level.INFO;
        if (value.contains("warn")) return Level.WARN;
        if (value.contains("error")) return Level.ERROR;
        return Level.UNKNOWN;
    }
}
