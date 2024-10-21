import 'package:flutter/material.dart';

class CustomCardItem extends StatelessWidget {
  const CustomCardItem({
    super.key,
    this.imageUrl,
    this.icon,
    required this.title,
    required this.subtitle,
    required this.owner,
    this.onOptionSelected,
  });

  final String? imageUrl;
  final IconData? icon; // Agora você pode passar um ícone como alternativa
  final String title;
  final String subtitle;
  final String owner;
  final Function(String)? onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageOrIcon(), // Função para construir a imagem ou ícone
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      // Verifica se onOptionSelected não é nulo antes de exibir o PopupMenuButton
                      if (onOptionSelected != null)
                        PopupMenuButton<String>(
                          onSelected: onOptionSelected,
                          itemBuilder: (BuildContext context) {
                            return {'Editar', 'Excluir'}.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                          icon: const Icon(Icons.more_vert), // Adicionando ícone de menu estilizado
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    owner,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para construir a imagem ou o ícone dependendo dos parâmetros fornecidos
  Widget _buildImageOrIcon() {
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl!,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
        ),
      );
    } else if (icon != null) {
      return Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.teal[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 60,
          color: Colors.teal,
        ),
      );
    } else {
      return _buildPlaceholderIcon();
    }
  }

  // Função de ícone padrão caso a imagem falhe ou nenhum ícone seja fornecido
  Widget _buildPlaceholderIcon() {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.image_not_supported,
        size: 50,
        color: Colors.white,
      ),
    );
  }
}