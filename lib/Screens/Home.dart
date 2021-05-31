import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:s4s_test/SharePrefMethods.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription<StepCount>? _subscription; //Pedometer Stream Subscription
  int _steps = 0; //Steps given by pedometer stream
  bool isRunning = false; //Sets the state of Start/Stop Button
  int stepsYet = 0; //Steps from the Shared Pref. i.e. Steps in the last session
  int displaySteps = 0; //The step which are displayed on the screen

  void startPadometerListen() {
    setState(() {
      isRunning = true; //Change state of the Start/Stop button
    });
    _subscription = Pedometer.stepCountStream.listen((event) async {
      _steps = event.steps;
      if (_steps < stepsYet) {
        // Upon device reboot, pedometer resets. When this happens, the saved steps must be reset as well.
        await SharePrefMethods().saveSteps(_steps);
        stepsYet = 0;
      }
      //Subtract the saved steps from the current steps to get the steps only after start is pressed
      setState(() {
        displaySteps = _steps - stepsYet;
      });
      stepsYet = _steps;
    });
  }

  //GET PHYSICAL ACTIVITY PERMISSION
  Future<void> getPermission() async {
    if (await Permission.activityRecognition.request().isGranted) {
      startPadometerListen();
    }
    Permission.activityRecognition.request();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("S4S Test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                "$displaySteps",
                style: TextStyle(fontSize: 75),
              ),
            ),
            Flexible(
              child: ElevatedButton(
                onPressed: () => isRunning ? stopPedo() : startPedo(),
                child: Text(isRunning ? "stop" : "Start"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Called when Start Button pressed
  startPedo() async {
    stepsYet = await SharePrefMethods().getStepsYet();
    getPermission();
  }

  //Called when Stop button Pressed
  stopPedo() async {
    _subscription?.cancel();

    await SharePrefMethods().saveSteps(_steps);
    displaySteps = 0;
    setState(() {
      isRunning = false;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    SharePrefMethods().saveSteps(_steps);
    super.dispose();
  }
}
