package com.apptentive.apptentive_flutter_example

import io.flutter.embedding.android.FlutterActivity

// Implement ApptentiveActivityInfo in order to show Apptenting Interactions
// through the Apptentive Flutter Plugin
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}
