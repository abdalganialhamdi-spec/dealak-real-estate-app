import 'package:flutter/material.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';

class PriceDisplay extends StatelessWidget {
  final double price;
  final String currency;
  final String listingType;
  final TextStyle? style;

  const PriceDisplay({
    super.key,
    required this.price,
    this.currency = 'SYP',
    this.listingType = 'SALE',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = Formatters.currency(price, symbol: currency == 'SYP' ? 'ل.س' : currency);
    final suffix = listingType == 'RENT_MONTHLY' ? '/شهر' : listingType == 'RENT_YEARLY' ? '/سنة' : listingType == 'RENT_DAILY' ? '/يوم' : '';

    return Text(
      '$formatted$suffix',
      style: style ?? Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}
