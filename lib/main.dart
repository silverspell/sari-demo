import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router/app_router.dart';
import 'session/session_controller.dart';
import 'session/shared_preferences_session_store.dart';
import 'theme/sari_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final sessionController = SessionController(
    SharedPreferencesSessionStore(preferences),
  );
  await sessionController.load();
  runApp(SariApp(sessionController: sessionController));
}

class SariApp extends StatefulWidget {
  const SariApp({super.key, required this.sessionController});

  final SessionController sessionController;

  @override
  State<SariApp> createState() => _SariAppState();
}

class _SariAppState extends State<SariApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(sessionController: widget.sessionController);
  }

  @override
  void didUpdateWidget(covariant SariApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionController != widget.sessionController) {
      _router.dispose();
      _router = createAppRouter(sessionController: widget.sessionController);
    }
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sarı',
      debugShowCheckedModeBanner: false,
      theme: buildSariTheme(),
      routerConfig: _router,
    );
  }
}
