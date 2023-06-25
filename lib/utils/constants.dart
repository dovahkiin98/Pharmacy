import 'package:intl/intl.dart';

NumberFormat getCurrencyFormat() => NumberFormat.currency(
      locale: 'en_US',
      decimalDigits: 0,
      symbol: 'SYP',
      customPattern: '###,### \u00A4',
    );
