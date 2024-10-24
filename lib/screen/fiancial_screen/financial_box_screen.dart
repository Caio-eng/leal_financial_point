import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:leal_apontar/components/menu.dart';
import 'package:leal_apontar/model/financial_box.dart';
import 'package:leal_apontar/screen/fiancial_screen/financial_box_register_screen.dart';
import 'package:leal_apontar/services/financial_box_service.dart';
import 'package:leal_apontar/services/financial_report_service.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../components/custom_Input_decoration.dart';
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
  String? anoSelecionado = '';
  String? mesSelecionado = '';
  String? pagamentoSelecionado = '';
  bool? ordemData = true;
  late List<FinancialBox> financialBoxs = [];

  @override
  void initState() {
    super.initState();
    atualizarAnoEMesSelecionados();
  }

  void atualizarAnoEMesSelecionados() {
    DateTime agora = DateTime.now();
    anoSelecionado = agora.year.toString();
    mesSelecionado = agora.month.toString().padLeft(2, '0');
  }

  List<DropdownMenuItem<String>> getPagamentoOptions() {
    return const [
      DropdownMenuItem(value: '', child: Text('Filtrar Todos')),
      DropdownMenuItem(value: 'Pago', child: Text('Pago')),
      DropdownMenuItem(value: 'Falta Pagar', child: Text('Falta Pagar')),
    ];
  }

  List<DropdownMenuItem<String>> getAnoOptions() {
    return const [
      DropdownMenuItem(value: '', child: Text('Todos os anos')),
      DropdownMenuItem(value: '2023', child: Text('2023')),
      DropdownMenuItem(value: '2024', child: Text('2024')),
      DropdownMenuItem(value: '2025', child: Text('2025')),
      DropdownMenuItem(value: '2026', child: Text('2026')),
    ];
  }

  List<DropdownMenuItem<String>> getMesOptions() {
    return const [
      DropdownMenuItem(value: '', child: Text('Todos os mêses')),
      DropdownMenuItem(value: '01', child: Text('Janeiro')),
      DropdownMenuItem(value: '02', child: Text('Fevereiro')),
      DropdownMenuItem(value: '03', child: Text('Março')),
      DropdownMenuItem(value: '04', child: Text('Abril')),
      DropdownMenuItem(value: '05', child: Text('Maio')),
      DropdownMenuItem(value: '06', child: Text('Junho')),
      DropdownMenuItem(value: '07', child: Text('Julho')),
      DropdownMenuItem(value: '08', child: Text('Agosto')),
      DropdownMenuItem(value: '09', child: Text('Setembro')),
      DropdownMenuItem(value: '10', child: Text('Outubro')),
      DropdownMenuItem(value: '11', child: Text('Novembro')),
      DropdownMenuItem(value: '12', child: Text('Dezembro')),
    ];
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
            child: ExpansionTile(
              title: const Text('Filtros de Pesquisa'),
              leading: const Icon(Icons.filter_list),
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
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: anoSelecionado,
                    items: getAnoOptions(),
                    onChanged: (value) {
                      setState(() {
                        anoSelecionado = value;
                        saldoCalculado = false;
                        mesSelecionado = '';
                      });
                    },
                    decoration: CustomInputDecoration.build(
                      labelText: 'Filtro pelo Ano',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: mesSelecionado,
                    items: getMesOptions(),
                    onChanged: (value) {
                      setState(() {
                        mesSelecionado = value;
                        saldoCalculado = false; // Reseta cálculo de saldo ao mudar mês
                      });
                    },
                    decoration: CustomInputDecoration.build(
                      labelText: 'Filtro pelo Mês',
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        value: pagamentoSelecionado,
                        items: getPagamentoOptions(),
                        onChanged: (value) {
                          setState(() {
                            pagamentoSelecionado = value;
                            saldoCalculado = false;
                          });
                        },
                        decoration: CustomInputDecoration.build(
                          labelText: 'Filtro pelo Pagamento',
                        ),
                      ),
                    ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            ordemData = !ordemData!;
                            saldoCalculado = false;
                          });
                        },
                        icon: Icon(
                          Icons.update_outlined,
                          color: ordemData! ? Colors.grey : Colors.teal,
                        ),
                      ),
                    ),
                  ],
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
              ],
            ),
          ),
          // Lista de lançamentos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: filtro == 'todos'
                  ? FinancialBoxService().findMyFinancialBox(widget.user.uid, ordemData!)
                  : filtro == 'entradas'
                  ? FinancialBoxService().findMyFinancialBoxEntradas(widget.user.uid, ordemData!)
                  : FinancialBoxService().findMyFinancialBoxSaidas(widget.user.uid, ordemData!),
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
                  financialBoxs = snapshot.data!.docs.map((doc) {
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

                  if (anoSelecionado != '' && mesSelecionado != '') {
                    financialBoxs = financialBoxs.where((financialBox) {
                      final dataItemCaixaController =
                      financialBox.dataItemCaixaController!.toLowerCase();
                      return dataItemCaixaController.contains('${mesSelecionado!}/${anoSelecionado!}');
                    }).toList();
                  } else if (anoSelecionado != '') {
                    financialBoxs = financialBoxs.where((financialBox) {
                      final dataItemCaixaController =
                      financialBox.dataItemCaixaController!.toLowerCase();
                      return dataItemCaixaController.contains(anoSelecionado!);
                    }).toList();
                  } else if (mesSelecionado != '') {
                    financialBoxs = financialBoxs.where((financialBox) {
                      final dataItemCaixaController =
                      financialBox.dataItemCaixaController!.toLowerCase();
                      return dataItemCaixaController.contains(mesSelecionado!);
                    }).toList();
                  }

                  if (pagamentoSelecionado != '') {
                    financialBoxs = financialBoxs.where((financialBox) {
                      return financialBox.pagamentoOK == pagamentoSelecionado;
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
                          subtitle: 'Tipo de ${financialBox.tipoCaixaSelecionado}: ${financialBox.tipoEntradaSaidaSelecionado}\nDescrição: ${financialBox.descricaoItemCaixaController}\n${financialBox.pagamentoOK != '' ? 'Pagamento: ${financialBox.pagamentoOK}' : ''}',
                          icon: Icons.attach_money,
                          owner: 'Valor: ${financialBox.valorItemCaixaController}',
                          onOptionSelected: (option) {
                            switch (option) {
                              case 'Comprovante':
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

                              case 'Copiar registro':
                                showCustomAlertDialog(
                                    context,
                                    'Copiar Registro',
                                    'Tem certeza que deseja copiar este registro para o próximo mês?',
                                    'Copiar',
                                    'Cancelar', () async {
                                  copyFinancialBox(financialBox.idFinancialBox!, financialBox, widget.user.uid);
                                });
                                break;
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
              color: saldoAtual >= 0 ? Colors.teal : Colors.red, // Cor similar ao FloatingActionButton
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
          SpeedDial(
            // Ícone principal do botão
            icon: Icons.add,
            activeIcon: Icons.close,
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,

            // Lista de botões secundários
            children: [
              SpeedDialChild(
                child: const Icon(Icons.attach_money, color: Colors.white),
                label: 'Registrar Caixa',
                backgroundColor: Colors.teal,
                onTap: () {
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
              ),
              SpeedDialChild(
                child: const Icon(Icons.description, color: Colors.white,),
                label: 'Gerar relatório de lançamentos',
                backgroundColor: Colors.teal,
                onTap: () {
                  if (financialBoxs.isNotEmpty) {
                    FinancialReportService().generateFinancialReport(
                        financialBoxs, saldoAtual);
                    customSnackBar(
                        context, 'Relatório financeiro gerado com sucesso!');
                  } else {
                    customSnackBar(context, 'Nenhum registro de caixa foi encontrado!', backgroundColor: Colors.red);
                  }
                },
              ),
            ],
          )
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

  void copyFinancialBox(String idFinancialBox, FinancialBox financialBox, String uid) async{
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    DateTime currentDate = dateFormat.parse(financialBox.dataItemCaixaController.toString());
    DateTime nextMonthDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);

    String nextMonthDateString = dateFormat.format(nextMonthDate);

    bool exists = await FinancialBoxService().checkIfFinancialBoxExistsForDescription(financialBox, financialBox.descricaoItemCaixaController!, uid);

    if (!exists) {
      idFinancialBox = FirebaseFirestore.instance.collection('financial_box').doc().id;
      FinancialBox newFinancialBox = FinancialBox(
        idFinancialBox: idFinancialBox,
        tipoCaixaSelecionado: financialBox.tipoCaixaSelecionado,
        tipoEntradaSaidaSelecionado: financialBox.tipoEntradaSaidaSelecionado,
        descricaoItemCaixaController: financialBox.descricaoItemCaixaController,
        valorItemCaixaController: financialBox.valorItemCaixaController,
        dataItemCaixaController: nextMonthDateString, // Ajuste a data para o próximo mês
        pagamentoOK: financialBox.pagamentoOK,
      );

      FinancialBoxService().saveFinancialBox(idFinancialBox, uid, newFinancialBox);

      customSnackBar(context, 'Registro copiado com sucesso para o mês seguinte!');
    } else {
      customSnackBar(context, 'Registro já existe para o próximo mês!', backgroundColor: Colors.red);
    }
  }


}