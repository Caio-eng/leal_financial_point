import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leal_apontar/model/financial_box.dart';
import 'package:leal_apontar/services/usuario_service.dart';

class FinancialBoxService {

  Stream<QuerySnapshot> findMyFinancialBox(String userId, bool ordemData) async* {
    String typeAccount = await UsuarioService().getTypeAccount(userId);

    yield* FirebaseFirestore.instance
        .collection('my_financial_box')
        .doc(userId)
        .collection(typeAccount == 'Pessoal' ? 'financial_box' : typeAccount)
        .orderBy('dataItemCaixaController', descending: ordemData)
        .snapshots();
  }


  Stream<QuerySnapshot> findMyFinancialBoxEntradas(String userId, bool ordemData) async* {
    String typeAccount = await UsuarioService().getTypeAccount(userId);

    yield* FirebaseFirestore.instance
        .collection('my_financial_box')
        .doc(userId)
        .collection(typeAccount == 'Pessoal' ? 'financial_box' : typeAccount) // Verifique se o tipo de conta é 'Pessoal' ou 'Administrador'financial_box')
        .where('tipoCaixaSelecionado', isEqualTo: 'Entrada')
        .orderBy('dataItemCaixaController', descending: ordemData)
        .snapshots();
  }

  Stream<QuerySnapshot> findMyFinancialBoxSaidas(String userId, bool ordemData) async* {
    String typeAccount = await UsuarioService().getTypeAccount(userId);
    yield* FirebaseFirestore.instance
        .collection('my_financial_box')
        .doc(userId)
        .collection(typeAccount == 'Pessoal' ? 'financial_box' : typeAccount) // Verifique se o tipo de conta é 'Pessoal' ou 'Administrador'financial_box')
        .where('tipoCaixaSelecionado', isEqualTo: 'Saída')
        .orderBy('dataItemCaixaController', descending: ordemData)
        .snapshots();
  }

  Stream<QuerySnapshot> findMyFinancialBoxReservas(String userId, bool ordemData) async* {
    String typeAccount = await UsuarioService().getTypeAccount(userId);
    yield* FirebaseFirestore.instance
        .collection('my_financial_box')
        .doc(userId)
        .collection(typeAccount == 'Pessoal' ? 'financial_box' : typeAccount)
        .where('tipoCaixaSelecionado', isEqualTo: 'Reserva')
        .orderBy('dataItemCaixaController', descending: ordemData)
        .snapshots();
  }

  void saveFinancialBox(String idFinancialBox, String uid, FinancialBox newFinancialBox) async {
    String typeAccount = await UsuarioService().getTypeAccount(uid);

    await FirebaseFirestore.instance
        .collection('financial_box')
        .doc(idFinancialBox)
        .set(newFinancialBox.toMap());

    await FirebaseFirestore.instance
        .collection("my_financial_box")
        .doc(uid)
        .collection(typeAccount == 'Pessoal' ? 'financial_box' : typeAccount) // Verifique se o tipo de conta é 'Pessoal' ou 'Administrador"financial_box")
        .doc(idFinancialBox)
        .set(newFinancialBox.toMap());
  }

  void deleteFinancialBox(String idFinancialBox, String uid) async {
    String typeAccount = await UsuarioService().getTypeAccount(uid);

    await FirebaseFirestore.instance
        .collection('financial_box')
        .doc(idFinancialBox)
        .delete()
        .then((_) {
      FirebaseFirestore.instance
          .collection("my_financial_box")
          .doc(uid)
          .collection(typeAccount == 'Pessoal' ? 'financial_box' : typeAccount) // Verifique se o tipo de conta é 'Pessoal' ou 'Administrador"financial_box")
          .doc(idFinancialBox)
          .delete();
    });

  }

  Future<bool> checkIfFinancialBoxExistsForDate(FinancialBox financialBox, String date, String userId) async {
    String typeAccount = await UsuarioService().getTypeAccount(userId);

    QuerySnapshot queryResult = await FirebaseFirestore.instance
        .collection('my_financial_box')
        .doc(userId)
        .collection(typeAccount == 'Pessoal' ? 'financial_box' : typeAccount)
        .where('dataItemCaixaController', isEqualTo: date)
        .get();

    return queryResult.docs.isNotEmpty; // Retorna true se existir, false caso contrário
  }

  Future<bool> checkIfFinancialBoxExists(FinancialBox financialBox, String userId) async {
    String typeAccount = await UsuarioService().getTypeAccount(userId);
    QuerySnapshot queryResult = await FirebaseFirestore.instance
        .collection('my_financial_box')
        .doc(userId)
        .collection(typeAccount == 'Pessoal' ? 'financial_box' : typeAccount) // Verifique se o tipo de conta é 'Pessoal'financial_box')
        .get();

    return queryResult.docs.isNotEmpty; // Retorna true se existir, false caso contrário
  }

  double convertValorToDouble(String value) {
    return double.parse( value
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim()
    );
  }

  String convertValorToString(double value) {
    String valorSomatorioFormatado = 'R\$ ${value.toStringAsFixed(2)}';
    return valorSomatorioFormatado.replaceAll('.', ',');
  }

  String removeCaracteres(String value) {
    return value
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
  }

}