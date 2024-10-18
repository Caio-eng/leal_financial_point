import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leal_apontar/screen/login_screen/register_screen.dart';
import 'package:leal_apontar/screen/login_screen/reset_password_modal.dart';

import '../../components/custom_input_decoration.dart';
import '../../components/custom_snack_bar.dart';
import '../../services/firebase_auth.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  AuthService authService = AuthService();
  bool _senhaVisivel = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          color: Colors.teal,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Bem Vindo!', style: TextStyle(fontSize: 30),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: CustomInputDecoration.build(
                          labelText: 'E-mail',
                          hintText: 'Digite seu E-mail',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor, digite seu E-mail!';
                          } else if (!value.contains('@')) {
                            return 'Por favor, digite um E-mail válido!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _senhaController,
                          obscureText: _senhaVisivel,
                          decoration: CustomInputDecoration.build(
                            labelText: 'Senha',
                            hintText: 'Digite sua Senha',
                            suffixIcon: IconButton(
                              padding: const EdgeInsets.only(right: 3),
                              icon: Icon(
                                _senhaVisivel
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _senhaVisivel = !_senhaVisivel;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Por favor, digite sua Senha!';
                            }
                            return null;
                          }
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _login();
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Entrar",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Não tem conta?, clique aqui',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ResetPasswordModal();
                            },
                          );
                        },
                        child: const Text(
                          'Equeceu sua senha?',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {

    final String? error = await authService.entrarUsuario(
      email: _emailController.text,
      senha: _senhaController.text,
    );

    if (error != null) {
      customSnackBar(context, error, backgroundColor: Colors.red);
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(user: user,)));
      }
    }
  }
}