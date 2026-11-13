abstract final class AppRoutes {
  static const login = '/giris';
  static const otp = '/dogrulama';
  static const name = '/isim';
  static const locationPermission = '/konum-izni';
  static const home = '/ana-sayfa';
  static const destination = '/nereye';
  static const routeFare = '/rota-ve-ucret';
  static const findingDriver = '/surucu-araniyor';

  static const authPaths = <String>{login, otp, name, locationPermission};
}
