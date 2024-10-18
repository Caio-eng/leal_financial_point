import 'package:flutter/material.dart';

Future<void> showCustomAlertDialog(
    BuildContext context,
    String title,
    String content,
    String confirmText,
    String cancelText,
    Future<void> Function() onConfirm
    ) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
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
        content: Text(
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
              await onConfirm(); // Chama a função de confirmação
              Navigator.of(context).pop();
            },
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
}