// Modelo que representa um anime vindo da API Jikan.
class Anime {
  final int malId;
  final String titulo;
  final String? tituloIngles;
  final String imagemUrl;
  final String tipo;
  final int episodios;
  final double nota;
  final String sinopse;
  final List<String> generos;

  const Anime({
    required this.malId,
    required this.titulo,
    required this.tituloIngles,
    required this.imagemUrl,
    required this.tipo,
    required this.episodios,
    required this.nota,
    required this.sinopse,
    required this.generos,
  });

  // O fromJson é o ponto onde protegemos o app contra campos ausentes da API.
  // Vários campos da Jikan podem vir null, então aplicamos valores padrão para
  // a UI nunca quebrar ao montar a tela.
  factory Anime.fromJson(Map<String, dynamic> json) {
    // images.jpg.image_url é aninhado; tratamos cada nível para evitar null.
    final imagens = json['images'] as Map<String, dynamic>?;
    final jpg = imagens?['jpg'] as Map<String, dynamic>?;

    // genres é uma lista de mapas; extraímos só o campo name de cada um.
    final listaGeneros = (json['genres'] as List<dynamic>?) ?? [];
    final generos = listaGeneros
        .map((g) => (g as Map<String, dynamic>)['name'] as String? ?? '')
        .where((nome) => nome.isNotEmpty)
        .toList();

    return Anime(
      malId: json['mal_id'] as int? ?? 0,
      titulo: json['title'] as String? ?? 'N/A',
      tituloIngles: json['title_english'] as String?,
      imagemUrl: jpg?['image_url'] as String? ?? '',
      tipo: json['type'] as String? ?? 'N/A',
      episodios: json['episodes'] as int? ?? 0,
      // score vem como num (pode ser int ou double); normalizamos para double.
      nota: (json['score'] as num?)?.toDouble() ?? 0.0,
      sinopse: json['synopsis'] as String? ?? 'Sem sinopse disponível.',
      generos: generos,
    );
  }
}
