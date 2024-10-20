import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leal_apontar/components/menu.dart';
import 'package:leal_apontar/model/financial_box.dart';
import 'package:leal_apontar/screen/fiancial_screen/financial_box_register_screen.dart';
import 'package:leal_apontar/services/financial_box_service.dart';

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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FinancialBoxService().findMyFinancialBox(widget.user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar o lançamento de caixa: ${snapshot.error}');
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

                  return ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: financialBoxs.length,
                    itemBuilder: (context, index) {
                      final financialBox = financialBoxs[index];
                      return GestureDetector(
                        onTap: () {

                        },
                        child: CustomCardItem(
                          title: '${financialBox.tipoCaixaSelecionado} ${financialBox.dataItemCaixaController}',
                          subtitle: '${financialBox.descricaoItemCaixaController}',
                          icon: Icons.attach_money,
                          owner: 'Valor: ${financialBox.valorItemCaixaController}',
                          onOptionSelected: (option) {
                            switch (option) {
                              case 'Editar':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FinancialBoxRegisterScreen(user: widget.user, idEditarFinancialBox: financialBox.idFinancialBox,),
                                  ),
                                );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FinancialBoxRegisterScreen(user: widget.user,),
              ),
            );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> deleteFinancialBox(String idFinancialBox) async {
    showCustomAlertDialog(
        context,
        'Confirmação de Exclusão',
        'Tem certeza que deseja excluir este lançamento de caixa?',
        'Excluir',
        'Cancelar', () async {
      FinancialBoxService().deleteFinancialBox(idFinancialBox, widget.user.uid);
      customSnackBar(context, 'Lançamento de caixa excluído com sucesso!');
    });
  }
}
