import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount, {String symbol = 'ل.س'}) {
    final formatter = NumberFormat('#,##0', 'ar_SY');
    return '${formatter.format(amount)} $symbol';
  }

  static String date(DateTime date) {
    return DateFormat.yMMMd('ar').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat.yMMMd('ar').add_Hm().format(date);
  }

  static String area(double sqm) {
    return '$sqm م²';
  }

  static String propertyType(String type) {
    const map = {
      'APARTMENT': 'شقة',
      'HOUSE': 'منزل',
      'VILLA': 'فيلا',
      'LAND': 'أرض',
      'COMMERCIAL': 'تجاري',
      'OFFICE': 'مكتب',
      'WAREHOUSE': 'مستودع',
      'FARM': 'مزرعة',
    };
    return map[type] ?? type;
  }

  static String listingType(String type) {
    const map = {
      'SALE': 'بيع',
      'RENT_MONTHLY': 'إيجار شهري',
      'RENT_YEARLY': 'إيجار سنوي',
      'RENT_DAILY': 'إيجار يومي',
    };
    return map[type] ?? type;
  }

  static String status(String status) {
    const map = {
      'AVAILABLE': 'متاح',
      'SOLD': 'مباع',
      'RENTED': 'مؤجر',
      'PENDING': 'قيد المراجعة',
      'RESERVED': 'محجوز',
      'DRAFT': 'مسودة',
    };
    return map[status] ?? status;
  }
}
