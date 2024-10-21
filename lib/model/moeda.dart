class Moeda {
  final String bid;    // Preço de compra
  final String ask;    // Preço de venda
  final String code;   // Código da moeda
  final String codein; // Código da moeda em
  final String name;
  final String low;

  Moeda({
    required this.bid,
    required this.ask,
    required this.code,
    required this.codein,
    required this.name,
    required this.low
  });

  factory Moeda.fromJson(Map<String, dynamic> json) {
    return Moeda(
      bid: json['bid'],
      ask: json['ask'],
      code: json['code'],
      codein: json['codein'],
      name: json['name'],
      low: json['low']
    );
  }
}