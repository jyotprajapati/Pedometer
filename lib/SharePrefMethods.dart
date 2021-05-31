import 'package:shared_preferences/shared_preferences.dart';

class SharePrefMethods {
  Future<int> getStepsYet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getInt('stepsyet') ?? 0);
  }

  Future<void> saveSteps(int _steps) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stepsyet', _steps);
    return;
  }
}
