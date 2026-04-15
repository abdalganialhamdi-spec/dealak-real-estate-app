extension StringExtensions on String {
  String get capitalize => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  String get toArabicNumbers => replaceAll('0', '٠').replaceAll('1', '١').replaceAll('2', '٢')
      .replaceAll('3', '٣').replaceAll('4', '٤').replaceAll('5', '٥')
      .replaceAll('6', '٦').replaceAll('7', '٧').replaceAll('8', '٨')
      .replaceAll('9', '٩');
}
