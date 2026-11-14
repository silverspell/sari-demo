import 'session.dart';

abstract final class SessionDisplay {
  static String fullName(Session? session) {
    final name = (session?.name ?? '').trim();
    final surname = (session?.surname ?? '').trim();
    final parts = [if (name.isNotEmpty) name, if (surname.isNotEmpty) surname];
    return parts.isEmpty ? 'Misafir' : parts.join(' ');
  }

  static String initials(Session? session) {
    final name = (session?.name ?? '').trim();
    final surname = (session?.surname ?? '').trim();
    if (name.isEmpty && surname.isEmpty) {
      return '?';
    }
    final first = name.isEmpty ? '' : name.substring(0, 1);
    final last = surname.isEmpty ? '' : surname.substring(0, 1);
    return '$first$last'.toUpperCase();
  }

  static String phone(Session? session) {
    final digits = (session?.phone ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('90')) {
      return '+${digits.substring(0, 2)} ${digits.substring(2, 5)} '
          '${digits.substring(5, 8)} ${digits.substring(8, 10)} '
          '${digits.substring(10, 12)}';
    }
    return session?.phone ?? '';
  }
}
