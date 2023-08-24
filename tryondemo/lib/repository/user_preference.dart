import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static SharedPreferences? _preferences;

  static const _kUserUid = 'uuid';
  static const _kUserId = 'id';
  static const _kUserPassword = 'password';
  static const kisLoggedIn = 'isLoggedIn';
  static const kUserToken = 'token';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /** 로그인 상태 저장 */
  static Future<bool> updateIsLoggedIn(bool isLoggedIn) async {
    return await _preferences?.setBool(kisLoggedIn, isLoggedIn) ?? false;
  }

  /** 토큰 값 저장 */
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  /** 유저 데이터 저장 */
  static Future<bool> saveUser({
    required String uuid,
    required String id,
    required String password,
  }) async {
    await _preferences?.setBool(kisLoggedIn, true);
    await _preferences?.setString(_kUserUid, uuid);
    await _preferences?.setString(_kUserId, id);
    return await _preferences?.setString(_kUserPassword, password) ?? false;
  }

  /** 유저 데이터 불러오기 */
  static String getUserUid() => _preferences?.getString(_kUserUid) ?? "uid없음";
  static String getUserId() => _preferences?.getString(_kUserId) ?? 'id없음';
  static String getUserPassword() =>
      _preferences?.getString(_kUserPassword) ?? 'password없음';

  static bool isLoggedIn() => _preferences?.getBool(kisLoggedIn) ?? false;
  static String getUserToken() =>
      _preferences?.getString(kUserToken) ?? "token 없음";

  /** 저장된 유저 데이터 삭제 */
  static Future<void> clear({
    bool keepUid = false,
    bool keepId = false,
    bool keepPassword = false,
    bool keepToken = false,
  }) async {
    if (keepUid || keepId || keepPassword) {
      final String savedUid = keepUid ? getUserUid() : '';
      final String savedId = keepId ? getUserId() : '';
      final String savedPassword = keepPassword ? getUserPassword() : '';
      final String savedToken = keepToken ? getUserToken() : '';

      await _preferences?.clear();

      if (keepUid) await _preferences?.setString(_kUserUid, savedUid);
      if (keepId) await _preferences?.setString(_kUserId, savedId);
      if (keepPassword)
        await _preferences?.setString(_kUserPassword, savedPassword);
      if (keepToken) await _preferences?.setString(kUserToken, savedToken);
    } else {
      await _preferences?.clear();
    }
  }
}
