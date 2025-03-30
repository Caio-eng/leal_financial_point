import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/custom_snack_bar.dart';
import '../components/menu.dart';
import '../services/usuario_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  String titulo = 'Leal Financial Point';

  HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var id;
  var name;
  bool perfilCompleto = true;
  bool isAtivo = true;

  @override
  void initState() {
    super.initState();
    carregarUsuario(widget.user.uid);
  }

  Future<void> carregarUsuario(String userId) async {
    Map<String, dynamic>? userData = await UsuarioService().carregarUsuario(userId);

    if (userData != null) {
      name = widget.user.displayName;
      id = userData['uid'];
      isAtivo = userData['isAtivo'];
      perfilCompleto = true;
      setState(() {});
    } else {
      perfilCompleto = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu(user: widget.user),
      appBar: AppBar(
        title: Text(widget.titulo),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 5,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "imagens/logo.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Bem-vindo ${name ?? widget.user.displayName }!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                perfilCompleto == false ? const SizedBox(height: 20) : const SizedBox(),
                perfilCompleto == false ?
                const Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.warning),
                        title:  Text('Para usar a aplicação necessita completar o perfil!'),
                        subtitle: Text('Clique no menu, depois clique na imagem e clique concluir perfil!'),
                      ),
                    ],
                  ),
                ): isAtivo == false
                    ? Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const ListTile(
                              leading: Icon(Icons.warning),
                              title:  Text('Sua Conta foi Desativada!'),
                              subtitle: Text('Entre em contato com o administrador do sistema, para reativá-la.'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: const Text('Entrar em Contato',),
                                  onPressed: () async {
                                    final url = Uri.parse(
                                      'https://api.whatsapp.com/send?phone=5562991417406&text=${Uri.encodeComponent(
                                              'Olá! Estou com perfil inativo, quero reativa-lo!\nEmail: ${widget.user.email}')}',
                                    );

                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    } else {
                                      customSnackBar(context, 'Não foi possível abrir o WhatsApp',
                                          backgroundColor: Colors.red);
                                    }
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ): Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}