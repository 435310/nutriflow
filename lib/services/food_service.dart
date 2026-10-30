import 'dart:convert'; // IMPORT ADICIONADO para lidar com JSON
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'local_storage_service.dart';

/// ============================================
/// SERVIÇO DE ALIMENTOS (TACO) — FUNCIONA OFFLINE
/// ============================================
class FoodService {
  static final FoodService _instance = FoodService._internal();
  factory FoodService() => _instance;
  FoodService._internal();

  static const Duration _maxAge = Duration(days: 7);
  static const Duration _downloadTimeout = Duration(seconds: 30);
  static const int _pageSize = 1000;

  // Ajuste nos acentos (o seu estava com caracteres corrompidos)
  static const String _accentsFrom = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  static const String _accentsTo = 'aaaaaeeeeiiiiooooouuuucn';

  final _local = LocalStorageService();

  List<Map<String, dynamic>>? _cache;
  Future<bool>? _refreshing;

  // ============================================
  // BUSCA
  // ============================================
  Future<List<Map<String, dynamic>>> search(String query, {int limit = 10}) async {
    final q = _normalize(query.trim());
    if (q.length < 2) return [];

    var catalog = await _catalog();
    if (catalog.isEmpty) {
      await refreshCatalog();
      catalog = await _catalog();
    }
    if (catalog.isEmpty) return _searchCloud(query.trim(), limit);

    final startsWith = <Map<String, dynamic>>[];
    final contains = <Map<String, dynamic>>[];
    for (final food in catalog) {
      final name = _normalize((food['name'] as String?) ?? '');
      if (name.startsWith(q)) {
        startsWith.add(food);
      } else if (name.contains(q)) {
        contains.add(food);
      }
    }
    return [...startsWith, ...contains].take(limit).toList();
  }

  // ============================================
  // CATÁLOGO
  // ============================================
  Future<void> refreshCatalogIfNeeded() async {
    final catalog = await _catalog();
    final updatedAt = await _local.foodCatalogUpdatedAt();
    final stale = updatedAt == null || DateTime.now().difference(updatedAt) > _maxAge;
    if (catalog.isEmpty || stale) await refreshCatalog();
  }

  Future<bool> refreshCatalog() {
    return _refreshing ??= _download().whenComplete(() => _refreshing = null);
  }

  // CORRIGIDO: Converte a String JSON para List
  Future<List<Map<String, dynamic>>> _catalog() async {
    if (_cache != null) return _cache!;
    
    final jsonString = await _local.loadFoodCatalog();
    if (jsonString == null) return [];
    
    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      _cache = list.cast<Map<String, dynamic>>();
      return _cache!;
    } catch (e) {
      debugPrint('[Foods] Erro ao decodificar catálogo: $e');
      return [];
    }
  }

  Future<bool> _download() async {
    try {
      final foods = await _fetchAll().timeout(_downloadTimeout);
      if (foods.isEmpty) return false;
      
      // CORRIGIDO: Converte a List para String JSON antes de salvar
      final jsonString = jsonEncode(foods);
      await _local.saveFoodCatalog(jsonString);
      
      _cache = foods;
      return true;
    } catch (e) {
      debugPrint('[Foods] Não foi possível baixar o catálogo: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAll() async {
    final client = Supabase.instance.client;
    final all = <Map<String, dynamic>>[];
    var from = 0;

    while (true) {
      final rows = await client
          .from('foods')
          .select('name,calories_per_100g')
          .order('name', ascending: true)
          .range(from, from + _pageSize - 1);
      all.addAll(rows);
      if (rows.length < _pageSize) break;
      from += _pageSize;
    }
    return all;
  }

  // Reserva: se não há catálogo local, tenta a busca direta na nuvem
  Future<List<Map<String, dynamic>>> _searchCloud(String query, int limit) async {
    try {
      final rows = await Supabase.instance.client
          .from('foods')
          .select('name,calories_per_100g')
          .ilike('name', '%$query%')
          .limit(limit);
      return rows;
    } catch (e) {
      debugPrint('[Foods] Busca na nuvem falhou: $e');
      return [];
    }
  }

  String _normalize(String text) {
    final buffer = StringBuffer();
    for (final rune in text.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      final i = _accentsFrom.indexOf(char);
      buffer.write(i >= 0 ? _accentsTo[i] : char);
    }
    return buffer.toString();
  }
}