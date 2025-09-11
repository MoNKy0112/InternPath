import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern(
    'es',
  ); // es = español

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Eliminar puntos antes de parsear
    String clean = newValue.text.replaceAll('.', '');

    int? value = int.tryParse(clean);
    if (value == null) {
      return oldValue;
    }

    // Formatear con separadores de miles
    String newText = _formatter.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
