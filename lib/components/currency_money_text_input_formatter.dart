import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyMoneyTextInputFormatter extends TextInputFormatter {
  String? tipoMoeda;

  // Construtor que recebe o tipo de moeda como opcional, padrão 'BRL-USD'
  CurrencyMoneyTextInputFormatter({this.tipoMoeda});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove tudo que não é número
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Converte o valor de string para double
    double value = double.tryParse(newText) ?? 0.0;

    // Formata o valor de acordo com o tipo de moeda
    String formattedValue;
    if (tipoMoeda == 'BRL-USD') {
      formattedValue = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
          .format(value / 100);
    } else if (tipoMoeda == 'USD-BRL') {
      formattedValue = NumberFormat.currency(locale: 'en_US', symbol: '\$')
          .format(value / 100);
    } else if (tipoMoeda == 'EUR-BRL') {
      formattedValue = NumberFormat.currency(locale: 'de_DE', symbol: '€')
          .format(value / 100);
    } else {
      // Caso padrão: BRL
      formattedValue = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
          .format(value / 100);
    }

    // Retorna o valor formatado e ajusta a seleção de texto
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
