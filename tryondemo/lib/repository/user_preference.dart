import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static SharedPreferences? _preferences;

  static const _kUserId = 'id';
  static const _kUserName = 'name';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<bool> saveUser({required int id, required String name}) async {
    await _preferences?.setInt(_kUserId, id);
    return await _preferences?.setString(_kUserName, name) ?? false;
  }

  static int getUserId() => _preferences?.getInt(_kUserId) ?? 0;
  static String getUserName() => _preferences?.getString(_kUserName) ?? '';

  // 필요하면 추가 데이터를 저장을 위해 이 곳에 코드를 작성

  static Future<void> clear() async {
    await _preferences?.clear();
  }
}
