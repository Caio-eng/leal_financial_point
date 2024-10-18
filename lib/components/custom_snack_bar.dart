import 'dart:async';

import 'package:flutter/material.dart';

void customSnackBar(BuildContext context, String message, {Color backgroundColor = Colors.green}) {
  final snackBar = SnackBar(
    backgroundColor: backgroundColor,
    content: Row(
      children: [
        Icon(
          backgroundColor == Colors.green ? Icons.check_circle : Icons.error,
          color: Colors.white,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message),
        ),
      ],
    ),
    action: SnackBarAction(
      label: 'Fechar',
      textColor: Colors.white,
      onPressed: () {
        Timer(const Duration(seconds: 15), () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        });
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
