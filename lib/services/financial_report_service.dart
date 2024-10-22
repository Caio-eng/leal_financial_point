import 'package:leal_apontar/model/financial_box.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

import 'package:pdf/widgets.dart';

class FinancialReportService {

  void generateProofFinancialBox(FinancialBox financialBox) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(marginBottom: 20, marginLeft: 20, marginRight: 20, marginTop: 20),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                pw.Text(
                  'Comprovante de Lançamento do Caixa',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.Divider(),
                pw.SizedBox(height: 10),

                // Detalhes do lançamento
                pw.Text(
                  'Tipo de Lançamento: ${financialBox.tipoCaixaSelecionado}',
                  style: const pw.TextStyle(fontSize: 18),
                ),
                pw.Text(
                  'Tipo de ${financialBox.tipoCaixaSelecionado}: ${financialBox.tipoEntradaSaidaSelecionado}',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Descrição: ${financialBox.descricaoItemCaixaController}',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.Text(
                  'Data: ${financialBox.dataItemCaixaController}',
                  style: const pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 60),
                pw.Text(
                  'Valor da ${financialBox.tipoCaixaSelecionado}: ${financialBox.valorItemCaixaController}',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),

                // Rodapé
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'A Leal Financial Point agradece por utilizar nosso serviço!',
                    style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'comprovante_financial_box.pdf')
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  void generateFinancialReport(List<FinancialBox> financialBoxes, double saldoAtual) async {
    final pdf = pw.Document();

    // Adiciona uma página para cada FinancialBox na lista
    for (var financialBox in financialBoxes) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.copyWith(marginBottom: 20, marginLeft: 20, marginRight: 20, marginTop: 20),
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Comprovante de Lançamento do Caixa',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Divider(),
                  pw.SizedBox(height: 10),

                  // Detalhes do lançamento
                  pw.Text(
                    'Tipo de Lançamento: ${financialBox.tipoCaixaSelecionado}',
                    style: const pw.TextStyle(fontSize: 18),
                  ),
                  pw.Text(
                    'Tipo de ${financialBox.tipoCaixaSelecionado}: ${financialBox.tipoEntradaSaidaSelecionado}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Descrição: ${financialBox.descricaoItemCaixaController}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.Text(
                    'Data: ${financialBox.dataItemCaixaController}',
                    style: const pw.TextStyle(fontSize: 18),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.SizedBox(height: 60),
                  pw.Text(
                    'Valor da ${financialBox.tipoCaixaSelecionado}: ${financialBox.valorItemCaixaController}',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.SizedBox(height: 20),

                  // Rodapé
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      'A Leal Financial Point agradece por utilizar nosso serviço!',
                      style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(marginBottom: 20, marginLeft: 20, marginRight: 20, marginTop: 20),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                pw.Text(
                  'Resumo Financeiro',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.Divider(),
                pw.SizedBox(height: 10),

                // Detalhes do saldo
                pw.Text(
                  'Saldo Atual:',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Com base nos lançamentos realizados, o saldo atual é:',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'R\$ ${saldoAtual.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: saldoAtual > 0 ? PdfColors.green : PdfColors.red),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),

                // Rodapé
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'A Leal Financial Point agradece por utilizar nosso serviço!',
                    style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'relatorio_financial_box.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

}