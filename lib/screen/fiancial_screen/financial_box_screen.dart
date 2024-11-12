import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:leal_apontar/components/menu.dart';
import 'package:leal_apontar/model/financial_box.dart';
import 'package:leal_apontar/screen/fiancial_screen/financial_box_register_screen.dart';
import 'package:leal_apontar/services/comuns_service.dart';
import 'package:leal_apontar/services/financial_box_service.dart';
import 'package:leal_apontar/services/financial_report_service.dart';
import 'package:leal_apontar/services/usuario_service.dart';
import '../../components/custom_Input_decoration.dart';
import '../../components/custom_card_item.dart';
import '../../components/custom_snack_bar.dart';
import '../../components/show_custom_alert_dialog.dart';

class FinancialBoxScreen extends StatefulWidget {
  final User user;
  const FinancialBoxScreen({super.key, required this.user});

  @override
  State<FinancialBoxScreen> createState() => _FinancialBoxScreenState();
}

class _FinancialBoxScreenState extends State<FinancialBoxScreen> {
  String searchQuery = '';
  String filtro = 'todos';
  double saldoAtual = 0;
  bool saldoCalculado = false;
  final TextEditingController _searchController = TextEditingController();
  String? anoSelecionado = '';
  String? mesSelecionado = '';
  String? pagamentoSelecionado = '';
  bool? ordemData = true;
  late List<FinancialBox> financialBoxs = [];
  String typeAccount = 'Pessoal';
  String typeUser = '';
  Stream<QuerySnapshot> listaFinancialBoxReserva = const Stream.empty();
  Stream<QuerySnapshot> listaFinancialBoxEntrada = const Stream.empty();
  Stream<QuerySnapshot> listaFinancialBoxSaida = const Stream.empty();
  bool? isReserva = false, isEntrada = false, isSaida = false;

  @override
  void initState() {
    super.initState();
    atualizarAnoEMesSelecionados();
    _loadUserInfo();
    _verificaFinancialBox();
  }

  void _verificaFinancialBox() {
    listaFinancialBoxReserva = FinancialBoxService().findMyFinancialBoxReservas(
      widget.user.uid, ordemData!,
    );
    listaFinancialBoxEntrada = FinancialBoxService().findMyFinancialBoxEntradas(
      widget.user.uid, ordemData!,
    );
    listaFinancialBoxSaida = FinancialBoxService().findMyFinancialBoxSaidas(
      widget.user.uid, ordemData!,
    );
    listaFinancialBoxReserva.listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        isReserva = true;
        saldoCalculado = false;
        setState(() {});
      } else {
        isReserva = false;
        setState(() {});
      }
    });

    listaFinancialBoxEntrada.listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        isEntrada = true;
        saldoCalculado = false;
        setState(() {});
      } else {
        isEntrada = false;
        setState(() {});
      }
    });

    listaFinancialBoxSaida.listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        isSaida = true;
        saldoCalculado = false;
        setState(() {});
      } else {
        isSaida = false;
        setState(() {});
      }
    });
  }

  void _loadUserInfo() async {
    typeAccount = await UsuarioService().getTypeAccount(widget.user.uid);
    typeUser = await UsuarioService().getTypeUser(widget.user.uid);
    setState(() {});
  }

  void atualizarAnoEMesSelecionados() {
    DateTime agora = DateTime.now();
    anoSelecionado = agora.year.toString();
    mesSelecionado = agora.month.toString().padLeft(2, '0');
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
                            searchQuery =
                                _searchController.text.trim().toLowerCase();
                            saldoCalculado = false;
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
                        saldoCalculado = false;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: anoSelecionado,
                    items: ComunsService().getAnoOptions(),
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
                    items: ComunsService().getMesOptions(),
                    onChanged: (value) {
                      setState(() {
                        mesSelecionado = value;
                        saldoCalculado = false;
                      });
                    },
                    decoration: CustomInputDecoration.build(
                      labelText: 'Filtro pelo Mês',
                    ),
                  ),
                ),
                typeUser == 'ADMIN' || typeUser == 'SUPER_ADMIN' ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: typeAccount,
                    items: ComunsService().getTypeAccountOptions(),
                    onChanged: (value) {
                      setState(() {
                        typeAccount = value!;
                        UsuarioService().updateTypeAccountUser(
                            widget.user.uid, typeAccount);
                        saldoCalculado = false;
                        saldoAtual = 0;
                        financialBoxs = [];
                        customSnackBar(
                          context,
                          typeAccount == 'Pessoal'
                              ? 'Perfil modificado para conta $typeAccount!'
                              : 'Perfil modificado para conta $typeAccount!',
                          backgroundColor: Colors.green,
                        );
                        setState(() {});
                      });
                    },
                    decoration: CustomInputDecoration.build(
                      labelText: 'Trocar Conta',
                    ),
                  ),
                ) : Container(),
                Row(
                  children: [
                   Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: DropdownButtonFormField<String>(
                          value: filtro,
                          items: ComunsService().getTypeBoxOptions(isReserva!, isEntrada!, isSaida!),
                          onChanged: (value) {
                            setState(() {
                              filtro = value!;
                              saldoCalculado = false;
                            });
                          },
                          decoration: CustomInputDecoration.build(
                            labelText: 'Tipo de Caixa',
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
                filtro != 'reservas' ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: pagamentoSelecionado,
                    items: ComunsService().getPagamentoOptions(),
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
                ) : Container(),
              ],
            ),
          ),
          // Lista de lançamentos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: filtro == 'todos'
                  ? FinancialBoxService().findMyFinancialBox(widget.user.uid, ordemData!)
                  : filtro == 'entradas'
                      ? FinancialBoxService().findMyFinancialBoxEntradas(
                          widget.user.uid, ordemData!)
                      :  filtro == 'saidas'
                      ? FinancialBoxService().findMyFinancialBoxSaidas(
                          widget.user.uid, ordemData!)
                      : FinancialBoxService().findMyFinancialBoxReservas(
                  widget.user.uid, ordemData!),
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
                      return dataItemCaixaController
                          .contains('${mesSelecionado!}/${anoSelecionado!}');
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
                    double reservas = 0;

                    for (var financialBox in financialBoxs) {
                      String valorString = FinancialBoxService().removeCaracteres(financialBox
                          .valorItemCaixaController!);
                      double valor = double.parse(valorString);

                      if (financialBox.tipoCaixaSelecionado == 'Entrada') {
                        entradas += valor;
                      } else if (financialBox.tipoCaixaSelecionado == 'Saída') {
                        saidas += valor;
                      } else {
                        reservas += valor;
                      }
                    }

                    // Move the state update here to avoid calling setState in the build method
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        saldoAtual = entradas - saidas - reservas;
                        if (saldoAtual.toStringAsFixed(2) == '-0.00') {
                          saldoAtual *= -1;
                        }
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
                          subtitle:
                              'Tipo de ${financialBox.tipoCaixaSelecionado}: ${financialBox.tipoEntradaSaidaSelecionado}\nDescrição: ${financialBox.descricaoItemCaixaController}\n${financialBox.pagamentoOK != '' ? 'Pagamento: ${financialBox.pagamentoOK}' : ''}',
                          icon: Icons.attach_money,
                          owner:
                              'Valor: ${financialBox.valorItemCaixaController}',
                          onOptionSelected: (option) {
                            switch (option) {
                              case 'Comprovante':
                                onDownloadPressed(financialBox);
                                break;
                              case 'Editar':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FinancialBoxRegisterScreen(
                                      user: widget.user,
                                      idEditarFinancialBox:
                                          financialBox.idFinancialBox,
                                    ),
                                  ),
                                );
                                saldoCalculado = false;
                                _verificaFinancialBox();
                                break;
                              case 'Excluir':
                                deleteFinancialBox(financialBox.idFinancialBox!);
                                _verificaFinancialBox();

                              case 'Copiar registro':
                                showCustomAlertDialog(
                                    context,
                                    'Copiar Registro',
                                    'Tem certeza que deseja copiar este registro para o próximo mês?',
                                    'Copiar',
                                    'Cancelar', () async {
                                  copyFinancialBox(financialBox.idFinancialBox!,
                                      financialBox, widget.user.uid);
                                  _verificaFinancialBox();
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
              color: filtro == 'reservas' ?
              Colors.orange
              : saldoAtual >= 0 && filtro != 'reservas'
                  ? Colors.teal
                  : Colors.red, // Cor similar ao FloatingActionButton
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
                  filtro != 'reservas' ?  'R\$ ${saldoAtual.toStringAsFixed(2)}' : 'R\$ ${(saldoAtual * -1).toStringAsFixed(2)}',
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
                  _verificaFinancialBox();
                },
              ),
              financialBoxs.isNotEmpty
                  ? SpeedDialChild(
                      child: const Icon(
                        Icons.description,
                        color: Colors.white,
                      ),
                      label: 'Gerar relatório de lançamentos',
                      backgroundColor: Colors.teal,
                      onTap: () {
                        if (financialBoxs.isNotEmpty) {
                          FinancialReportService().generateFinancialReport(
                              financialBoxs, saldoAtual, filtro);
                          customSnackBar(context,
                              'Relatório financeiro gerado com sucesso!');
                        } else {
                          customSnackBar(context,
                              'Nenhum registro de caixa foi encontrado!',
                              backgroundColor: Colors.red);
                        }
                      },
                    )
                  : SpeedDialChild(),
              financialBoxs.isEmpty
                  ? SpeedDialChild()
                  : anoSelecionado == '' && mesSelecionado == ''
                      ? SpeedDialChild()
                      : SpeedDialChild(
                          child: const Icon(
                            Icons.copy,
                            color: Colors.white,
                          ),
                          label: 'Copiar Lista de Lançamentos',
                          backgroundColor: Colors.teal,
                          onTap: () {
                            copyListFinancialBox(financialBoxs);
                            _verificaFinancialBox();
                          },
                        ),
              financialBoxs.isNotEmpty
                  ? SpeedDialChild(
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      label: 'Deletar Lista de Lançamentos',
                      backgroundColor: Colors.teal,
                      onTap: () {
                        deleteAllFinancialBox(financialBoxs);
                        _verificaFinancialBox();
                      },
                    )
                  : SpeedDialChild(),
            ],
          )
        ],
      ),
    );
  }

  Future<void> deleteAllFinancialBox(financialBoxs) async {
    if (financialBoxs.isNotEmpty) {
      showCustomAlertDialog(
          context,
          'Confirmar Exclusão',
          'Tem certeza que deseja excluir todos os lançamento de caixa?',
          'Excluir',
          'Cancelar', () async {
        for (var financialBox in financialBoxs) {
          FinancialBoxService()
              .deleteFinancialBox(financialBox.idFinancialBox, widget.user.uid);
        }
        mesSelecionado = DateTime.now().month.toString().padLeft(2, '0');
        anoSelecionado = DateTime.now().year.toString();
        filtro = 'todos';
        setState(() {});
        customSnackBar(context, 'Lançamentos de caixa excluídos com sucesso!');
      });
    } else {
      customSnackBar(context, 'Nenhum lançamento de caixa foi encontrado!',
          backgroundColor: Colors.red);
    }
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
      filtro = 'todos';
      customSnackBar(context, 'Lançamento de caixa excluído com sucesso!');
    });
  }

  void onDownloadPressed(FinancialBox financialBox) async {
    FinancialReportService().generateProofFinancialBox(financialBox);
    customSnackBar(context, 'Comprovante gerado com sucesso!');
  }

  void copyListFinancialBox(financialBoxs) async {
    if (financialBoxs.isNotEmpty) {
      showCustomAlertDialog(
        context,
        'Confirmar Copia',
        'Será copiado todos lançamentos de caixa para o mês seguinte, deseja continuar?\nOBS: Caso use neste mês a funcionalidade novamente irá duplicar os lançamentos, tenha cuidado!',
        'Copiar',
        'Cancelar',
        () async {
          for (FinancialBox financialBox in financialBoxs) {
            DateFormat dateFormat = DateFormat('dd/MM/yyyy');
            DateTime currentDate = dateFormat
                .parse(financialBox.dataItemCaixaController.toString());
            DateTime nextMonthDate = DateTime(
                currentDate.year, currentDate.month + 1, currentDate.day);

            String nextMonthDateString = dateFormat.format(nextMonthDate);

            bool exists = await FinancialBoxService()
                .checkIfFinancialBoxExists(financialBox, widget.user.uid);

            if (exists) {
              _copyRegister(financialBox.idFinancialBox!, financialBox,
                  widget.user.uid, nextMonthDateString);
            }
          }
          setState(() {});
          customSnackBar(context, 'Lançamentos copiado com sucesso para o mês seguinte!');
        },
        showLoadingIndicator: true,
      );
    } else {
      customSnackBar(context, 'Nenhum lançamento de caixa foi encontrado!',
          backgroundColor: Colors.red);
    }
  }

  void copyFinancialBox(
      String idFinancialBox, FinancialBox financialBox, String uid) async {
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    DateTime currentDate =
        dateFormat.parse(financialBox.dataItemCaixaController.toString());
    DateTime nextMonthDate =
        DateTime(currentDate.year, currentDate.month + 1, currentDate.day);

    String nextMonthDateString = dateFormat.format(nextMonthDate);

    bool exists = await FinancialBoxService()
        .checkIfFinancialBoxExists(financialBox, uid);

    if (exists) {
      exists = await FinancialBoxService().checkIfFinancialBoxExistsForDate(
          financialBox, nextMonthDateString, uid);
      if (!exists) {
        _copyRegister(idFinancialBox, financialBox, uid, nextMonthDateString);
        customSnackBar(context, 'Lançamento de caixa copiado com sucesso para o mês seguinte!');
      } else {
        showCustomAlertDialog(
            context,
            'Confirmar Copia',
            'Tem um registro com está data para o mês. Tem certeza que deseja copiar este registro?',
            'Copiar',
            'Cancelar', () async {
              _copyRegister(idFinancialBox, financialBox, uid, nextMonthDateString);
              customSnackBar(context, 'Lançamento de caixa copiado com sucesso para o mês seguinte!');
        });
      }
    } else {
      customSnackBar(context, 'Lancamento de caixa já existe para o próximo mês!',
          backgroundColor: Colors.red);
    }
  }

  _copyRegister(String idFinancialBox, FinancialBox financialBox, String uid,
      String nextMonthDateString) {
    idFinancialBox =
        FirebaseFirestore.instance.collection('financial_box').doc().id;
    FinancialBox newFinancialBox = FinancialBox(
      idFinancialBox: idFinancialBox,
      tipoCaixaSelecionado: financialBox.tipoCaixaSelecionado,
      tipoEntradaSaidaSelecionado: financialBox.tipoEntradaSaidaSelecionado,
      descricaoItemCaixaController: financialBox.descricaoItemCaixaController,
      valorItemCaixaController: financialBox.valorItemCaixaController,
      dataItemCaixaController: nextMonthDateString,
      pagamentoOK: financialBox.pagamentoOK,
    );

    FinancialBoxService().saveFinancialBox(idFinancialBox, uid, newFinancialBox);
  }
}
