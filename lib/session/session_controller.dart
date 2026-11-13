import 'package:flutter/foundation.dart';

import 'session.dart';
import 'session_store.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._store);

  final SessionStore _store;

  Session? _session;

  Session? get session => _session;

  bool get hasSession => _session != null;

  Future<void> load() async {
    _session = await _store.read();
    notifyListeners();
  }

  Future<void> save(Session session) async {
    await _store.write(session);
    _session = session;
    notifyListeners();
  }

  Future<void> clear() async {
    await _store.clear();
    _session = null;
    notifyListeners();
  }
}
