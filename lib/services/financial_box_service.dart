import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leal_apontar/model/financial_box.dart';

class FinancialBoxService {

  Stream<QuerySnapshot> findMyFinancialBox(String userId) {
    return FirebaseFirestore.instance
        .collection('my_financial_box')
        .doc(userId)
        .collection('financial_box')
        .snapshots();
  }

  Stream<QuerySnapshot> findMyFinancialBoxEntradas(String userId) {
    return FirebaseFirestore.instance
        .collection('my_financial_box')
        .doc(userId)
        .collection('financial_box')
        .where('tipoCaixaSelecionado', isEqualTo: 'Entrada')
        .snapshots();
  }

  Stream<QuerySnapshot> findMyFinancialBoxSaidas(String userId) {
    return FirebaseFirestore.instance
        .collection('my_financial_box')
        .doc(userId)
        .collection('financial_box')
        .where('tipoCaixaSelecionado', isEqualTo: 'Saída')
        .snapshots();
  }

  void saveFinancialBox(String idFinancialBox, String uid, FinancialBox newFinancialBox) async {
    await FirebaseFirestore.instance
        .collection('financial_box')
        .doc(idFinancialBox)
        .set(newFinancialBox.toMap());

    await FirebaseFirestore.instance
        .collection("my_financial_box")
        .doc(uid)
        .collection("financial_box")
        .doc(idFinancialBox)
        .set(newFinancialBox.toMap());
  }

  void deleteFinancialBox(String idFinancialBox, String uid) async {
    await FirebaseFirestore.instance
        .collection('financial_box')
        .doc(idFinancialBox)
        .delete()
        .then((_) {
      FirebaseFirestore.instance
          .collection("my_financial_box")
          .doc(uid)
          .collection("financial_box")
          .doc(idFinancialBox)
          .delete();
    });
  }
}