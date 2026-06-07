import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'anime.dart';

// Helper do banco local usando sqlite3 puro.
// Diferença para o sqflite: o pacote sqlite3 fala direto com a biblioteca
// nativa do SQLite (via FFI) e é SÍNCRONO. A "conexão" é um objeto Database
// que abrimos uma única vez e reaproveitamos (singleton), em vez de abrir a
// cada operação. Persistimos campos suficientes para mostrar a lista de
// favoritos e reabrir o detalhe sem nova chamada à API.
class FavoritosDb {
  FavoritosDb._();
  static final FavoritosDb instancia = FavoritosDb._();

  Database? _db;

  // Abre a conexão (uma vez) e garante a tabela criada.
  // O getter continua async para manter a mesma assinatura; a conexão sqlite3
  // em si é síncrona.
  Future<Database> get _banco async {
    if (_db != null) return _db!;
    // Apenas desenvolvimento: salva o banco na raiz do projeto (Directory.current
    // = diretório onde o `flutter run` é executado). NÃO usar em release: app
    // empacotado não tem pasta de projeto gravável. Trocar por
    // getApplicationDocumentsDirectory()/getApplicationSupportDirectory() na hora
    // de distribuir.
    final caminho = p.join(Directory.current.path, 'favoritos.db');
    final db = sqlite3.open(caminho);
    db.execute('''
      CREATE TABLE IF NOT EXISTS favoritos (
        mal_id INTEGER PRIMARY KEY,
        titulo TEXT,
        titulo_ingles TEXT,
        imagem_url TEXT,
        tipo TEXT,
        episodios INTEGER,
        nota REAL,
        sinopse TEXT,
        generos TEXT
      )
    ''');
    _db = db;
    return db;
  }

  Future<void> adicionar(Anime anime) async {
    final db = await _banco;
    // INSERT OR REPLACE = equivalente ao ConflictAlgorithm.replace do sqflite:
    // se o mal_id já existir, sobrescreve em vez de dar erro.
    db.execute(
      'INSERT OR REPLACE INTO favoritos '
      '(mal_id, titulo, titulo_ingles, imagem_url, tipo, episodios, nota, sinopse, generos) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        anime.malId,
        anime.titulo,
        anime.tituloIngles,
        anime.imagemUrl,
        anime.tipo,
        anime.episodios,
        anime.nota,
        anime.sinopse,
        // generos é List<String>; salvamos como texto separado por vírgula.
        anime.generos.join(','),
      ],
    );
  }

  Future<void> remover(int malId) async {
    final db = await _banco;
    db.execute('DELETE FROM favoritos WHERE mal_id = ?', [malId]);
  }

  Future<bool> existe(int malId) async {
    final db = await _banco;
    final resultado =
        db.select('SELECT 1 FROM favoritos WHERE mal_id = ? LIMIT 1', [malId]);
    return resultado.isNotEmpty;
  }

  Future<List<Anime>> listarTodos() async {
    final db = await _banco;
    final resultado = db.select('SELECT * FROM favoritos');

    // Reconstruímos o Anime a partir das linhas para reabrir o detalhe.
    return resultado.map((linha) {
      final generosTexto = linha['generos'] as String? ?? '';
      return Anime(
        malId: linha['mal_id'] as int,
        titulo: linha['titulo'] as String,
        tituloIngles: linha['titulo_ingles'] as String?,
        imagemUrl: linha['imagem_url'] as String,
        tipo: linha['tipo'] as String,
        episodios: linha['episodios'] as int,
        // sqlite3 devolve num para colunas REAL; normalizamos para double.
        nota: (linha['nota'] as num).toDouble(),
        sinopse: linha['sinopse'] as String,
        generos: generosTexto.isEmpty ? [] : generosTexto.split(','),
      );
    }).toList();
  }
}
