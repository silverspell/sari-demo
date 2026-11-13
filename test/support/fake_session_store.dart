import 'package:sari/session/session.dart';
import 'package:sari/session/session_store.dart';

class FakeSessionStore implements SessionStore {
  FakeSessionStore([this.session]);

  Session? session;

  @override
  Future<Session?> read() async => session;

  @override
  Future<void> write(Session session) async {
    this.session = session;
  }

  @override
  Future<void> clear() async {
    session = null;
  }
}
