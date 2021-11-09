import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:apptentive_flutter/apptentive_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    } else if (Platform.isIOS) {
      apptentiveKey = "<YOUR_IOS_KEY>";
      apptentiveSignature = "<YOUR_IOS_SIGNATURE>";
    } else {
      String os = Platform.operatingSystem;
      print("E Apptentive: Platform not supported for Apptentive Flutter Plugin: ${os}. Apptentive failed to initialize.");
      return;
    }

    final ApptentiveConfiguration configuration = ApptentiveConfiguration(
        apptentiveKey: apptentiveKey,
        apptentiveSignature: apptentiveSignature,
        logLevel: LogLevel.verbose,
        shouldEncryptStorage: false,
        shouldSanitizeLogMessages: false,
        troubleshootingModeEnabled: true,
        shouldCollectAndroidIdOnPreOreoTargets: true,
        shouldShowInfoButton: true,
        enableDebugLogFile: true,
        gatherCarrierInfo: true
    );
    ApptentiveFlutter.surveyFinishedCallback = (bool completed) {
      print("Survey Finished?: ${completed}");
    };
    ApptentiveFlutter.authenticationFailedCallback = (String reason, String errorMessage) {
      print("Authentication failed because due to following reason: ${reason} Error message: ${errorMessage}");
    };
    ApptentiveFlutter.messageCenterUnreadCountChangedNotification = (int count) {
      print("Message Center unread message count is now: ${count}");
    };
    ApptentiveFlutter.messageSentNotification = (String sentByUser) {
      print("Message sent by user: " + sentByUser);
    };
    bool successful = await ApptentiveFlutter.register(configuration);

    // Set callback/notification functions
    if (successful) {

    }

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

              eventTester(context),

              personCustomDataTester(context),

              personCustomDataRemoverTester(context),

              deviceCustomDataTester(context),

              deviceCustomDataRemoverTester(context),

              person(context),

              OutlinedButton(
                onPressed: () {
                  ApptentiveFlutter.showMessageCenter();
                },
                child: Text('Show Message Center'),
              ),

              OutlinedButton(
                onPressed: () {
                  ApptentiveFlutter.getUnreadMessageCount().then((count) {
                    print("Unread Message Count: $count");
                  });
                },
                child: Text('Print Unread Message Count'),
              ),

              OutlinedButton(
                onPressed: () {
                  ApptentiveFlutter.registerListeners();
                },
                child: Text('Register Listeners'),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget eventTester(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: editText(
        hint: "Where Event",
        onSubmit: (eventName) async {
          ApptentiveFlutter.engage(eventName: eventName).then((value) {
            if (!value) {
              Fluttertoast.showToast(msg: "Not engaged");
            } else {
              Fluttertoast.showToast(msg: "${eventName} engaged!");
            }
          });
        },
        buttonText: "Engage"
      ),
    );
  }

  Widget personCustomDataTester(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: doubleEditText(
        hint: "Person Data Name",
        hint2: "Person Data Value",
        onSubmit: (personCustomDataMap) async {
          ApptentiveFlutter.addCustomPersonData(key: personCustomDataMap["name"]!, value: personCustomDataMap["value"]!).then((value) {
            if (!value) {
              Fluttertoast.showToast(msg: "Person Custom Data Not Added");
            } else {
              Fluttertoast.showToast(msg: "Person Custom Data Added!");
            }
          });
        },
        buttonText: "Add"
      )
    );
  }

  Widget personCustomDataRemoverTester(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: editText(
        hint: "Person Custom Data To Remove",
        onSubmit: (personCustomDataName) async {
          ApptentiveFlutter.removeCustomPersonData(key: personCustomDataName).then((value) {
            if (!value) {
              Fluttertoast.showToast(msg: "Custom Person Data Not Removed");
            } else {
              Fluttertoast.showToast(msg: "Custom Person Data Removed!");
            }
          });
        },
        buttonText: "Remove"
      )
    );
  }

  Widget deviceCustomDataTester(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: doubleEditText(
        hint: "Device Data Name",
        hint2: "Device Data Value",
        onSubmit: (deviceCustomDataMap) async {
          ApptentiveFlutter.addCustomDeviceData(key: deviceCustomDataMap["name"]!, value: deviceCustomDataMap["value"]!).then((value) {
            if (!value) {
              Fluttertoast.showToast(msg: "Device Custom Data Not Added");
            } else {
              Fluttertoast.showToast(msg: "Device Custom Data Added!");
            }
          });
        },
        buttonText: "Add"
      )
    );
  }

  Widget deviceCustomDataRemoverTester(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: editText(
        hint: "Device Custom Data To Remove",
        onSubmit: (deviceCustomDataName) async {
          ApptentiveFlutter.removeCustomDeviceData(key: deviceCustomDataName).then((value) {
            if (!value) {
              Fluttertoast.showToast(msg: "Custom Device Data Not Removed");
            } else {
              Fluttertoast.showToast(msg: "Custom Device Data Removed!");
            }
          });
        },
        buttonText: "Remove"
      )
    );
  }

  Widget person(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          editText(
            hint: "Person name",
            onSubmit: (name) async {
              ApptentiveFlutter.setPersonName(name: name);
            },
            buttonText: "Update"
          ),
          editText(
              hint: "Person email",
              onSubmit: (email) async {
                ApptentiveFlutter.setPersonEmail(email: email);
              },
              buttonText: "Update"
          ),
        ],
      ),
    );
  }

  Widget editText({required String hint, required AsyncValueSetter<String> onSubmit, required String buttonText}) {
    var controller = TextEditingController();

    return Row(
      children: [
        Flexible(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: hint
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            onSubmit(controller.text);
          },
          child: Text("${buttonText}")
        ),
      ],
    );
  }

  Widget doubleEditText({required String hint, required String hint2, required AsyncValueSetter<Map<String,String>> onSubmit, required String buttonText}) {
    var controller = TextEditingController();
    var controller2 = TextEditingController();

    return Row(
      children: [
        Flexible(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: hint
            ),
          ),
        ),
        Flexible(
          child: TextField(
            controller: controller2,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: hint2
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            onSubmit({"name":controller.text,"value":controller2.text});
          },
          child: Text("${buttonText}")
        ),
      ],
    );
  }
}
