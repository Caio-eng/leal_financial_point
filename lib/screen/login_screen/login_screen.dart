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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.teal,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Column(
            children: [
             Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 30,
                        ),
                        children: [
                          TextSpan(
                            text: 'Leal Financial',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )
                          ),
                        ]
                      )
                    ),
                    const SizedBox(height: 16,),
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
                  ],
                 ),
                ),
              
              //Formulário
              Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(45)
                    ),
                  ),
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.stretch,
                     children: [
                
                      //Email
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
                
                      //Senha
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
                
                      //Botão de Entrar
                      SizedBox(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            )
                          ),
                          onPressed: (){
                            if (_formKey.currentState!.validate()) {
                                _login();
                              }
                          }, 
                          child: const Text(
                            'Entrar', 
                            style: TextStyle(
                              fontSize: 18
                              ),
                            )
                          ),
                      ),
                      const SizedBox(height: 16),
                
                      // Esqueceu a senha
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const ResetPasswordModal();
                              },
                            );
                          }, 
                        child: const Text(
                          'Esqueceu a senha?',
                          style: TextStyle(
                            color: Colors.teal,
                            ),
                          )
                        ),
                      ),
                
                      // Divisor
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.withAlpha(90),
                                thickness: 2,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Text('ou'),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.withAlpha(90),
                                thickness: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                
                      //Botão de novo usuário
                      SizedBox(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)
                            ),
                            side: const BorderSide(
                              width: 2,
                              color: Colors.teal
                            )
                          ),
                          onPressed: (){
                           Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterScreen(),
                                  ),
                             );
                          }, 
                          child: const Text(
                            'Criar conta',
                            style: TextStyle(
                              fontSize: 18
                            ),
                            )
                          ),
                      )
                     ], 
                  ),
                ),
              ),
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