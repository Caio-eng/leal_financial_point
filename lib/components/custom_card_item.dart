import 'package:flutter/material.dart';

class CustomCardItem extends StatelessWidget {
  const CustomCardItem({
    super.key,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.owner,
    this.onOptionSelected,
  });

  final String? imageUrl;
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
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl != null
                  ? Image.network(
                imageUrl!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 100,
                width: 100,
                color: Colors.grey,
                child: const Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
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
                      // Verifica se onOptionSelected é nulo antes de exibir o PopupMenuButton
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
}