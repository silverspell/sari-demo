import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'session.dart';
import 'session_store.dart';

class SharedPreferencesSessionStore implements SessionStore {
  SharedPreferencesSessionStore(this._preferences);

  static const sessionKey = 'sari.session';

  final SharedPreferences _preferences;

  @override
  Future<Session?> read() async {
    final raw = _preferences.getString(sessionKey);
    if (raw == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return Session.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(Session session) async {
    await _preferences.setString(sessionKey, jsonEncode(session.toJson()));
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(sessionKey);
  }
}
