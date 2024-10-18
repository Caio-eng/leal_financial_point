import 'package:flutter/material.dart';

import '../../components/custom_input_decoration.dart';
import '../../components/custom_snack_bar.dart';
import '../../services/firebase_auth.dart';

class ResetPasswordModal extends StatefulWidget {
  const ResetPasswordModal({super.key});

  @override
  State<ResetPasswordModal> createState() => _ResetPasswordModalState();
}

class _ResetPasswordModalState extends State<ResetPasswordModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
          child: Text('Recuperar senha')
      ),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: CustomInputDecoration.build(
              labelText: 'E-mail',
              hintText: 'Digite seu E-mail',
              suffixIcon: const Icon(Icons.email),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Informe um endereço de e-mail válido!';
              } else {
                return null;
              }
            },
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
                if(_formKey.currentState!.validate()) {
                  authService.redefinicaoSenha(
                      email: _emailController.text
                  ).then((String? erro) {
                    Navigator.of(context).pop();

                    if(erro != null) {
                      customSnackBar(context, erro, backgroundColor: Colors.red);
                    } else {
                      customSnackBar(
                          context, 'Um e-mail de redefinição de senha foi enviado para o seu endereço de e-mail: ${_emailController.text}',
                          backgroundColor: Colors.green );
                    }
                  });
                }
              },
              child: const Text('Recuperar senha'),
            )
          ],
        ),
      ],
    );
  }
}