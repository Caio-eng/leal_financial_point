import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsuarioService {

  Future<Map<String, dynamic>?> carregarUsuario(String userId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userProfileSnapshot.exists) {
          return userProfileSnapshot.data() as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('Erro ao carregar usuário: $e');
    }
    return null; // Retorna nulo se o usuário não existir ou houver um erro
  }

  Stream<QuerySnapshot> findAllUsers(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> findAllUsersTypeAdmin(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: userId)
        .where('typeUser', isEqualTo: 'ADMIN')
        .snapshots();
  }

  Stream<QuerySnapshot> findAllUsersTypeUser(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: userId)
        .where('typeUser', isEqualTo: 'USER')
        .snapshots();
  }

  void updateTypeUser(String userId, String typeUser, bool isAtivo) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'typeUser': typeUser, 'isAtivo': isAtivo});
  }
}