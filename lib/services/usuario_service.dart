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

  Future<String> getTypeAccount(String userId) async {
    try {
      // Obtém o documento do perfil do usuário com base no ID
      DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userProfileSnapshot.exists) {
        Map<String, dynamic> userProfileData =
        userProfileSnapshot.data() as Map<String, dynamic>;
        String typeAccount = userProfileData['typeAccount'] ?? '';

        // Retorna o valor de 'typeAccount'
        return typeAccount;
      } else {
        return '';
      }
    } catch (e) {
      print('Erro ao obter o tipo de conta: $e');
      return '';
    }
  }

  void updateTypeUser(String userId, String typeUser, bool isAtivo) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'typeUser': typeUser, 'isAtivo': isAtivo});
  }

  void updateTypeAccountUser(String userId, String typeAccount) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'typeAccount': typeAccount});
  }
}