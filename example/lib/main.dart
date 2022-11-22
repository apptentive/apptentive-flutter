import 'package:alkami_core_dependencies/alkami_core_dependencies.dart';
// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:async';
import 'dart:io' show Platform;

import 'package:apptentive_flutter/apptentive_flutter.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Apptentive: handling a background message");
  print("Notification Data: ${message.data}");
}

String? integration_token = "";

void main() async {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
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
    // Save the device token for our Firebase push integration on Android
    if (Platform.isAndroid) {
      integration_token = await FirebaseMessaging.instance.getToken();
    }

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
      print(
          "E Apptentive: Platform not supported for Apptentive Flutter Plugin: $os. Apptentive failed to initialize.");
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
        gatherCarrierInfo: true);
    ApptentiveFlutter.surveyFinishedCallback = (bool completed) {
      print("Survey Finished?: $completed");
    };
    ApptentiveFlutter.messageCenterUnreadCountChangedNotification = (int count) {
      print("Message Center unread message count is now: $count");
    };
    ApptentiveFlutter.messageSentNotification = (String sentByUser) {
      print("Message sent by user: " + sentByUser);
    };
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
              eventTester(context),
              personCustomDataTester(context),
              personCustomDataRemoverTester(context),
              deviceCustomDataTester(context),
              deviceCustomDataRemoverTester(context),
              person(context),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
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
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            ApptentiveFlutter.registerListeners();
                          },
                          child: Text('Register Listeners'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            if (integration_token != null) {
                              ApptentiveFlutter.setPushNotificationIntegration(
                                  provider: PushProvider.apptentive, token: integration_token!);
                            } else {
                              print("Apptentive Error: Push integration token is null.");
                            }
                          },
                          child: Text('Set Push Notification Integration'),
                        ),
                      ],
                    ),
                  ),
                ],
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
                print("Not engaged");
              } else {
                print("$eventName engaged!");
              }
            });
          },
          buttonText: "Engage"),
    );
  }

  Widget personCustomDataTester(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: doubleEditText(
            hint: "Person Data Name",
            hint2: "Person Data Value",
            onSubmit: (personCustomDataMap) async {
              ApptentiveFlutter.addCustomPersonData(
                      key: personCustomDataMap["name"]!, value: personCustomDataMap["value"]!)
                  .then((value) {
                if (!value) {
                  print("Person Custom Data Not Added");
                } else {
                  print("Person Custom Data Added!");
                }
              });
            },
            buttonText: "Add"));
  }

  Widget personCustomDataRemoverTester(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: editText(
            hint: "Person Custom Data To Remove",
            onSubmit: (personCustomDataName) async {
              ApptentiveFlutter.removeCustomPersonData(key: personCustomDataName).then((value) {
                if (!value) {
                  print("Custom Person Data Not Removed");
                } else {
                  print("Custom Person Data Removed!");
                }
              });
            },
            buttonText: "Remove"));
  }

  Widget deviceCustomDataTester(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: doubleEditText(
            hint: "Device Data Name",
            hint2: "Device Data Value",
            onSubmit: (deviceCustomDataMap) async {
              ApptentiveFlutter.addCustomDeviceData(
                      key: deviceCustomDataMap["name"]!, value: deviceCustomDataMap["value"]!)
                  .then((value) {
                if (!value) {
                  print("Device Custom Data Not Added");
                } else {
                  print("Device Custom Data Added!");
                }
              });
            },
            buttonText: "Add"));
  }

  Widget deviceCustomDataRemoverTester(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: editText(
            hint: "Device Custom Data To Remove",
            onSubmit: (deviceCustomDataName) async {
              ApptentiveFlutter.removeCustomDeviceData(key: deviceCustomDataName).then((value) {
                if (!value) {
                  print("Custom Device Data Not Removed");
                } else {
                  print("Custom Device Data Removed!");
                }
              });
            },
            buttonText: "Remove"));
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
              buttonText: "Update"),
          editText(
              hint: "Person email",
              onSubmit: (email) async {
                ApptentiveFlutter.setPersonEmail(email: email);
              },
              buttonText: "Update"),
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
            decoration: InputDecoration(border: OutlineInputBorder(), hintText: hint),
          ),
        ),
        OutlinedButton(
            onPressed: () {
              onSubmit(controller.text);
            },
            child: Text("$buttonText")),
      ],
    );
  }

  Widget doubleEditText(
      {required String hint,
      required String hint2,
      required AsyncValueSetter<Map<String, String>> onSubmit,
      required String buttonText}) {
    var controller = TextEditingController();
    var controller2 = TextEditingController();

    return Row(
      children: [
        Flexible(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(border: OutlineInputBorder(), hintText: hint),
          ),
        ),
        Flexible(
          child: TextField(
            controller: controller2,
            decoration: InputDecoration(border: OutlineInputBorder(), hintText: hint2),
          ),
        ),
        OutlinedButton(
            onPressed: () {
              onSubmit({"name": controller.text, "value": controller2.text});
            },
            child: Text("$buttonText")),
      ],
    );
  }
}
