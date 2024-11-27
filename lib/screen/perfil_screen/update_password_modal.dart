import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/custom_input_decoration.dart';
import '../../components/custom_snack_bar.dart';
import '../../services/firebase_auth.dart';

class UpdatePasswordModal extends StatefulWidget {
  final User user;
  const UpdatePasswordModal({super.key, required this.user});

  @override
  State<UpdatePasswordModal> createState() => _UpdatePasswordModalState();
}

class _UpdatePasswordModalState extends State<UpdatePasswordModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _comfirmaSenhaController = TextEditingController();
  bool _senhaVisivel = true;
  bool _confirmarSenhaVisivel = true;

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
          child: Text('Atualizar senha')
      ),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                  labelText: 'Nova Senha',
                  hintText: 'Digite a nova Senha',
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
                  hintText: 'Confirme a nova Senha',
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
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_senhaController.text != _comfirmaSenhaController.text) {
                  customSnackBar(context, 'As senhas devem ser iguais!', backgroundColor: Colors.red);
                }
                if(_formKey.currentState!.validate() && _comfirmaSenhaController.text == _senhaController.text) {
                  authService.atualizarSenha(
                      senha: _comfirmaSenhaController.text
                  ).then((String? erro) {
                    Navigator.of(context).pop();
                    if(erro != null) {
                      customSnackBar(context, erro, backgroundColor: Colors.red);
                    } else {
                      customSnackBar(
                          context, 'Senha atualizada com sucesso!',
                          backgroundColor: Colors.green );
                    }
                  });
                }
              },
              child: const Text('Atualizar senha'),
            )
          ],
        ),
      ],
    );
  }
}