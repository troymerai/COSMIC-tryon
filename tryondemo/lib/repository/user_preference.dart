// import 'package:shared_preferences/shared_preferences.dart';

// class UserPreferences {
//   static SharedPreferences? _preferences;

//   static const _kUserUid = 'uuid';
//   static const _kUserId = 'id';
//   static const _kUserPassword = 'password';

//   static Future init() async {
//     _preferences = await SharedPreferences.getInstance();
//   }

//   // Save user data
//   static Future<bool> saveUser(
//       {required String uuid,
//       required String id,
//       required String password}) async {
//     await _preferences?.setString(_kUserUid, uuid);
//     await _preferences?.setString(_kUserId, id);
//     return await _preferences?.setString(_kUserPassword, password) ?? false;
//   }

//   // Get user data
//   static String getUserUuid() => _preferences?.getString(_kUserUid) ?? "uid없음";
//   static String getUserId() => _preferences?.getString(_kUserId) ?? 'id없음';
//   static String getUserPassword() =>
//       _preferences?.getString(_kUserPassword) ?? 'password없음';

//   // Clear stored data
//   static Future<void> clear() async {
//     await _preferences?.clear();
//   }
// }

import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static SharedPreferences? _preferences;

  static const _kUserUid = 'uuid';
  static const _kUserId = 'id';
  static const _kUserPassword = 'password';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Save user data
  static Future<bool> saveUser({
    required String uuid,
    required String id,
    required String password,
  }) async {
    await _preferences?.setString(_kUserUid, uuid);
    await _preferences?.setString(_kUserId, id);
    return await _preferences?.setString(_kUserPassword, password) ?? false;
  }

  // Get user data
  static String getUserUid() => _preferences?.getString(_kUserUid) ?? "uid없음";
  static String getUserId() => _preferences?.getString(_kUserId) ?? 'id없음';
  static String getUserPassword() =>
      _preferences?.getString(_kUserPassword) ?? 'password없음';

  // Clear stored data
  static Future<void> clear({
    bool keepUid = false,
    bool keepId = false,
    bool keepPassword = false,
  }) async {
    if (keepUid || keepId || keepPassword) {
      final String savedUid = keepUid ? getUserUid() : '';
      final String savedId = keepId ? getUserId() : '';
      final String savedPassword = keepPassword ? getUserPassword() : '';

      await _preferences?.clear();

      if (keepUid) await _preferences?.setString(_kUserUid, savedUid);
      if (keepId) await _preferences?.setString(_kUserId, savedId);
      if (keepPassword)
        await _preferences?.setString(_kUserPassword, savedPassword);
    } else {
      await _preferences?.clear();
    }
  }
}
