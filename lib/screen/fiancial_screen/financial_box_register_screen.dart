import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leal_apontar/model/financial_box.dart';
import 'package:leal_apontar/services/comuns_service.dart';
import 'package:leal_apontar/services/financial_box_service.dart';
import 'package:leal_apontar/services/usuario_service.dart';

import '../../components/currency_text_input_formatter.dart';
import '../../components/custom_input_decoration.dart';
import '../../components/custom_snack_bar.dart';

class FinancialBoxRegisterScreen extends StatefulWidget {
  User user;
  final String? idEditarFinancialBox;
  FinancialBoxRegisterScreen(
      {super.key, required this.user, this.idEditarFinancialBox});

  @override
  State<FinancialBoxRegisterScreen> createState() =>
      _FinancialBoxRegisterScreenState();
}

class _FinancialBoxRegisterScreenState
    extends State<FinancialBoxRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController valorItemCaixaController = TextEditingController();
  TextEditingController valorSomatorioController = TextEditingController();
  TextEditingController valorMultipliController = TextEditingController();
  TextEditingController valorTotal = TextEditingController();
  TextEditingController quantidade = TextEditingController();
  TextEditingController descricaoItemCaixaController = TextEditingController();
  String? pagamentoSelecionado = '';
  final TextEditingController dataItemCaixaController = TextEditingController();
  String? tipoCaixaSelecionado = 'Entrada';
  String? tipoEntradaSaidaSelecionado;
  late String idFinancialBox = '';
  String valorSomatorioFormatado = '';
  bool showTextField = false;
  User? user;
  String typeAccount = '';
  late double valorItemCaixa;

  @override
  void initState() {
    super.initState();
    _recoverFinancialBox();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    typeAccount = await UsuarioService().getTypeAccount(widget.user.uid);
    setState(() {});
  }

  Future<void> _recoverFinancialBox() async {
    try {
      DocumentSnapshot financialBoxDoc = await FirebaseFirestore.instance
          .collection('financial_box')
          .doc(widget.idEditarFinancialBox)
          .get();

      if (financialBoxDoc.exists) {
        Map<String, dynamic> financialBoxData =
            financialBoxDoc.data() as Map<String, dynamic>;

        setState(() {
          idFinancialBox = financialBoxData['idFinancialBox'] ?? '';
          tipoCaixaSelecionado = financialBoxData['tipoCaixaSelecionado'] ?? '';
          tipoEntradaSaidaSelecionado =
              financialBoxData['tipoEntradaSaidaSelecionado'] ?? '';
          descricaoItemCaixaController.text =
              financialBoxData['descricaoItemCaixaController'] ?? '';
          valorItemCaixaController.text =
              financialBoxData['valorItemCaixaController'] ?? '';
          dataItemCaixaController.text =
              financialBoxData['dataItemCaixaController'] ?? '';
          pagamentoSelecionado = financialBoxData['pagamentoOK'] ?? '';
          if (typeAccount == 'Comercial') {
            valorTotal.text = financialBoxData['valorTotal'] ?? '';
            quantidade.text = financialBoxData['quantidade'] ?? '';
          }
        });
      }
    } catch (e) {
      customSnackBar(context, "Erro ao recuperar item do caixa: $e",
          backgroundColor: Colors.red);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}"; // Formato dd/MM/yyyy
      setState(() {
        dataItemCaixaController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: Text(idFinancialBox == ''
            ? 'Cadastrar Laçamento de Caixa'
            : 'Atualizar Laçamento de Caixa'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: tipoCaixaSelecionado,
                      items: const [
                        DropdownMenuItem(value: 'Entrada', child: Text('Entrada')),
                        DropdownMenuItem(value: 'Saída', child: Text('Saída')),
                        DropdownMenuItem(value: 'Reserva', child: Text('Reserva')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          tipoCaixaSelecionado = value;
                          tipoEntradaSaidaSelecionado = ''; // Limpa a seleção
                        });
                      },
                      decoration: CustomInputDecoration.build(
                        labelText: 'Tipo de Caixa',
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione o tipo de caixa';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: tipoEntradaSaidaSelecionado,
                      items: tipoCaixaSelecionado == 'Entrada'
                          ? (typeAccount == 'Pessoal'
                          ? ComunsService().getEntradaPessoalOptions()
                          : ComunsService().getEntradaOptions())
                          : tipoCaixaSelecionado == 'Saída'
                          ? (typeAccount == 'Pessoal'
                          ? ComunsService().getSaidaPessoalOptions()
                          : ComunsService().getSaidaOptions())
                          : (typeAccount == 'Pessoal' 
                          ? ComunsService().getReservaOptions() 
                          : ComunsService().getReservaComercialOptions()),
                      onChanged: (value) {
                        setState(() {
                          tipoEntradaSaidaSelecionado = value;
                        });
                      },
                      decoration: CustomInputDecoration.build(
                        labelText: tipoCaixaSelecionado == 'Entrada'
                            ? 'Tipo da Entrada'
                            : tipoCaixaSelecionado == 'Saída'
                            ? 'Tipo da Saída'
                            : 'Tipo da Reserva',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione o tipo da $tipoCaixaSelecionado';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descricaoItemCaixaController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Descrição da $tipoCaixaSelecionado é obrigatória!';
                        }
                        return null;
                      },
                      decoration: CustomInputDecoration.build(
                        hintText: tipoCaixaSelecionado == 'Entrada'
                            ? 'ex: Dízimo do João'
                            : tipoCaixaSelecionado == 'Saída' ? 'ex: Conta de energia' : 'ex: Dinheiro reservado',
                        labelText: tipoCaixaSelecionado == 'Entrada'
                            ? 'Descrição da Entrada'
                            : tipoCaixaSelecionado == 'Saída' ? 'Descrição da Saída' : 'Descrição da Reserva',
                        suffixIcon: const Icon(Icons.description),
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    typeAccount == 'Comercial' ? TextFormField(
                      controller: quantidade,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                      decoration: CustomInputDecoration.build(
                        labelText: tipoCaixaSelecionado == 'Entrada'
                            ? 'Quantidade de Entrada'
                            : tipoCaixaSelecionado == 'Saída' ? 'Quantidade de Saída' : 'Quantidade de Reserva',
                        suffixIcon: const Icon(Icons.numbers_rounded),
                      ),
                    ) : Container(),
                    typeAccount == 'Comercial' ? const SizedBox(height: 16) : const SizedBox(),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: valorItemCaixaController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CurrencyTextInputFormatter()
                            ],
                            onChanged: (valorItemCaixaController) {
                              valorItemCaixa = FinancialBoxService()
                                .convertValorToDouble(valorItemCaixaController) *
                              FinancialBoxService()
                                  .convertValorToDouble(quantidade.text);

                               valorTotal.text =
                                    FinancialBoxService().convertValorToString(valorItemCaixa);
                            },
                            validator: (value) {  
                              if (value!.isEmpty) {
                                return 'Valor da $tipoCaixaSelecionado é obrigatório!';
                              }
                              return null;
                            },
                            decoration: CustomInputDecoration.build(
                              hintText: tipoCaixaSelecionado == 'Entrada'
                                  ? 'Digite o valor da entrada'
                                  : tipoCaixaSelecionado == 'Saída' ? 'Digite o valor da saída' : 'Digite o valor da reserva',
                              labelText: tipoCaixaSelecionado == 'Entrada'
                                  ? 'Valor da Entrada'
                                  : tipoCaixaSelecionado == 'Saída' ? 'Valor da Saída' : 'Valor da Reserva',
                              suffixIcon: const Icon(Icons.monetization_on),
                            ),
                          ),
                        ),
                    const SizedBox(height: 16),
                        widget.idEditarFinancialBox != null && typeAccount == 'Pessoal' 
                            ? Expanded(
                                child: Tooltip(
                                  message: "Adicionar valor",
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showTextField =
                                            !showTextField; // Alterar estado
                                      });
                                    },
                                    icon: showTextField ? const Icon(Icons.remove) : const Icon(Icons.add),
                                    color: showTextField ? Colors.teal : Colors.black,
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    ),
                    typeAccount == 'Comercial' ? const SizedBox(height: 16) : const SizedBox(),
                    typeAccount == 'Comercial' ? TextFormField(
                      controller: valorTotal,
                      inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CurrencyTextInputFormatter()
                            ],
                      enabled: false,
                      decoration: CustomInputDecoration.build(
                        labelText: tipoCaixaSelecionado == 'Entrada'
                            ? 'Valor Total da Entrada'
                            : tipoCaixaSelecionado == 'Saída' ? 'Valor total da Saída' : 'Valor total da Reserva',
                        suffixIcon: const Icon(Icons.monetization_on),
                      ),
                    ) : Container(),
                    const SizedBox(height: 16),
                    showTextField
                        ? TextFormField(
                            controller: valorSomatorioController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CurrencyTextInputFormatter()
                            ],
                            decoration: CustomInputDecoration.build(
                              hintText: tipoCaixaSelecionado == 'Entrada'
                                  ? 'Digite o valor a ser somado a entrada'
                                  : tipoCaixaSelecionado == 'Saída' ? 'Digite o valor a ser somado a saída' : 'Digite o valor a ser somado a reserva',
                              labelText: 'Valor Somatório',
                              suffixIcon: const Icon(Icons.monetization_on),
                            ),
                          )
                        : Container(),
                    showTextField
                        ? const SizedBox(height: 16)
                        : Container(),
                    GestureDetector(
                      onTap: () {
                        _selectDate(context); // Exibir o DatePicker
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: dataItemCaixaController,
                          decoration: CustomInputDecoration.build(
                            labelText: tipoCaixaSelecionado == 'Entrada'
                                ? 'Data da Entrada'
                                : tipoCaixaSelecionado == 'Saída' ? 'Data da Saída' : 'Data da Reserva',
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Data da $tipoCaixaSelecionado é obrigatória!';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    tipoCaixaSelecionado != 'Reserva' ? const SizedBox(height: 16) : Container(),
                    tipoCaixaSelecionado != 'Reserva' ? DropdownButtonFormField<String>(
                      value: pagamentoSelecionado,
                      items: tipoCaixaSelecionado == 'Entrada'
                          ? ComunsService().getPagamentoEntradaOptions()
                          : tipoCaixaSelecionado == 'Saída' ? ComunsService().getPagamentoSaidaOptions()
                          : ComunsService().getReservaOptions(),
                      onChanged: (value) {
                        setState(() {
                          pagamentoSelecionado = value;
                        });
                      },
                      decoration: CustomInputDecoration.build(
                        labelText: tipoCaixaSelecionado == 'Saída'
                            ? 'Conta Paga?'
                            : 'Conta Recebida?',
                      ),
                    ) : Container(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _saveFinancialBox();
                            }
                          },
                          child: Text(
                            idFinancialBox == '' ? "Cadastrar" : "Atualizar",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Future<void> _saveFinancialBox() async {
    // Exibe um indicador de carregamento durante o salvamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      if (widget.idEditarFinancialBox != null) {
        idFinancialBox = widget.idEditarFinancialBox!;
        if (valorSomatorioController.text != '') {
          double valorSomatorio = FinancialBoxService()
                  .convertValorToDouble(valorItemCaixaController.text) +
              FinancialBoxService()
                  .convertValorToDouble(valorSomatorioController.text);
          valorSomatorioFormatado =
              FinancialBoxService().convertValorToString(valorSomatorio);
        }
      } else {
        idFinancialBox =
            FirebaseFirestore.instance.collection('financial_box').doc().id;
      }

      FinancialBox newFinancialBox = FinancialBox(
          idFinancialBox: idFinancialBox,
          tipoCaixaSelecionado: tipoCaixaSelecionado,
          tipoEntradaSaidaSelecionado: tipoEntradaSaidaSelecionado,
          descricaoItemCaixaController: descricaoItemCaixaController.text,
          quantidade: typeAccount == 'Comercial' ? quantidade.text : null,
          valorItemCaixaController: typeAccount == 'Comercial' ? valorItemCaixaController.text :
          widget.idEditarFinancialBox != null && valorSomatorioController.text != ''
              ? valorSomatorioFormatado
              : valorItemCaixaController.text,
          valorTotal: typeAccount == 'Comercial' ? valorTotal.text : null,
          dataItemCaixaController: dataItemCaixaController.text,
          pagamentoOK: pagamentoSelecionado);

      FinancialBoxService()
          .saveFinancialBox(idFinancialBox, widget.user.uid, newFinancialBox);
      Navigator.of(context).pop();

      customSnackBar(
        context,
        widget.idEditarFinancialBox != null
            ? tipoCaixaSelecionado == 'Entrada'
                ? "Entrada atualizada com sucesso!"
                : tipoCaixaSelecionado == 'Saída' ? 'Saída atualizada com sucesso!'
                : "Reserva atualizada com sucesso!"
            : tipoCaixaSelecionado == 'Entrada'
                ? "Entrada registrada com sucesso!"
                : tipoCaixaSelecionado == 'Saída' ? "Saída registrada com sucesso!"
                : "Reserva registrada com sucesso!",
        backgroundColor: Colors.green,
      );

      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      customSnackBar(context, "Erro ao cadastrar lançamento de caixa: $e",
          backgroundColor: Colors.red);
    }
  }
}
