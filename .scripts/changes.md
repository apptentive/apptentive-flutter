- Apptentive Android SDK: 7.4.0
- Apptentive iOS SDK: 7.4.0

### New & Improved
- The `Region.ca` (Canada) region now works on iOS; previously it silently fell back to US because ApptentiveKit did not support it (it already worked on Android)
- The SDK can now be remotely disabled (kill switch)
- Interaction throttling is now configured from the server
- The Dart SDK constraint is updated to `>=3.5.0 <4.0.0` to match the minimum supported Flutter version (3.24)
