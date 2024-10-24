import 'package:flutter/material.dart';

Future<void> showCustomAlertDialog(
  BuildContext context,
  String title,
  String content,
  String confirmText,
  String cancelText,
  Future<void> Function() onConfirm, {
  bool showLoadingIndicator =
      false, // Adiciona o indicador de carregamento como opcional
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      bool isLoading = false; // Controla o estado do carregamento

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: isLoading
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Por favor, aguarde...'),
                    ],
                  )
                : Text(
                    content,
                    style: const TextStyle(fontSize: 16),
                  ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () async {
                  if (showLoadingIndicator) {
                    setState(() {
                      isLoading = true; // Ativa o indicador de carregamento
                    });
                  }
                  await onConfirm(); // Chama a função de confirmação
                  Navigator.of(context).pop();
                },
                child: Text(confirmText),
              ),
            ],
          );
        },
      );
    },
  );
}
