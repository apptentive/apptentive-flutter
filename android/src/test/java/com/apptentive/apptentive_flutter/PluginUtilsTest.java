package com.apptentive.apptentive_flutter;

import com.apptentive.android.sdk.ApptentiveConfiguration;
import com.apptentive.android.sdk.ApptentiveLog;
import com.apptentive.android.sdk.module.engagement.interaction.model.TermsAndConditions;

import org.junit.Test;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import static org.junit.Assert.assertTrue;

public class PluginUtilsTest {
    @Test
    public void testUnpackSimpleConfiguration() {
        final Map<String, Object> data = createData();
        final ApptentiveConfiguration actual = PluginUtils.unpackConfiguration(data);
        final ApptentiveConfiguration expected = new ApptentiveConfiguration("apptentiveKey", "apptentiveSignature");
        assertTrue(equal(expected, actual));
    }

    @Test
    public void testUnpackConfiguration1() {
        final Map<String, Object> data = createData();
        data.put("log_level", "error");
        final ApptentiveConfiguration actual = PluginUtils.unpackConfiguration(data);
        final ApptentiveConfiguration expected = new ApptentiveConfiguration("apptentiveKey", "apptentiveSignature");
        expected.setLogLevel(ApptentiveLog.Level.ERROR);
        assertTrue(equal(expected, actual));
    }

    @Test
    public void testUnpackConfiguration2() {
        final Map<String, Object> data = createData();
        data.put("should_encrypt_storage", true);
        final ApptentiveConfiguration actual = PluginUtils.unpackConfiguration(data);
        final ApptentiveConfiguration expected = new ApptentiveConfiguration("apptentiveKey", "apptentiveSignature");
        expected.setShouldEncryptStorage(true);
        assertTrue(equal(expected, actual));
    }

    @Test
    public void testUnpackConfiguration3() {
        final Map<String, Object> data = createData();
        data.put("should_sanitize_log_messages", false);
        final ApptentiveConfiguration actual = PluginUtils.unpackConfiguration(data);
        final ApptentiveConfiguration expected = new ApptentiveConfiguration("apptentiveKey", "apptentiveSignature");
        expected.setShouldSanitizeLogMessages(false);
        assertTrue(equal(expected, actual));
    }

    @Test
    public void testUnpackConfiguration4() {
        final Map<String, Object> data = createData();
        data.put("troubleshooting_mode_enabled", false);
        final ApptentiveConfiguration actual = PluginUtils.unpackConfiguration(data);
        final ApptentiveConfiguration expected = new ApptentiveConfiguration("apptentiveKey", "apptentiveSignature");
        expected.setTroubleshootingModeEnabled(false);
        assertTrue(equal(expected, actual));
    }

    @Test
    public void testUnpackConfiguration5() {
        final Map<String, Object> data = createData();
        data.put("should_collect_android_id_on_pre_oreo_targets", false);
        final ApptentiveConfiguration actual = PluginUtils.unpackConfiguration(data);
        final ApptentiveConfiguration expected = new ApptentiveConfiguration("apptentiveKey", "apptentiveSignature");
        expected.setShouldCollectAndroidIdOnPreOreoTargets(false);
        assertTrue(equal(expected, actual));
    }

    private Map<String, Object> createData() {
        final Map<String, Object> data = new HashMap<>();
        data.put("key", "apptentiveKey");
        data.put("signature", "apptentiveSignature");
        return data;
    }

    // ApptentiveConfiguration does not provide equality methods
    private static boolean equal(ApptentiveConfiguration a, ApptentiveConfiguration b) {
        return a.shouldEncryptStorage() == b.shouldEncryptStorage() &&
                a.shouldSanitizeLogMessages() == b.shouldSanitizeLogMessages() &&
                a.isTroubleshootingModeEnabled() == b.isTroubleshootingModeEnabled() &&
                a.shouldCollectAndroidIdOnPreOreoTargets() == b.shouldCollectAndroidIdOnPreOreoTargets() &&
                a.getApptentiveKey().equals(b.getApptentiveKey()) &&
                a.getApptentiveSignature().equals(b.getApptentiveSignature()) &&
                a.getLogLevel() == b.getLogLevel() &&
                equal(a.getSurveyTermsAndConditions(), b.getSurveyTermsAndConditions());
    }

    // TermsAndConditions does not provide equality methods
    private static boolean equal(TermsAndConditions a, TermsAndConditions b) {
        return a == null && b == null || (a != null && b != null &&
                Objects.equals(a.getBodyText(), b.getBodyText()) &&
                Objects.equals(a.getLinkText(), b.getLinkText()) &&
                Objects.equals(a.getLinkURL(), b.getLinkURL()));
    }
}