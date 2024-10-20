import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/menu.dart';
import '../services/usuario_service.dart';

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
      setState(() {});
    } else {
      print('Erro ao recuperar os dados do usuário');
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
                // Aumentando o tamanho da imagem e centralizando
                Container(
                  width: 200, // Aumente o tamanho da imagem
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Torna a imagem circular
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Sombra leve
                        blurRadius: 10,
                        spreadRadius: 5,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "imagens/logo.png",
                      fit: BoxFit.cover, // Garante que a imagem se ajuste bem ao container
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Bem-vindo ${name ?? widget.user.displayName }!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal, // Altere para a cor desejada
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}