import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:leal_apontar/services/api_key.dart';
import '../model/moeda.dart';

class CotacaoService {

  static Future<Moeda> buscaCotacaoMoedaRecente() async {
    final url = Uri.parse(APIKey.apiCotacao);

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
