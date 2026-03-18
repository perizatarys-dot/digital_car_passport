import 'package:intl/intl.dart';

/// Formatting helpers for Digital Car Passport
abstract class Formatters {
  /// 8400000 → "8,400,000 ₸"
  static String kzt(int amount) {
    final f = NumberFormat('#,###', 'ru_RU');
    return '${f.format(amount)} ₸';
  }

  /// 8400000 → "8.4M ₸"
  static String kztMillions(int amount) {
    return '${(amount / 1000000).toStringAsFixed(1)}M ₸';
  }

  /// 78200 → "78,200 km"
  static String km(int mileage) {
    final f = NumberFormat('#,###', 'ru_RU');
    return '${f.format(mileage)} km';
  }

  /// 78200 → "78.2K km"
  static String kmShort(int mileage) {
    return '${(mileage / 1000).toStringAsFixed(0)}K km';
  }

  /// "2023-04-15" → "15 Apr 2023"
  static String date(String iso) {
    try {
      final d = DateTime.parse(iso);
      return DateFormat('d MMM yyyy').format(d);
    } catch (_) {
      return iso;
    }
  }

  /// trust score → label
  static String trustLabel(int score) {
    if (score >= 75) return 'Safe to Consider';
    if (score >= 50) return 'Check Carefully';
    return 'High Risk';
  }
}
