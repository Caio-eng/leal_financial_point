import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/moeda_dto.dart';

/*
 * @class: APICotacaoService
 * @description: Classe que realiza a busca da cotação da moeda do backend
 * @author: Caio Cesar Pereira Leal Moreira
 */
class APICotacaoService {
  static Future<MoedaDTO> buscaCotacaoMoedaRecente() async {
    var url = Uri.parse('http://localhost:8081/cotacao/recente');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return MoedaDTO.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao buscar cotação da moeda');
    }
  }
}
