class Usuario {
  String uid;
  String nome;
  String email;
  String telefone;
  String cpf;
  String? typeUser;

  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cpf,
    this.typeUser,
  });

  // Método para converter os dados do objeto para um Map, para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
      'typeUser': typeUser
    };
  }

  // Método para criar um objeto Usuario a partir de um Map (ex: ao recuperar do Firestore)
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      uid: map['uid'],
      nome: map['nome'],
      email: map['email'],
      telefone: map['telefone'],
      cpf: map['cpf'],
      typeUser: map['typeUser'],
    );
  }
}