import 'apptentive_terms_and_conditions.dart';

enum LogLevel { verbose, debug, info, warn, error }

// FIXME: java-doc comment
class ApptentiveConfiguration {
  final String apptentiveKey;
  final String apptentiveSignature;
  final LogLevel logLevel;
  final bool shouldEncryptStorage;
  final bool shouldSanitizeLogMessages;
  final bool troubleshootingModeEnabled;
  final bool shouldCollectAndroidIdOnPreOreoTargets;
  final ApptentiveTermsAndConditions? surveyTermsAndConditions;

  ApptentiveConfiguration(this.apptentiveKey, this.apptentiveSignature,
      {this.logLevel = LogLevel.info,
      this.shouldEncryptStorage = false,
      this.shouldSanitizeLogMessages = true,
      this.troubleshootingModeEnabled = true,
      this.shouldCollectAndroidIdOnPreOreoTargets = true,
      this.surveyTermsAndConditions});
}
