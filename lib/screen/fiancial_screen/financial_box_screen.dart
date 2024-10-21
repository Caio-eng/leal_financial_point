import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leal_apontar/components/menu.dart';
import 'package:leal_apontar/model/financial_box.dart';
import 'package:leal_apontar/screen/fiancial_screen/financial_box_register_screen.dart';
import 'package:leal_apontar/services/financial_box_service.dart';
import 'package:leal_apontar/services/financial_report_service.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../components/custom_card_item.dart';
import '../../components/custom_snack_bar.dart';
import '../../components/show_custom_alert_dialog.dart';

class FinancialBoxScreen extends StatefulWidget {
  User user;
  FinancialBoxScreen({super.key, required this.user});

  @override
  State<FinancialBoxScreen> createState() => _FinancialBoxScreenState();
}

class _FinancialBoxScreenState extends State<FinancialBoxScreen> {
  String searchQuery = '';
  String filtro = 'todos';
  double saldoAtual = 0;
  bool saldoCalculado = false; // Variável auxiliar para evitar cálculos repetidos
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lançamento de Caixa'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      drawer: Menu(user: widget.user),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                hintText: 'Digite o que deseja pesquisar',
                labelText: 'Pesquisar',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchQuery = _searchController.text.trim().toLowerCase();
                      saldoCalculado = false; // Reseta cálculo de saldo ao pesquisar
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                  saldoCalculado = false; // Reseta cálculo de saldo ao digitar
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: 'todos',
                      groupValue: filtro,
                      onChanged: (value) {
                        setState(() {
                          filtro = value!;
                          saldoAtual = 0;
                          saldoCalculado = false; // Reseta cálculo de saldo ao mudar filtro
                        });
                      },
                    ),
                    const Text('Lançamentos'),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: 'entradas',
                      groupValue: filtro,
                      onChanged: (value) {
                        setState(() {
                          filtro = value!;
                          saldoAtual = 0;
                          saldoCalculado = false;
                        });
                      },
                    ),
                    const Text('Entradas'),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: 'saidas',
                      groupValue: filtro,
                      onChanged: (value) {
                        setState(() {
                          filtro = value!;
                          saldoAtual = 0;
                          saldoCalculado = false;
                        });
                      },
                    ),
                    const Text('Saídas'),
                  ],
                ),
              ],
            ),
          ),
          // Lista de lançamentos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: filtro == 'todos'
                  ? FinancialBoxService().findMyFinancialBox(widget.user.uid)
                  : filtro == 'entradas'
                  ? FinancialBoxService().findMyFinancialBoxEntradas(widget.user.uid)
                  : FinancialBoxService().findMyFinancialBoxSaidas(widget.user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(
                      'Erro ao carregar o lançamento de caixa: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                        'Olá ${widget.user.displayName}, nenhum lançamento de caixa encontrado!'),
                  );
                } else {
                  List<FinancialBox> financialBoxs = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return FinancialBox.fromMap(data);
                  }).toList();

                  if (searchQuery.isNotEmpty) {
                    financialBoxs = financialBoxs.where((financialBox) {
                      final tipoCaixaSelecionado =
                      financialBox.tipoCaixaSelecionado!.toLowerCase();
                      final tipoEntradaSaidaSelecionado =
                      financialBox.tipoEntradaSaidaSelecionado!.toLowerCase();
                      final descricaoItemCaixaController =
                      financialBox.descricaoItemCaixaController!.toLowerCase();
                      final valorItemCaixaController =
                      financialBox.valorItemCaixaController!.toLowerCase();
                      final dataItemCaixaController =
                      financialBox.dataItemCaixaController!.toLowerCase();
                      return tipoCaixaSelecionado.contains(searchQuery) ||
                          tipoEntradaSaidaSelecionado.contains(searchQuery) ||
                          descricaoItemCaixaController.contains(searchQuery) ||
                          valorItemCaixaController.contains(searchQuery) ||
                          dataItemCaixaController.contains(searchQuery);
                    }).toList();
                  }

                  if (!saldoCalculado) {
                    double entradas = 0;
                    double saidas = 0;

                    for (var financialBox in financialBoxs) {
                      String valorString = financialBox.valorItemCaixaController!
                          .replaceAll('R\$', '')
                          .replaceAll('.', '')
                          .replaceAll(',', '.');

                      double valor = double.parse(valorString);

                      if (financialBox.tipoCaixaSelecionado == 'Entrada') {
                        entradas += valor;
                      } else if (financialBox.tipoCaixaSelecionado == 'Saída') {
                        saidas += valor;
                      }
                    }

                    // Move the state update here to avoid calling setState in the build method
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        saldoAtual = entradas - saidas;
                        saldoCalculado = true;
                      });
                    });
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: financialBoxs.length,
                    itemBuilder: (context, index) {
                      final financialBox = financialBoxs[index];
                      return GestureDetector(
                        onTap: () {},
                        child: CustomCardItem(
                          title:
                          '${financialBox.tipoCaixaSelecionado} ${financialBox.dataItemCaixaController}',
                          subtitle: 'Tipo de ${financialBox.tipoCaixaSelecionado}: ${financialBox.tipoEntradaSaidaSelecionado}\nDescrição: ${financialBox.descricaoItemCaixaController}',
                          icon: Icons.attach_money,
                          owner: 'Valor: ${financialBox.valorItemCaixaController}',
                          onOptionSelected: (option) {
                            switch (option) {
                              case 'Download':
                                onDownloadPressed(financialBox);
                                break;
                              case 'Editar':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FinancialBoxRegisterScreen(
                                      user: widget.user,
                                      idEditarFinancialBox:
                                      financialBox.idFinancialBox,
                                    ),
                                  ),
                                );
                                saldoCalculado = false;
                                break;
                              case 'Excluir':
                                deleteFinancialBox(financialBox.idFinancialBox!);
                            }
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(30),
              color: Colors.teal, // Cor similar ao FloatingActionButton
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Saldo Atual:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'R\$ ${saldoAtual.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinancialBoxRegisterScreen(
                    user: widget.user,
                  ),
                ),
              );
              saldoCalculado = false;
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Future<void> deleteFinancialBox(String idFinancialBox) async {
    showCustomAlertDialog(
        context,
        'Confirmar Exclusão',
        'Tem certeza que deseja excluir este lançamento de caixa?',
        'Excluir',
        'Cancelar', () async {
      FinancialBoxService().deleteFinancialBox(idFinancialBox, widget.user.uid);
      saldoCalculado = false;
      customSnackBar(context, 'Lançamento de caixa excluído com sucesso!');
    });
  }
  void onDownloadPressed(FinancialBox financialBox) async {
    FinancialReportService().generateProofFinancialBox(financialBox);
    customSnackBar(context, 'Comprovante gerado com sucesso!');
  }


}