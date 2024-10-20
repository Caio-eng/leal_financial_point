class FinancialBox {
  final String? idFinancialBox;
  final String? tipoCaixaSelecionado;
  final String? tipoEntradaSaidaSelecionado;
  final String? descricaoItemCaixaController;
  final String? valorItemCaixaController;
  final String? dataItemCaixaController;

  FinancialBox({
    this.idFinancialBox,
    this.tipoCaixaSelecionado,
    this.tipoEntradaSaidaSelecionado,
    this.descricaoItemCaixaController,
    this.valorItemCaixaController,
    this.dataItemCaixaController
  });

  Map<String, dynamic> toMap() {
    return {
      'idFinancialBox': idFinancialBox,
      'tipoCaixaSelecionado': tipoCaixaSelecionado,
      'tipoEntradaSaidaSelecionado': tipoEntradaSaidaSelecionado,
      'descricaoItemCaixaController': descricaoItemCaixaController,
      'valorItemCaixaController': valorItemCaixaController,
      'dataItemCaixaController': dataItemCaixaController
    };
  }

  factory FinancialBox.fromMap(Map<String, dynamic> map) {
    return FinancialBox(
      idFinancialBox: map['idFinancialBox'] ?? '',
      tipoCaixaSelecionado: map['tipoCaixaSelecionado'] ?? '',
      tipoEntradaSaidaSelecionado: map['tipoEntradaSaidaSelecionado'] ?? '',
      descricaoItemCaixaController: map['descricaoItemCaixaController'] ?? '',
      valorItemCaixaController: map['valorItemCaixaController'] ?? '',
      dataItemCaixaController: map['dataItemCaixaController'] ?? '',
    );
  }
}