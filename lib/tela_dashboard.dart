import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'anime.dart';
import 'jikan_service.dart';
import 'tela_detalhe_anime.dart';
import 'tela_lista_animes.dart';

// Tela inicial (aba "Animes"): apresenta o projeto, mostra um carousel da
// temporada atual e deixa o usuário escolher um ano/temporada para explorar.
class TelaDashboard extends StatefulWidget {
  const TelaDashboard({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TelaDashboardState();
  }
}

class _TelaDashboardState extends State<TelaDashboard> {
  // Future do carousel guardado no initState para não refazer a chamada a cada
  // rebuild, mesmo padrão usado na tela de lista.
  late Future<List<Anime>> _futureDestaques;

  // Temporadas da API Jikan com seu rótulo em português para exibição.
  static const List<({String valor, String rotulo})> _temporadas = [
    (valor: 'winter', rotulo: 'Inverno'),
    (valor: 'spring', rotulo: 'Primavera'),
    (valor: 'summer', rotulo: 'Verão'),
    (valor: 'fall', rotulo: 'Outono'),
  ];

  // Lista fixa de anos (mais recente primeiro) para o usuário navegar.
  static const List<int> _anos = [
    2026,
    2025,
    2024,
    2023,
    2022,
    2021,
    2020,
    2019,
    2018,
    2017,
    2016,
    2015,
  ];

  @override
  void initState() {
    super.initState();
    _futureDestaques = buscarTemporadaAtual();
  }

  // Abre a listagem de uma temporada específica como nova rota.
  void _abrirTemporada(int ano, String temporada, String rotulo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaListaAnimes(
          ano: ano,
          temporada: temporada,
          titulo: '$rotulo $ano',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Explicação do projeto.
        Text(
          'Sobre o app',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Este app lista animes por temporada usando a API pública Jikan '
          '(MyAnimeList). Veja os destaques da temporada atual abaixo, escolha '
          'um ano e uma estação para explorar a listagem, e salve seus '
          'favoritos na aba Favoritos.',
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        // Carousel da temporada atual.
        Text(
          'Destaques da temporada',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: FutureBuilder<List<Anime>>(
            future: _futureDestaques,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar destaques.'));
              }

              // Pegamos só os primeiros animes para o carousel não ficar gigante.
              final destaques = (snapshot.data ?? []).take(10).toList();
              return PageView.builder(
                controller: PageController(viewportFraction: 0.7),
                itemCount: destaques.length,
                itemBuilder: (context, indice) {
                  final anime = destaques[indice];
                  return _CardDestaque(
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
            },
          ),
        ),
        const SizedBox(height: 24),

        // Lista de anos; cada ano abre as quatro temporadas.
        Text(
          'Explorar por temporada',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        for (final ano in _anos)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$ano',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final temporada in _temporadas)
                      ActionChip(
                        label: Text(temporada.rotulo),
                        onPressed: () => _abrirTemporada(
                          ano,
                          temporada.valor,
                          temporada.rotulo,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Card de um anime dentro do carousel: poster grande + título.
class _CardDestaque extends StatelessWidget {
  const _CardDestaque({required this.anime, required this.onTap});

  final Anime anime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: anime.imagemUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  anime.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
