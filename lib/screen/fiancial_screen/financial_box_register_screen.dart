import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leal_apontar/model/financial_box.dart';
import 'package:leal_apontar/services/financial_box_service.dart';

import '../../components/currency_text_input_formatter.dart';
import '../../components/custom_input_decoration.dart';
import '../../components/custom_snack_bar.dart';

class FinancialBoxRegisterScreen extends StatefulWidget {
  User user;
  final String? idEditarFinancialBox;
  FinancialBoxRegisterScreen({super.key, required this.user, this.idEditarFinancialBox});

  @override
  State<FinancialBoxRegisterScreen> createState() => _FinancialBoxRegisterScreenState();
}

class _FinancialBoxRegisterScreenState extends State<FinancialBoxRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController valorItemCaixaController = TextEditingController();
  TextEditingController descricaoItemCaixaController = TextEditingController();
  String? pagamentoSelecionado = '';
  final TextEditingController dataItemCaixaController = TextEditingController();
  String? tipoCaixaSelecionado = 'Entrada';
  String? tipoEntradaSaidaSelecionado;
  late String idFinancialBox = '';

  @override
  void initState() {
    super.initState();
    _recoverFinancialBox();
  }

  Future<void> _recoverFinancialBox() async {
    try {
      DocumentSnapshot financialBoxDoc = await FirebaseFirestore.instance
          .collection('financial_box')
          .doc(widget.idEditarFinancialBox)
          .get();

      if (financialBoxDoc.exists) {
        Map<String, dynamic> imovelData =
        financialBoxDoc.data() as Map<String, dynamic>;

        setState(() {
          idFinancialBox = imovelData['idFinancialBox'] ?? '';
          tipoCaixaSelecionado = imovelData['tipoCaixaSelecionado'] ?? '';
          tipoEntradaSaidaSelecionado =
              imovelData['tipoEntradaSaidaSelecionado'] ?? '';
          descricaoItemCaixaController.text =
              imovelData['descricaoItemCaixaController'] ?? '';
          valorItemCaixaController.text =
              imovelData['valorItemCaixaController'] ?? '';
          dataItemCaixaController.text =
              imovelData['dataItemCaixaController'] ?? '';
          pagamentoSelecionado = imovelData['pagamentoOK'] ?? '';
        });
      }
    } catch (e) {
      customSnackBar(context, "Erro ao recuperar item do caixa: $e",
          backgroundColor: Colors.red);
    }
  }

  List<DropdownMenuItem<String>> getEntradaOptions() {
    return const [
      DropdownMenuItem(value: 'Dizimo', child: Text('Dízimo')),
      DropdownMenuItem(value: 'Oferta', child: Text('Oferta')),
      DropdownMenuItem(value: 'Outros', child: Text('Outros')),
    ];
  }

  List<DropdownMenuItem<String>> getSaidaOptions() {
    return const [
      DropdownMenuItem(value: 'Compras', child: Text('Compras')),
      DropdownMenuItem(value: 'Despesas', child: Text('Despesas Gerais')),
      DropdownMenuItem(value: 'Outros', child: Text('Outros')),
    ];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      String formattedDate = "${pickedDate.day.toString().padLeft(
          2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate
          .year}"; // Formato dd/MM/yyyy
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
        title: Text(idFinancialBox == '' ? 'Cadastrar Laçamento de Caixa' : 'Atualizar Laçamento de Caixa'),
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
                        DropdownMenuItem(
                            value: 'Entrada', child: Text('Entrada')),
                        DropdownMenuItem(
                            value: 'Saída', child: Text('Saída')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          tipoCaixaSelecionado = value;
                          tipoEntradaSaidaSelecionado = null;
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
                    const SizedBox(height: 16), // Espaçamento horizontal
                    DropdownButtonFormField<String>(
                      value: tipoEntradaSaidaSelecionado,
                      items: tipoCaixaSelecionado == 'Entrada'
                          ? getEntradaOptions()
                          : tipoCaixaSelecionado == 'Saída'
                          ? getSaidaOptions()
                          : [],
                      onChanged: (value) {
                        setState(() {
                          tipoEntradaSaidaSelecionado = value;
                        });
                      },
                      decoration: CustomInputDecoration.build(
                        labelText: tipoCaixaSelecionado == 'Entrada' ? 'Tipo da Entrada' : 'Tipo da Saída',
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione o tipo de entrada/saída';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descricaoItemCaixaController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Descrição é obrigatória!';
                        }
                        return null;
                      },
                      decoration: CustomInputDecoration.build(
                        hintText: tipoCaixaSelecionado == 'Entrada' ? 'ex: Dízimo do João' : 'ex: Conta de energia',
                        labelText: tipoCaixaSelecionado == 'Entrada' ? 'Descrição da Entrada' : 'Descrição da Saída',
                        suffixIcon: const Icon(Icons.description),
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: valorItemCaixaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CurrencyTextInputFormatter()
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Valor do Item da caixa é obrigatório!';
                        }
                        return null;
                      },
                      decoration: CustomInputDecoration.build(
                        hintText: tipoCaixaSelecionado == 'Entrada' ? 'Digite o valor da entrada' : 'Digite o valor da saída',
                        labelText: tipoCaixaSelecionado == 'Entrada' ? 'Valor da Entrada' : 'Valor da Saída',
                        suffixIcon: const Icon(Icons.monetization_on),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        _selectDate(context); // Exibir o DatePicker
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: dataItemCaixaController,
                          decoration: CustomInputDecoration.build(
                            labelText: tipoCaixaSelecionado == 'Entrada' ? 'Data da Entrada' : 'Data da Saída',
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Data de entrada/saída é obrigatória';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: pagamentoSelecionado,
                      items: const [
                        DropdownMenuItem(
                            value: '', child: Text('Selecione uma opção')),
                        DropdownMenuItem(
                            value: 'Pago', child: Text('Pago')),
                        DropdownMenuItem(
                            value: 'Falta Pagar', child: Text('Falta Pagar')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          pagamentoSelecionado = value;
                        });
                      },
                      decoration: CustomInputDecoration.build(
                        labelText: 'Conta Paga?',
                        hintText: 'Selecione uma opção, isto é opicional',
                      ),
                    ),
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
      } else {
        idFinancialBox = FirebaseFirestore.instance.collection('financial_box').doc().id;
      }

      FinancialBox newFinancialBox = FinancialBox(
        idFinancialBox: idFinancialBox,
        tipoCaixaSelecionado: tipoCaixaSelecionado,
        tipoEntradaSaidaSelecionado: tipoEntradaSaidaSelecionado,
        descricaoItemCaixaController: descricaoItemCaixaController.text,
        valorItemCaixaController: valorItemCaixaController.text,
        dataItemCaixaController: dataItemCaixaController.text,
        pagamentoOK: pagamentoSelecionado
      );

      FinancialBoxService().saveFinancialBox(idFinancialBox, widget.user.uid, newFinancialBox);
      Navigator.of(context).pop();

      customSnackBar(
        context,
        widget.idEditarFinancialBox != null
            ? tipoCaixaSelecionado == 'Entrada' ? "Entrada atualizada com sucesso!" : "Saída atualizada com sucesso!"
            : tipoCaixaSelecionado == 'Entrada' ? "Entrada registrada com sucesso!" : "Saída registrada com sucesso!",
        backgroundColor: Colors.green,
      );

      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      customSnackBar(context, "Erro ao cadastrar imóvel: $e",
          backgroundColor: Colors.red);
    }
  }
}