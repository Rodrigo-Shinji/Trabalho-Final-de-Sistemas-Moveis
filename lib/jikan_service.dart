import 'dart:convert';

import 'package:http/http.dart' as http;

import 'anime.dart';

// Isolamos o acesso à rede aqui para que as telas só cuidem da UI, sem saber
// como os dados chegam (separação de responsabilidades).

// Busca os animes de uma temporada específica (ano + estação).
Future<List<Anime>> buscarAnimes(int ano, String temporada) async {
  final url = Uri.parse('https://api.jikan.moe/v4/seasons/$ano/$temporada?sfw');
  return _buscar(url);
}

// Busca os animes da temporada atual, usado no carousel da dashboard.
Future<List<Anime>> buscarTemporadaAtual() async {
  final url = Uri.parse('https://api.jikan.moe/v4/seasons/now?sfw');
  return _buscar(url);
}

// Lógica comum de request + parse, compartilhada pelas funções acima.
Future<List<Anime>> _buscar(Uri url) async {
  final resposta = await http.get(url);

  // Qualquer status diferente de 200 vira exceção para a tela mostrar o erro.
  if (resposta.statusCode != 200) {
    throw Exception('Falha ao buscar animes (status ${resposta.statusCode})');
  }

  final json = jsonDecode(resposta.body) as Map<String, dynamic>;
  final lista = json['data'] as List<dynamic>;

  return lista
      .map((item) => Anime.fromJson(item as Map<String, dynamic>))
      .toList();
}
