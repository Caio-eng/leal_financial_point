import 'package:flutter/material.dart';

import 'custom_Input_decoration.dart';

Future<String?> confirmarSenhaDialog(BuildContext context, String nomeAcao) async {
  final _formKey = GlobalKey<FormState>();
  String? senha;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Form(
        key: _formKey,
        child: AlertDialog(
          title: Center(child: Text(nomeAcao)),
          content: TextFormField(
            obscureText: true,
            decoration: CustomInputDecoration.build(
              labelText: 'Digite sua senha',
              suffixIcon: const Icon(Icons.lock),
            ),
            onChanged: (value) {
              senha = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Senha obrigatória';
              }
              return null;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                if( _formKey.currentState!.validate() ) {
                  Navigator.of(context).pop(senha);
                }
              },
            ),
          ],
        ),
      );
    },
  );

  return senha; // Retorna a senha inserida pelo usuário ou null se for cancelado
}
