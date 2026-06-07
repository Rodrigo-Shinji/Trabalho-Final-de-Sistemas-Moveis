import 'package:flutter/material.dart';

import 'anime.dart';
import 'card_anime.dart';
import 'favoritos_db.dart';
import 'tela_detalhe_anime.dart';

class TelaFavoritos extends StatefulWidget {
  const TelaFavoritos({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TelaFavoritosState();
  }
}

class _TelaFavoritosState extends State<TelaFavoritos> {
  List<Anime> _favoritos = [];

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  // Esta tela lê do banco local (sqlite3), sem chamar a API.
  Future<void> _carregarFavoritos() async {
    final lista = await FavoritosDb.instancia.listarTodos();
    setState(() {
      _favoritos = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_favoritos.isEmpty) {
      return const Center(child: Text('Nenhum favorito ainda'));
    }

    return ListView.builder(
      itemCount: _favoritos.length,
      itemBuilder: (context, indice) {
        final anime = _favoritos[indice];
        return CardAnime(
          anime: anime,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaDetalheAnime(anime: anime),
            ),
          ),
        );
      },
    );
  }
}
