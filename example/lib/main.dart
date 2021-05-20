import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:apptentive_flutter/apptentive_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final String apptentiveKey;
    final String apptentiveSignature;
    if (Platform.isAndroid) {
      apptentiveKey = "<YOUR_ANDROID_KEY>";
      apptentiveSignature = "<YOUR_ANDROID_SIGNATURE>";
    } else if (Platform.isAndroid) {
      apptentiveKey = "YOUR_IOS_KEY";
      apptentiveSignature = "<YOUR_IOS_SIGNATURE>";
    } else {
      // FIXME: proper error message
      return;
    }

    final ApptentiveConfiguration configuration = ApptentiveConfiguration(
        apptentiveKey: apptentiveKey,
        apptentiveSignature: apptentiveSignature,
        logLevel: LogLevel.verbose
    );
    bool successful = await ApptentiveFlutter.register(configuration);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  ApptentiveFlutter.engage(eventName: "love_dialog").then((value) {
                    if (!value) {
                      Fluttertoast.showToast(msg: "Not engaged");
                    }
                  });
                },
                child: Text('Love Dialog'),
              ),
              TextButton(
                onPressed: () {
                  ApptentiveFlutter.showMessageCenter();
                },
                child: Text('Show Message Center'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
