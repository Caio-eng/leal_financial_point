import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leal_apontar/components/currency_text_input_formatter.dart';
import 'package:leal_apontar/components/custom_snack_bar.dart';
import 'package:leal_apontar/services/cotacao_service.dart';

import 'components/custom_Input_decoration.dart';
import 'model/moeda.dart';

class CotacaoScreen extends StatefulWidget {
  const CotacaoScreen({super.key});

  @override
  State<CotacaoScreen> createState() => _CotacaoScreenState();
}

class _CotacaoScreenState extends State<CotacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<Moeda> cotacaoFuture;
  final TextEditingController _realController = TextEditingController();
  double? resultadoDolar;

  @override
  void initState() {
    super.initState();
    cotacaoFuture = CotacaoService.buscaCotacaoMoedaRecente();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Cotação Recente'),
        backgroundColor: Colors.teal,
      ),
      body: Form(
        key: _formKey,
        child: FutureBuilder<Moeda>(
          future: cotacaoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erro ao carregar cotação: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            } else if (snapshot.hasData) {
              final cotacao = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.attach_money, size: 30, color: Colors.teal),
                        SizedBox(width: 10),
                        Text(
                          'Real Brasileiro / Dólar Americano ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Código de Conversão:',
                              style: TextStyle(fontSize: 18, color: Colors.black54),
                            ),
                            Text(
                              '${cotacao.codein} / ${cotacao.code}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.compare_arrows, size: 24, color: Colors.black54),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1.5),
                    TextFormField(
                      controller: _realController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CurrencyTextInputFormatter()
                      ],
                      decoration: CustomInputDecoration.build(
                        labelText: 'Real',
                        hintText: 'Insira um valor em real',
                        suffixIcon: GestureDetector(
                            onTap: () {
                              cacularDolar(cotacao.bid);
                            },
                            child: const Icon(Icons.search)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um valor';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    if (resultadoDolar != null)
                      Text(
                        '${_realController.text} reais equivalem à \$${resultadoDolar!.toStringAsFixed(2)} dólares',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Licitação de Compra:',
                              style: TextStyle(fontSize: 18, color: Colors.black54),
                            ),
                            Text(
                              'R\$ ${cotacao.bid}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.attach_money, size: 24, color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Licitação de Venda:',
                              style: TextStyle(fontSize: 18, color: Colors.black54),
                            ),
                            Text(
                              'R\$ ${cotacao.ask}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.money_off, size: 24, color: Colors.redAccent),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
            return Container(); // Estado inicial
          },
        ),
      ),
    );
  }

  void cacularDolar(String licitacaoDeCompra) {
    if (_formKey.currentState!.validate()) {
      String realValue = _realController.text
          .replaceAll(RegExp(r'[^\d,]'), '')
          .replaceAll(',', '.');

      double valorReal = double.parse(realValue);
      double precoDolar = valorReal / double.parse(licitacaoDeCompra);

      setState(() {
        resultadoDolar = precoDolar;
        customSnackBar(context, 'Calculo concluído co sucesso', backgroundColor: Colors.green);
      });
    }
  }
}