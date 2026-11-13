abstract final class AppRoutes {
  static const login = '/giris';
  static const otp = '/dogrulama';
  static const name = '/isim';
  static const locationPermission = '/konum-izni';
  static const session = '/oturum';

  static const authPaths = <String>{login, otp, name, locationPermission};
}
