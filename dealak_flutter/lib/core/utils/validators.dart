class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'بريد إلكتروني غير صالح';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    return null;
  }

  static String? required(String? value, [String field = 'هذا الحقل']) {
    if (value == null || value.isEmpty) return '$field مطلوب';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^\+?[\d\s-]{7,15}$').hasMatch(value)) {
      return 'رقم هاتف غير صالح';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) return 'كلمات المرور غير متطابقة';
    return null;
  }
}
