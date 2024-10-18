import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove qualquer caractere não numérico
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Converte para um número
    double value = double.tryParse(newText) ?? 0.0;

    // Formata o número como moeda
    String formattedValue = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value / 100);

    // Retorna o novo valor formatado
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}