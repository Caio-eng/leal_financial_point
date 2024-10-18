import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/moeda.dart';
import '../model/moeda_dto.dart';

class CotacaoService {
  static const String apiUrl = "https://economia.awesomeapi.com.br/last";
  static const String currencies = "USD-BRL";

  static Future<Moeda> buscaCotacaoMoedaRecente() async {
    final url = Uri.parse('$apiUrl/$currencies');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonMap = json.decode(response.body);
        Map<String, dynamic> moedaNode = jsonMap['USDBRL'];

        return Moeda.fromJson(moedaNode);
      } else {
        throw Exception('Falha ao buscar cotação da moeda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar cotação: $e');
    }
  }
}
