/*
  * @class: MoedaDTO - Classe que representa o objeto de retorno do endpoint da API.
  * @author: Caio Cesar Pereira Leal Moreira
 */
class MoedaDTO {
  final String licitacaoDeCompra;
  final String licitacaoDeVenda;
  final String codigo;
  final String codigoEm;
  final String nome;

  MoedaDTO({
    required this.licitacaoDeCompra,
    required this.licitacaoDeVenda,
    required this.codigo,
    required this.codigoEm,
    required this.nome,
  });

  factory MoedaDTO.fromJson(Map<String, dynamic> json) {
    return MoedaDTO(
      licitacaoDeCompra: json['licitacaoDeCompra'],
      licitacaoDeVenda: json['licitacaoDeVenda'],
      codigo: json['codigo'],
      codigoEm: json['codigoEm'],
      nome: json['nome'],
    );
  }
}
