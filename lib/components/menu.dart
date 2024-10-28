import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leal_apontar/components/show_custom_alert_dialog.dart';
import 'package:leal_apontar/screen/cotacao_screen/cotacao_screen.dart';
import 'package:leal_apontar/screen/fiancial_screen/financial_box_screen.dart';
import 'package:leal_apontar/screen/perfil_screen/users_screen.dart';

import '../screen/home_screen.dart';
import '../screen/login_screen/login_screen.dart';
import '../screen/perfil_screen/register_perfil_screen.dart';
import '../services/firebase_auth.dart';
import 'custom_snack_bar.dart';

class Menu extends StatefulWidget {
  final User user;
  const Menu({super.key, required this.user});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool perfilExistente = false; // Variável para armazenar se o perfil existe
  User? user;
  bool isAtivo = true;
  var nome;
  var photoUrl;
  var typeUser;

  @override
  void initState() {
    super.initState();
    verificarPerfilExistente(widget.user.uid);
  }

  @override
  void dispose() {
    // Não utilize o context diretamente aqui
    super.dispose();
  }

  Future<void> verificarPerfilExistente(String userId) async {
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      photoUrl = user!.photoURL;
      nome = user!.displayName;

      DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userProfileSnapshot.exists) {
        Map<String, dynamic> userProfileData = userProfileSnapshot.data() as Map<String, dynamic>;
        typeUser = userProfileData['typeUser'];
        isAtivo = userProfileData['isAtivo'];

        setState(() {
          perfilExistente = true;
        });
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: GestureDetector(
              onTap: () {
                _mostrarPerfilDialog(context, widget.user);
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: (widget.user.photoURL != null)
                    ? NetworkImage(photoUrl!)
                    : const AssetImage('imagens/logo.png'),
              ),
            ),
            accountName: Text(nome ?? ''),
            accountEmail: Text(widget.user.email!),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen(user: widget.user)));
            },
          ),
          perfilExistente == true && typeUser == 'SUPER_ADMIN' ? ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Usuários'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UsersScreen(user: widget.user)));
            },
          ) : Container(),
          perfilExistente == true && typeUser == 'SUPER_ADMIN' ? ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Cotação'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CotacaoScreen(user: widget.user)));
            },
          ) : Container(),
          perfilExistente == true && isAtivo == true ? ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('Lançamentos de Caixa'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FinancialBoxScreen(user: widget.user)));
            },
          ) : Container(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              await AuthService().deslogar(); // Certifique-se de que esse método retorna um Future
              setState(() {}); // Atualiza o estado para refletir o logout
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _mostrarPerfilDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: (user.photoURL != null &&
                    user.photoURL!.isNotEmpty)
                    ? NetworkImage(photoUrl!)
                    : const AssetImage('imagens/logo.png'), // Imagem padrão
              ),
              const SizedBox(height: 20),
              Text(
                nome ?? 'Nome não disponível',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user.email ?? 'Email não disponível',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RegisterPerfilScreen(user: widget.user)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                    perfilExistente ? 'Atualizar Perfil' : 'Concluir Perfil'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _confirmarExclusao(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Excluir Conta'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmarExclusao(BuildContext context) {
    showCustomAlertDialog(
        context,
        'Excluir Conta',
        'Tem certeza de que quer excluir sua conta?',
        'Excluir',
        'Cancelar', () async {
      _deletarConta();
    });
  }

  Future<void> _deletarConta() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Deleta o perfil do usuário no Firestore
        DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userProfileSnapshot.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .delete();
        }

        await AuthService().excluirContaWithEmail(context, email: user.email!);
        await FirebaseAuth.instance.signOut();
      }

      // Verifica se o widget ainda está montado antes de realizar a navegação
    } catch (e) {
      print("Erro ao excluir conta: $e");
    }
  }
}