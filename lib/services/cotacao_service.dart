import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:leal_apontar/services/api_key.dart';
import '../model/moeda.dart';

class CotacaoService {

  static Future<Moeda> buscaCotacaoMoedaRecente(String tipoMoedaSelecionado) async {
    final url = Uri.parse(APIKey.apiCotacao + tipoMoedaSelecionado);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonMap = json.decode(response.body);
        Map<String, dynamic> moedaNode = {};

        if (tipoMoedaSelecionado == 'USD-BRL') {
          moedaNode = jsonMap['USDBRL'];
        } else if (tipoMoedaSelecionado == 'BRL-USD') {
          moedaNode = jsonMap['BRLUSD'];
        } else if (tipoMoedaSelecionado == 'EUR-BRL') {
          moedaNode = jsonMap['EURBRL'];
        } else {
          moedaNode = jsonMap['BRLEUR'];
        }

        return Moeda.fromJson(moedaNode);
      } else {
        throw Exception('Falha ao buscar cotação da moeda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar cotação: $e');
    }
  }
}
