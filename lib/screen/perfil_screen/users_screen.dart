import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leal_apontar/components/menu.dart';
import 'package:leal_apontar/model/usuario.dart';
import 'package:leal_apontar/services/comuns_service.dart';
import 'package:leal_apontar/services/usuario_service.dart';

import '../../components/custom_Input_decoration.dart';
import '../../components/custom_card_item.dart';
import '../../components/custom_snack_bar.dart';

class UsersScreen extends StatefulWidget {
  User user;
  UsersScreen({super.key, required this.user});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String searchQuery = '';
  String filtro = 'todos';
  final TextEditingController _searchController = TextEditingController();
  late List<Usuario> usuarios = [];
  String typeUserSelecionado = '';
  String typeNivelSelecionado = '';
  final _formKey = GlobalKey<FormState>();
  final typeUserController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      drawer: Menu(user: widget.user),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ExpansionTile(
              title: const Text('Filtros de Pesquisa'),
              leading: const Icon(Icons.filter_list),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: 'Digite o que deseja pesquisar',
                      labelText: 'Pesquisar',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            searchQuery = _searchController.text.trim().toLowerCase();
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: 'todos',
                            groupValue: filtro,
                            onChanged: (value) {
                              setState(() {
                                filtro = value!;
                              });
                            },
                          ),
                          const Text('Todos'),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'admins',
                            groupValue: filtro,
                            onChanged: (value) {
                              setState(() {
                                filtro = value!;
                              });
                            },
                          ),
                          const Text('Admins'),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'usuarios',
                            groupValue: filtro,
                            onChanged: (value) {
                              setState(() {
                                filtro = value!;
                              });
                            },
                          ),
                          const Text('Usuários'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lista de lançamentos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: filtro == 'todos'
                  ? UsuarioService().findAllUsers(widget.user.uid)
                  : filtro == 'admins'
                  ? UsuarioService().findAllUsersTypeAdmin(widget.user.uid)
                  : UsuarioService().findAllUsersTypeUser(widget.user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(
                      'Erro ao carregar os usuários: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                        'Olá ${widget.user.displayName}, nenhum usuário encontrado!'),
                  );
                } else {
                  usuarios = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Usuario.fromMap(data);
                  }).toList();

                  if (searchQuery.isNotEmpty) {
                    usuarios = usuarios.where((usuario) {
                      final nome =
                      usuario.nome.toLowerCase();
                      final email =
                      usuario.email.toLowerCase();
                      final telefone =
                      usuario.telefone.toLowerCase();
                      final typeUser =
                      usuario.typeUser!.toLowerCase();
                      return nome.contains(searchQuery) ||
                          email.contains(searchQuery) ||
                          telefone.contains(searchQuery) ||
                          typeUser.contains(searchQuery);
                    }).toList();
                  }

                  if (typeUserSelecionado != '') {
                    usuarios = usuarios.where((usuario) {
                      final typeUser =
                      usuario.typeUser!.toLowerCase();
                      return typeUser.contains(typeUserSelecionado);
                    }).toList();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: usuarios.length,
                    itemBuilder: (context, index) {
                      final usuario = usuarios[index];
                      return GestureDetector(
                        onTap: () {
                          typeUserSelecionado = usuario.typeUser!;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Center(child: Text('Nível de Acesso')),
                                content: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Form(
                                    key: _formKey,
                                    child: DropdownButtonFormField<String>(
                                      value: typeNivelSelecionado,
                                      items: ComunsService().getTypeUserOptions(),
                                      onChanged: (value) {
                                        setState(() {
                                          typeNivelSelecionado = value!;
                                        });
                                      },
                                      decoration: CustomInputDecoration.build(
                                        labelText: 'Selecione o Nível de acesso',
                                      ),
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Por favor, selecione o nível de acesso';
                                        }
                                        return null;
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
                                        onPressed: () async {
                                          if (_formKey.currentState!.validate()) {
                                            UsuarioService().updateTypeUser(usuario.uid, typeNivelSelecionado);
                                            customSnackBar(context, "Nível de acesso alterado com sucesso!",
                                                backgroundColor: Colors.green);
                                            Navigator.of(context).pop();  // Fechar o diálogo
                                          }
                                        },
                                        child: const Text('Confirmar'),
                                      )
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: CustomCardItem(
                          title:
                          usuario.nome,
                          subtitle: 'Email: ${usuario.email}',
                          icon: Icons.person,
                          owner: 'Pepel: '
                              '${usuario.typeUser == null || usuario.typeUser == '' ?
                              'Nenhum'
                              : usuario.typeUser == 'ADMIN' ? 'Administrador'
                              : usuario.typeUser == 'SUPER_ADMIN' ? 'Super Administrador' : 'Usuário'}',
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
