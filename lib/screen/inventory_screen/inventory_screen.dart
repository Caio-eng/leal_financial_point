import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leal_apontar/components/menu.dart';

class InventoryScreen extends StatefulWidget {
  User user;
  InventoryScreen({super.key, required this.user});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque de produtos'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      drawer: Menu(user: widget.user),
    );
  }
}