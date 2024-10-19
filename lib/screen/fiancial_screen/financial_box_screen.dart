import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leal_apontar/components/menu.dart';
import 'package:leal_apontar/screen/fiancial_screen/financial_box_register_screen.dart';

class FinancialBoxScreen extends StatefulWidget {
  User user;
  FinancialBoxScreen({super.key, required this.user});

  @override
  State<FinancialBoxScreen> createState() => _FinancialBoxScreenState();
}

class _FinancialBoxScreenState extends State<FinancialBoxScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caixa'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      drawer: Menu(user: widget.user),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FinancialBoxRegisterScreen(user: widget.user,),
              ),
            );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
