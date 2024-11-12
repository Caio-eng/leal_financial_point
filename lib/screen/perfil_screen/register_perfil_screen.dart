import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart'; // Para câmera e galeria
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:validadores/Validador.dart';
import 'dart:html' as html; // Import necessário para downloads na web

import '../../components/custom_input_decoration.dart';
import '../../components/custom_snack_bar.dart';
import '../../components/show_custom_alert_dialog.dart';
import '../../services/comuns_service.dart';
import '../../services/firebase_auth.dart';
import '../home_screen.dart';

class RegisterPerfilScreen extends StatefulWidget {
  final User user;
  RegisterPerfilScreen({super.key, required this.user});

  @override
  State<RegisterPerfilScreen> createState() => _RegisterPerfilScreenState();
}

class _RegisterPerfilScreenState extends State<RegisterPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isUpdating = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _dataNascimentoController = TextEditingController(); // Controller para data de nascimento

  final cpfFormatter = MaskTextInputFormatter(mask: '###.###.###-##');
  final telefoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####');

  User? user;
  String? photoUrl;
  Uint8List? _imageBytes;
  String? typeAccount;
  String? typeUser;
  String? statusElevacao;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _nomeController.text = user!.displayName ?? '';
      _emailController.text = user!.email ?? '';
      photoUrl = user!.photoURL;

      DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userProfileSnapshot.exists) {
        Map<String, dynamic> userProfileData = userProfileSnapshot.data() as Map<String, dynamic>;
        _nomeController.text = userProfileData['nome'] ?? '';
        _cpfController.text = userProfileData['cpf'] ?? '';
        _telefoneController.text = userProfileData['telefone'] ?? '';
        _dataNascimentoController.text = userProfileData['dataNascimento'] ?? '';
        typeAccount = userProfileData['typeAccount'];
        typeUser = userProfileData['typeUser'];
        statusElevacao = userProfileData['statusElevacao'];

        setState(() {
          isUpdating = true;
        });
      }
      setState(() {});
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
        await _uploadImageWeb(bytes); // Fazer upload da imagem
      } else {
        customSnackBar(context, 'Nenhuma imagem selecionada.', backgroundColor: Colors.yellow);
      }
    } catch (e) {
      customSnackBar(context, 'Erro ao selecionar imagem: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> _uploadImageWeb(Uint8List imageBytes) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final profileImagesRef = storageRef.child('profileImages/${widget.user.uid}.jpg');
      await profileImagesRef.putData(imageBytes);

      String downloadUrl = await profileImagesRef.getDownloadURL();

      setState(() {
        photoUrl = downloadUrl;
      });

      customSnackBar(context, 'Imagem atualizada com sucesso!', backgroundColor: Colors.green);
    } catch (e) {
      customSnackBar(context, 'Erro ao fazer upload da imagem: $e', backgroundColor: Colors.red);
    }
  }

  void _downloadImage() async {
    try {
      if (photoUrl != null && photoUrl!.isNotEmpty) {
        final Reference ref = FirebaseStorage.instance.refFromURL(photoUrl!);

        if (kIsWeb) {
          final String url = await ref.getDownloadURL();
          final html.AnchorElement anchor = html.AnchorElement(href: url)
            ..setAttribute("download", "perfil.jpg")
            ..click();
          customSnackBar(context, 'Imagem baixada com sucesso para o navegador!', backgroundColor: Colors.green);
        } else {
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          final String filePath = '${appDocDir.path}/perfil.jpg';

          await ref.writeToFile(File(filePath));

          if (Platform.isAndroid || Platform.isIOS) {
            await GallerySaver.saveImage(filePath);
          }

          customSnackBar(context, 'Imagem baixada com sucesso!', backgroundColor: Colors.green);
        }
      } else {
        customSnackBar(context, 'Nenhuma imagem disponível para baixar.', backgroundColor: Colors.yellow);
      }
    } catch (e) {
      customSnackBar(context, 'Erro ao baixar imagem: $e', backgroundColor: Colors.red);
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Selecionar da galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            if (photoUrl != null && photoUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Baixar imagem'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadImage();
                },
              ),
          ],
        );
      },
    );
  }

  // Função para mostrar o DatePicker e formatar a data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2008),
      firstDate: DateTime(1924),
      lastDate: DateTime(2008),
    );

    if (pickedDate != null) {
      String formattedDate = "${pickedDate.day.toString().padLeft(
          2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate
          .year}"; // Formato dd/MM/yyyy
      setState(() {
        _dataNascimentoController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isUpdating ? 'Atualizar Perfil' : 'Concluir Perfil'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView( // Adiciona scroll
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  _showImageSourceActionSheet(context);
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imageBytes != null
                      ? MemoryImage(_imageBytes!)
                      : (photoUrl != null && photoUrl!.isNotEmpty
                      ? NetworkImage(photoUrl!)
                      : const AssetImage('imagens/logo.png')) as ImageProvider<Object>?,
                  child: _imageBytes == null && photoUrl == null
                      ? const Icon(Icons.camera_alt, color: Colors.black, size: 28)
                      : null,
                ),
              ),
             const SizedBox(height: 16),
              Center(
                child: Text(
                  'Perfil: ${typeUser == 'ADMIN' ? 'Administrador' : typeUser == 'USER' ? 'Usuário' : typeUser == 'SUPER_ADMIN' ? 'Super Administrador' : 'Nenhum'}',
                  style: const TextStyle(fontSize: 16),),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: CustomInputDecoration.build(
                  labelText: 'Nome',
                  suffixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cpfController,
                keyboardType: TextInputType.number,
                inputFormatters: [cpfFormatter],
                decoration: CustomInputDecoration.build(
                  labelText: 'CPF',
                  suffixIcon: const Icon(Icons.co_present),
                ),
                validator: (value) {
                  return Validador()
                      .add(Validar.CPF, msg: 'CPF Inválido')
                      .add(Validar.OBRIGATORIO, msg: 'Campo obrigatório')
                      .minLength(11)
                      .maxLength(11)
                      .valido(value, clearNoNumber: true);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [telefoneFormatter],
                decoration: CustomInputDecoration.build(
                  labelText: 'Telefone',
                  suffixIcon: const Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Telefone é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  _selectDate(context); // Exibir o DatePicker
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dataNascimentoController,
                    decoration: CustomInputDecoration.build(
                      labelText: 'Data de Nascimento',
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Data de nascimento é obrigatória';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              typeUser == 'ADMIN' || typeUser == 'SUPER_ADMIN' ? const SizedBox(height: 16) : const SizedBox(),
              typeUser == 'ADMIN' || typeUser == 'SUPER_ADMIN' ? DropdownButtonFormField<String>(
                value: typeAccount,
                items: ComunsService().getTypeAccountOptions(),
                onChanged: (value) {
                  setState(() {
                    typeAccount = value!;
                  });
                },
                decoration: CustomInputDecoration.build(
                  labelText: 'Selecione o Tipo de Conta',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tipo de conta é obrigatório';
                  }
                  return null;
                },
              ) : Container(),
              isUpdating == true && statusElevacao != 'Solicitado' ?
                typeUser == 'USER' || typeUser == '' ? const SizedBox(height: 16) : const SizedBox() : const SizedBox(),
              isUpdating == true && statusElevacao != 'Solicitado' ?
                typeUser == 'USER' || typeUser == '' ? TextButton(
                  onPressed: () {
                    showCustomAlertDialog(
                        context,
                        'Solicitar Admin',
                        'Tem certeza que deseja confirmar solicitação de perfil?',
                        'Confirmar',
                        'Cancelar', () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.user.uid)
                              .update({
                            'statusElevacao': 'Solicitado',
                          });
                          customSnackBar(context, 'Solicitação de perfil enviada com sucesso!');
                          setState(() {});
                          Navigator.pop(context);
                    });
                  },
                  child: const Text('Solicitar Perfil de Administrador'),
                ) : Container() : Container(),
              isUpdating == true && statusElevacao == 'Solicitado' ? const SizedBox(height: 16) : const SizedBox(),
              isUpdating == true && statusElevacao == 'Solicitado' ? Center(
                child: Text('$statusElevacao Perfil de Administrador\nAguardando aprovação...', style: const TextStyle(fontSize: 16, color: Colors.teal),),
              ) : const SizedBox(),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveProfile();
                      }
                    },
                    child: Text(isUpdating ? 'Atualizar Perfil' : 'Concluir Perfil'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, dynamic> userProfileData = {
          'uid': widget.user.uid,
          'nome': _nomeController.text.trim(),
          'email': _emailController.text.trim(),
          'cpf': _cpfController.text.trim(),
          'telefone': _telefoneController.text.trim(),
          'dataNascimento': _dataNascimentoController.text.trim(),
          'typeUser' : '',
          'isAtivo': true,
          'typeAccount': typeAccount,
        };

        await AuthService().atualizarImagem(urlImagem: photoUrl);

        await AuthService().atualizarNome(nome: _nomeController.text);

        if (isUpdating == false) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.user.uid)
              .set(userProfileData);
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.user.uid)
              .update({
                'nome': _nomeController.text.trim(),
                'email': _emailController.text.trim(),
                'cpf': _cpfController.text.trim(),
                'telefone': _telefoneController.text.trim(),
                'dataNascimento': _dataNascimentoController.text.trim(),
                'typeUser' : typeUser != null || typeUser != '' ? typeUser : '',
                'typeAccount' : typeAccount ?? '',
              });
        }

        customSnackBar(
          context,
          isUpdating
              ? 'Perfil atualizado com sucesso!'
              : 'Perfil concluido com sucesso!',
          backgroundColor: Colors.green,
        );

        setState(() {
          isUpdating = true;
        });

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(user: widget.user)));
      } catch (e) {
        customSnackBar(context, 'Erro ao preencher/atualizar perfil: $e', backgroundColor: Colors.red);
      }
    }
  }
}