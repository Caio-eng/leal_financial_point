import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/currency_text_input_formatter.dart';
import '../../components/custom_input_decoration.dart';
import '../../components/custom_snack_bar.dart';

class FinancialBoxRegisterScreen extends StatefulWidget {
  User user;
  FinancialBoxRegisterScreen({super.key, required this.user});

  @override
  State<FinancialBoxRegisterScreen> createState() => _FinancialBoxRegisterScreenState();
}

class _FinancialBoxRegisterScreenState extends State<FinancialBoxRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isUpdating = false;
  TextEditingController valorItemCaixaController = TextEditingController();
  TextEditingController descricaoItemCaixaController = TextEditingController();
  final TextEditingController dataItemCaixaController = TextEditingController();
  String? tipoCaixaSelecionado = 'Entrada';
  String? tipoEntradaSaidaSelecionado;

  List<DropdownMenuItem<String>> getEntradaOptions() {
    return const [
      DropdownMenuItem(value: 'Dizimo', child: Text('Dízimo')),
      DropdownMenuItem(value: 'Oferta', child: Text('Oferta')),
      DropdownMenuItem(value: 'Outros', child: Text('Outros')),
    ];
  }

  List<DropdownMenuItem<String>> getSaidaOptions() {
    return const [
      DropdownMenuItem(value: 'Compra', child: Text('Compras')),
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
        title: const Text('Cadastrar Item do Caixa'),
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
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: tipoCaixaSelecionado,
                            items: const [
                              DropdownMenuItem(
                                  value: 'Entrada', child: Text('Entrada')),
                              DropdownMenuItem(
                                  value: 'Saida', child: Text('Saída')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                tipoCaixaSelecionado = value;
                                tipoEntradaSaidaSelecionado = null;
                                descricaoItemCaixaController.text = '';
                                valorItemCaixaController.text = '';
                                dataItemCaixaController.text  = '';
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
                        ),
                        const SizedBox(width: 16), // Espaçamento horizontal
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: tipoEntradaSaidaSelecionado,
                            items: tipoCaixaSelecionado == 'Entrada'
                                ? getEntradaOptions()
                                : tipoCaixaSelecionado == 'Saida'
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
                        ),
                      ],
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

                              tipoCaixaSelecionado == 'Entrada' ? customSnackBar(context, "Entrada registrada com sucesso!", backgroundColor: Colors.green)
                              : customSnackBar(context, "Saída registrada com sucesso!", backgroundColor: Colors.green);
                            }
                          },
                          child: const Text(
                            "Cadastrar",
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
}