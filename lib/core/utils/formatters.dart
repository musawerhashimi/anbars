import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String locale = 'fa';

  static NumberFormat get _currency => NumberFormat.currency(
        locale: locale == 'fa' ? 'fa' : 'en_US',
        symbol: '\$',
        decimalDigits: 2,
      );

  static String currency(double amount) => _currency.format(amount);
  static String date(String iso) =>
      DateFormat.yMMMd(locale).format(DateTime.parse(iso));
  static String dateTime(String iso) =>
      DateFormat.yMMMd(locale).add_jm().format(DateTime.parse(iso));
  static String shortDate(String iso) =>
      DateFormat.MMMd(locale).format(DateTime.parse(iso));
  static String compact(double amount) =>
      NumberFormat.compact(locale: locale).format(amount);
  static String longDate(DateTime date) =>
      DateFormat.MMMMEEEEd(locale).format(date);
  static String month(DateTime date) => DateFormat.MMM(locale).format(date);
  static String number(num value) =>
      NumberFormat.decimalPattern(locale).format(value);
  static String time(DateTime date) => DateFormat.jm(locale).format(date);
  static String weekdayShort(DateTime date) =>
      DateFormat.E(locale).format(date);
  static String dayMonth(DateTime date) =>
      DateFormat.MMMEd(locale).format(date);
}
