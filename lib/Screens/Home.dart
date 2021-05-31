import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription<StepCount>? _subscription;
  int _steps = 0;
  bool isRunning = false;
  int stepsYet = 0;
  int displaySteps = 0;

  resetSteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stepsyet', 0);
    print((prefs.getInt('stepsyet')));
  }

  void startPadometerListen() {
    setState(() {
      isRunning = true;
    });
    _subscription = Pedometer.stepCountStream.listen((event) async {
      print(event);
      _steps = event.steps;
      if (_steps < stepsYet) {
        // Upon device reboot, pedometer resets. When this happens, the saved counter must be reset as well.
        await saveSteps();
        stepsYet = 0;
        // getStepsYet();
        // {persist this value using a package of your choice here}
      }
      setState(() {
        displaySteps = _steps - stepsYet;
      });
      stepsYet = _steps;
      // getStepsYet();
    });

    print("pedo called");
  }

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

  getStepsYet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    stepsYet = (prefs.getInt('stepsyet') ?? 0);
    print('steps yet =  $stepsYet ');
  }

  startPedo() {
    getStepsYet();
    getPermission();
  }

  saveSteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stepsyet', _steps);
  }

  stopPedo() async {
    _subscription?.cancel();

    await saveSteps();
    displaySteps = 0;
    setState(() {
      isRunning = false;
    });
  }

  @override
  void dispose() async {
    _subscription?.cancel();
    await saveSteps();
    super.dispose();
  }
}
