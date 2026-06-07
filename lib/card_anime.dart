import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'anime.dart';

// Widget reaproveitado na lista e nos favoritos, recebendo o anime por
// parâmetro. Mantém a aparência do card consistente nas duas telas.
class CardAnime extends StatelessWidget {
  const CardAnime({super.key, required this.anime, required this.onTap});

  final Anime anime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        // Hero compartilha a imagem entre a lista e o detalhe (animação bônus).
        leading: Hero(
          tag: 'poster_${anime.malId}',
          child: CachedNetworkImage(
            imageUrl: anime.imagemUrl,
            width: 50,
            fit: BoxFit.cover,
            // placeholder/errorWidget garantem que a imagem nunca quebre a UI.
            placeholder: (context, url) => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image),
          ),
        ),
        title: Text(anime.titulo),
        subtitle: Text('${anime.tipo} • Nota: ${anime.nota}'),
        onTap: onTap,
      ),
    );
  }
}
