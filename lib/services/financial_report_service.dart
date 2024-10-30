import 'package:leal_apontar/model/financial_box.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'package:intl/intl.dart';

class FinancialReportService {

  void generateProofFinancialBox(FinancialBox financialBox) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(marginBottom: 20, marginLeft: 20, marginRight: 20, marginTop: 20),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blueGrey700),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center, // Centraliza o conteúdo do comprovante
                children: [
                  // Título do Comprovante
                  pw.Text(
                    'Comprovante de Lançamento do Caixa',
                    style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                  ),
                  pw.Divider(thickness: 1.5, color: PdfColors.blueGrey700),
                  pw.SizedBox(height: 20),

                  // Detalhes do lançamento
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      border: pw.Border.all(color: PdfColors.blueGrey700),
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Tipo de Lançamento: ${financialBox.tipoCaixaSelecionado}',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Tipo de ${financialBox.tipoCaixaSelecionado}: ${financialBox.tipoEntradaSaidaSelecionado}',
                          style: const pw.TextStyle(fontSize: 16, color: PdfColors.blueGrey700),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Descrição: ${financialBox.descricaoItemCaixaController}',
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                        financialBox.pagamentoOK != '' ? pw.SizedBox(height: 10) : pw.SizedBox(),
                        financialBox.pagamentoOK != '' ? pw.Text(
                          'Pagamento: ${financialBox.pagamentoOK}',
                          style: const pw.TextStyle(fontSize: 16),
                        ) : pw.SizedBox(),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Data: ${financialBox.dataItemCaixaController}',
                          style: const pw.TextStyle(fontSize: 18),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Divider(thickness: 1.5, color: PdfColors.blueGrey700),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Valor da ${financialBox.tipoCaixaSelecionado}: ${financialBox.valorItemCaixaController}',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: financialBox.tipoCaixaSelecionado == 'Entrada' ? PdfColors.green700 : financialBox.tipoCaixaSelecionado == 'Saída' ? PdfColors.red700 : PdfColors.orange700),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Rodapé
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      'A Leal Financial Point agradece por utilizar nosso serviço!',
                      style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic, color: PdfColors.blueGrey400),
                    ),
                  ),
                ],
              )
            )
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'comprovante_financeiro.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void generateFinancialReport(List<FinancialBox> financialBoxes, double saldoAtual) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    financialBoxes.sort((a, b) {
      final dateA = dateFormat.parse(a.dataItemCaixaController.toString());
      final dateB = dateFormat.parse(b.dataItemCaixaController.toString());
      return dateA.compareTo(dateB);
    });

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(marginBottom: 20, marginLeft: 20, marginRight: 20, marginTop: 20),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'Relatório Financeiro',
                style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
              ),
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.blueGrey700),
            pw.SizedBox(height: 20),

            // Lista todos os FinancialBox com quebra automática de página
            pw.ListView.builder(
              itemCount: financialBoxes.length,
              itemBuilder: (context, index) {
                final financialBox = financialBoxes[index];
                return financialBox.tipoCaixaSelecionado != 'Reserva' ? pw.Center(
                  child: pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    margin: const pw.EdgeInsets.symmetric(vertical: 10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      border: pw.Border.all(color: PdfColors.blueGrey700),
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center, // Centraliza o conteúdo do card
                      children: [
                        pw.Text(
                          'Tipo de Lançamento: ${financialBox.tipoCaixaSelecionado}',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Tipo de ${financialBox.tipoCaixaSelecionado}: ${financialBox.tipoEntradaSaidaSelecionado}',
                          style: const pw.TextStyle(fontSize: 16, color: PdfColors.blueGrey700),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Descrição: ${financialBox.descricaoItemCaixaController}',
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                        financialBox.pagamentoOK != '' ? pw.SizedBox(height: 10) : pw.SizedBox(),
                        financialBox.pagamentoOK != '' ? pw.Text(
                          'Pagamento: ${financialBox.pagamentoOK}',
                          style: const pw.TextStyle(fontSize: 16),
                        ) : pw.SizedBox(),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Data: ${financialBox.dataItemCaixaController}',
                          style: const pw.TextStyle(fontSize: 18),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Valor: ${financialBox.valorItemCaixaController}',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: financialBox.tipoCaixaSelecionado == 'Saída' ? PdfColors.red700 : PdfColors.green700),
                        ),
                      ],
                    ),
                  ),
                ) : pw.SizedBox();
              },
            ),
            // Detalhes do saldo
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  margin: const pw.EdgeInsets.symmetric(vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blueGrey700),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Dinheiro Reservado',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                    ),
                    pw.Divider(thickness: 1.5, color: PdfColors.blueGrey700),
                    pw.SizedBox(height: 10),
                    for( FinancialBox financialBox in financialBoxes )
                      if (financialBox.tipoCaixaSelecionado == 'Reserva')
                        pw.Column(
                          children: [
                            pw.Text(
                              'Tipo de Lançamento: ${financialBox.tipoCaixaSelecionado}',
                              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(
                              'Tipo de ${financialBox.tipoCaixaSelecionado}: ${financialBox.tipoEntradaSaidaSelecionado}',
                              style: const pw.TextStyle(fontSize: 16, color: PdfColors.blueGrey700),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              'Descrição: ${financialBox.descricaoItemCaixaController}',
                              style: const pw.TextStyle(fontSize: 16),
                            ),
                            financialBox.pagamentoOK != '' ? pw.SizedBox(height: 10) : pw.SizedBox(),
                            financialBox.pagamentoOK != '' ? pw.Text(
                              'Pagamento: ${financialBox.pagamentoOK}',
                              style: const pw.TextStyle(fontSize: 16),
                            ) : pw.SizedBox(),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              'Data: ${financialBox.dataItemCaixaController}',
                              style: const pw.TextStyle(fontSize: 18),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              'Valor: ${financialBox.valorItemCaixaController}',
                              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.orange700),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Divider(thickness: 1.5, color: PdfColors.blueGrey700),
                            pw.SizedBox(height: 10),
                          ]
                        ),
                  ]
                )
              )
            )
          ];
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(marginBottom: 20, marginLeft: 20, marginRight: 20, marginTop: 20),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blueGrey700),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center, // Centraliza o conteúdo
                children: [
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Resumo Financeiro',
                    style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                  ),
                  pw.Divider(thickness: 1.5, color: PdfColors.blueGrey700),
                  // Detalhes do saldo
                  pw.Text(
                    'Saldo Atual',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                  ),
                  pw.Text(
                    'Com base nos lançamentos realizados, o saldo atual é:',
                    style: const pw.TextStyle(fontSize: 16, color: PdfColors.blueGrey600),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'R\$ ${saldoAtual.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 36,
                      fontWeight: pw.FontWeight.bold,
                      color: saldoAtual > 0 ? PdfColors.green700 : PdfColors.red700,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(thickness: 1.5, color: PdfColors.blueGrey700),
                  pw.SizedBox(height: 10),

                  // Rodapé
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      'A Leal Financial Point agradece por utilizar nosso serviço!',
                      style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic, color: PdfColors.blueGrey400),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'relatorio_financeiro.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

}