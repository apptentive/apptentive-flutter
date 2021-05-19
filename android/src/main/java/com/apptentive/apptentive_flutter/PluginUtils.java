package com.apptentive.apptentive_flutter;

import com.apptentive.android.sdk.ApptentiveConfiguration;
import com.apptentive.android.sdk.ApptentiveLog.Level;
import com.apptentive.android.sdk.module.engagement.interaction.model.TermsAndConditions;

import java.util.Map;

final class PluginUtils {
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
        if ("verbose".equals(value)) return Level.VERBOSE;
        if ("debug".equals(value)) return Level.DEBUG;
        if ("info".equals(value)) return Level.INFO;
        if ("warn".equals(value)) return Level.WARN;
        if ("error".equals(value)) return Level.ERROR;
        return Level.UNKNOWN;
    }
}
