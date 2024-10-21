import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:validadores/Validador.dart';
import '../../components/custom_input_decoration.dart';
import '../../components/custom_snack_bar.dart';
import '../../services/firebase_auth.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _comfirmaSenhaController =
      TextEditingController();
  final TextEditingController _nomeController = TextEditingController();

  bool _senhaVisivel = true;
  bool _confirmarSenhaVisivel = true;
  bool _isLoading = false; // Variável para controlar o estado de loading

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.person_add_alt_1,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 50),
                    TextFormField(
                      controller: _nomeController,
                      autofocus: true,
                      keyboardType: TextInputType.name,
                      decoration: CustomInputDecoration.build(
                        labelText: 'Nome',
                        hintText: 'Digite seu nome',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Nome é obrigatório!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: CustomInputDecoration.build(
                        labelText: 'E-mail',
                        hintText: 'Digite seu E-mail',
                      ),
                      validator: (value) {
                        return Validador()
                            .add(Validar.EMAIL, msg: 'E-Mail Inválido')
                            .add(Validar.OBRIGATORIO, msg: 'Campo obrigatório')
                            .valido(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _senhaVisivel,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Senha é obrigatória!';
                        } else if (value.length < 6) {
                          return 'Senha deve ter pelo menos 6 caracteres!';
                        }
                        return null;
                      },
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
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _comfirmaSenhaController,
                      obscureText: _confirmarSenhaVisivel,
                      decoration: CustomInputDecoration.build(
                        labelText: 'Confirmar Senha',
                        hintText: 'Confirme sua Senha',
                        suffixIcon: IconButton(
                          padding: const EdgeInsets.only(right: 3),
                          icon: Icon(
                            _confirmarSenhaVisivel
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmarSenhaVisivel = !_confirmarSenhaVisivel;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 8),
                        // Exibe o CircularProgressIndicator ou o botão de cadastrar
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.blue,
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _registrarUsuario();
                                  }
                                },
                                child: const Text(
                                  "Cadastrar",
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _registrarUsuario() {
    setState(() {
      _isLoading = true; // Inicia o loading
    });

    if (_senhaController.text == _comfirmaSenhaController.text) {
      authService
          .cadastratUsuario(
        email: _emailController.text,
        senha: _senhaController.text,
        nome: _nomeController.text,
      )
          .then((String? erro) {
        setState(() {
          _isLoading = false; // Finaliza o loading
        });

        if (erro != null) {
          customSnackBar(context, erro, backgroundColor: Colors.red);
        } else {
          User? usuario =
              FirebaseAuth.instance.currentUser; // Obtém o usuário atual

          if (usuario != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(user: usuario)),
            );
            customSnackBar(context, "Usuário criado com sucesso!",
                backgroundColor: Colors.green);
          }
        }
      });
    } else {
      setState(() {
        _isLoading = false; // Finaliza o loading se as senhas não correspondem
      });
      customSnackBar(context, "As Senhas não correspondem",
          backgroundColor: Colors.red);
    }
  }
}
