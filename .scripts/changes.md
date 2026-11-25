- Apptentive Android SDK: 7.4.0
- Apptentive iOS SDK: 7.4.0

### New & Improved
- The `Region.ca` (Canada) region now works on iOS; previously it silently fell back to US because ApptentiveKit did not support it (it already worked on Android)
- The SDK can now be remotely disabled (kill switch)
- Interaction throttling is now configured from the server
- The Dart SDK constraint is updated to `>=3.5.0 <4.0.0` to match the minimum supported Flutter version (3.24)
* Fixed a crash on Android when an Apptentive Activity is resumed.
* Fixed Survey edge-to-edge layout issues on Android 15/16.
* Fixed EnjoymentDialog#dismiss being incorrectly sent on device rotation while the Love Dialog remains open.
* Fixed links in Prompt (Note) title and content not being tappable.
* Fixed links in Card Survey introduction and question text not being tappable.
