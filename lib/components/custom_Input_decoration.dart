import 'package:flutter/material.dart';

class CustomInputDecoration {
  static InputDecoration build({
    String? labelText,
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    EdgeInsets contentPadding = const EdgeInsets.fromLTRB(32, 16, 32, 16),
    Color fillColor = Colors.white,
    double borderRadius = 32.0,
  }) {
    return InputDecoration(
      contentPadding: contentPadding,
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
    );
  }
}