import 'package:intl/intl.dart';

final _numberFormatter = NumberFormat('0.0');

String formatNumber(num number) => _numberFormatter.format(number);