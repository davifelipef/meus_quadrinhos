import 'package:flutter/material.dart';

class CollectionCard extends StatelessWidget {
  const CollectionCard({super.key, required this.currentItem});

  final Map<String, dynamic> currentItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  currentItem["comic"] ?? "Erro ao retornar o quadrinho",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentItem["description"] ?? "",
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
