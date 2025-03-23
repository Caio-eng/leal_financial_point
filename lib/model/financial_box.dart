class FinancialBox {
  final String? idFinancialBox;
  final String? tipoCaixaSelecionado;
  final String? tipoEntradaSaidaSelecionado;
  final String? descricaoItemCaixaController;
  final String? valorItemCaixaController;
  final String? dataItemCaixaController;
  final String? quantidade;
  final String? valorTotal;
  final String? pagamentoOK;
  final String? papelUsuario;

  FinancialBox({
    this.idFinancialBox,
    this.tipoCaixaSelecionado,
    this.tipoEntradaSaidaSelecionado,
    this.descricaoItemCaixaController,
    this.valorItemCaixaController,
    this.dataItemCaixaController,
    this.pagamentoOK,
    this.quantidade,
    this.valorTotal,
    this.papelUsuario
  });

  Map<String, dynamic> toMap() {
    return {
      'idFinancialBox': idFinancialBox,
      'tipoCaixaSelecionado': tipoCaixaSelecionado,
      'tipoEntradaSaidaSelecionado': tipoEntradaSaidaSelecionado,
      'descricaoItemCaixaController': descricaoItemCaixaController,
      'valorItemCaixaController': valorItemCaixaController,
      'dataItemCaixaController': dataItemCaixaController,
      'papelUsuario': papelUsuario,
      'quantidade': quantidade,
      'valorTotal': valorTotal,
      'pagamentoOK': pagamentoOK
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
      papelUsuario: map['papelUsuario'] ?? '',
      pagamentoOK: map['pagamentoOK'] ?? '',
      quantidade: map['quantidade'] ?? '',
      valorTotal: map['valorTotal'] ?? ''
    );
  }
}