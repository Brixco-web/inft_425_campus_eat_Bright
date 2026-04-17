import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _settingsBoxName = 'settings';
  static const String _biometricsKey = 'use_biometrics';
  static const String _stayLoggedInKey = 'stay_logged_in';

  Future<void> init() async {
    await Hive.openBox(_settingsBoxName);
  }

  Box get _box => Hive.box(_settingsBoxName);

  bool get useBiometrics => _box.get(_biometricsKey, defaultValue: false);
  set useBiometrics(bool value) => _box.put(_biometricsKey, value);

  bool get stayLoggedIn => _box.get(_stayLoggedInKey, defaultValue: false);
  set stayLoggedIn(bool value) => _box.put(_stayLoggedInKey, value);

  Future<void> clearSettings() async {
    await _box.clear();
  }
}
