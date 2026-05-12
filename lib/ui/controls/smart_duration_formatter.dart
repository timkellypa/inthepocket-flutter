import 'package:flutter/services.dart';

class SmartDurationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // remove padded zeros so we can re-pad them correctly
    final String unpaddedDigits = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    final String digits = unpaddedDigits.length > 4
        ? unpaddedDigits.substring(0, 4)
        : unpaddedDigits;

    final String padded = digits.padLeft(4, '0');
    final String text = '${padded.substring(0, 2)}:${padded.substring(2, 4)}';

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  static int stringToDuration(String input) {
    final List<String> parts = input.split(':');
    if (parts.length != 2) {
      return 0;
    }
    final int minutes = int.tryParse(parts[0]) ?? 0;
    final int seconds = int.tryParse(parts[1]) ?? 0;
    return (minutes * 60000) + (seconds * 1000);
  }

  static String durationToString(int duration) {
    final int minutes = (duration / 60000).floor();
    final int seconds = ((duration % 60000) / 1000).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
