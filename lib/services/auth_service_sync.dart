import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/meal.dart';
import '../models/symptom_report.dart';
import '../models/weight_entry.dart';
import 'auth_service.dart';

/// ============================================
/// RESULTADO DE UMA OPERAÇÃO NA NUVEM
/// ============================================
/// `isNetworkError = true` significa "não conseguimos falar com o servidor"
/// (offline, timeout, sessão ausente). O SyncService para a fila e tenta de novo depois.
/// `false` significa que o servidor respondeu com erro (RLS, validação, etc.).
class CloudResult<T> {
  final T? data;
  final String? error;
  final bool isNetworkError;

  const CloudResult._({this.data, this.error, this.isNetworkError = false});

  factory CloudResult.success([T? data]) => CloudResult._(data: data);

  factory CloudResult.failure(Object e) => CloudResult._(
        error: e.toString(),
        isNetworkError: !(e is PostgrestException || e is AuthException || e is StorageException),
      );

  factory CloudResult.notLoggedIn() =>
      const CloudResult._(error: 'Usuário não logado', isNetworkError: true);

  bool get ok => error == null;
}

const Duration _cloudTimeout = Duration(seconds: 15);

Future<CloudResult<T>> _guard<T>(Future<T> Function() action) async {
  try {
    return CloudResult<T>.success(await action().timeout(_cloudTimeout));
  } catch (e) {
    debugPrint('[Sync] $e');
    return CloudResult<T>.failure(e);
  }
}

String _utc(DateTime d) => d.toUtc().toIso8601String();

/// ============================================
/// OPERAÇÕES DE SINCRONIZAÇÃO (usadas pelo SyncService)
/// ============================================
extension AuthServiceSync on AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  // ---------- REFEIÇÕES ----------
  Future<CloudResult<bool>> pushMeal(Meal meal) {
    final user = currentUser;
    if (user == null) return Future.value(CloudResult<bool>.notLoggedIn());

    return _guard<bool>(() async {
      await _client.from('meal_entries').upsert({
        'id': meal.id,
        'patient_id': user.id,
        'type': meal.type.name,
        'date_time': _utc(meal.dateTime),
        'notes': meal.notes,
        'photo_path': meal.photoPath,
        'foods': meal.foods
            .map((f) => {
                  'name': f.name,
                  'quantity': f.quantity,
                  'unit': f.unit,
                  'calories': f.calories,
                })
            .toList(),
      });
      return true;
    });
  }

  Future<CloudResult<bool>> removeMeal(String id) {
    final user = currentUser;
    if (user == null) return Future.value(CloudResult<bool>.notLoggedIn());

    return _guard<bool>(() async {
      await _client.from('meal_entries').delete().eq('id', id).eq('patient_id', user.id);
      return true;
    });
  }

  Future<CloudResult<List<Meal>>> pullMealsSince(DateTime since) {
    final user = currentUser;
    if (user == null) return Future.value(CloudResult<List<Meal>>.notLoggedIn());

    return _guard<List<Meal>>(() async {
      final rows = await _client
          .from('meal_entries')
          .select()
          .eq('patient_id', user.id)
          .gte('date_time', _utc(since))
          .order('date_time', ascending: true);

      return rows.map<Meal>((row) {
        final foods = ((row['foods'] as List<dynamic>?) ?? []).map((f) {
          return FoodItem(
            name: f['name'] as String,
            quantity: (f['quantity'] as num).toDouble(),
            unit: f['unit'] as String? ?? 'g',
            calories: (f['calories'] as num?)?.toDouble(),
          );
        }).toList();

        return Meal(
          id: row['id'] as String,
          type: MealType.values.firstWhere(
            (t) => t.name == row['type'],
            orElse: () => MealType.lunch,
          ),
          dateTime: DateTime.parse(row['date_time'] as String).toLocal(),
          foods: foods,
          notes: row['notes'] as String?,
          photoPath: row['photo_path'] as String?,
        );
      }).toList();
    });
  }

  // ---------- PESOS ----------
  /// Grava o peso e só depois remove outros registros do mesmo dia
  /// (se a limpeza falhar, sobra duplicata, mas nunca se perde o peso).
  Future<CloudResult<bool>> pushWeight(WeightEntry entry) {
    final user = currentUser;
    if (user == null) return Future.value(CloudResult<bool>.notLoggedIn());

    return _guard<bool>(() async {
      await _client.from('weight_entries').upsert({
        'id': entry.id,
        'patient_id': user.id,
        'date': _utc(entry.date),
        'weight_kg': entry.weightKg,
        'notes': entry.notes,
      });

      final start = DateTime(entry.date.year, entry.date.month, entry.date.day);
      final end = DateTime(entry.date.year, entry.date.month, entry.date.day + 1);
      await _client
          .from('weight_entries')
          .delete()
          .eq('patient_id', user.id)
          .gte('date', _utc(start))
          .lt('date', _utc(end))
          .neq('id', entry.id);
      return true;
    });
  }

  Future<CloudResult<bool>> removeWeight(String id) {
    final user = currentUser;
    if (user == null) return Future.value(CloudResult<bool>.notLoggedIn());

    return _guard<bool>(() async {
      await _client.from('weight_entries').delete().eq('id', id).eq('patient_id', user.id);
      return true;
    });
  }

  Future<CloudResult<List<WeightEntry>>> pullWeights() {
    final user = currentUser;
    if (user == null) return Future.value(CloudResult<List<WeightEntry>>.notLoggedIn());

    return _guard<List<WeightEntry>>(() async {
      final rows = await _client
          .from('weight_entries')
          .select()
          .eq('patient_id', user.id)
          .order('date', ascending: true);

      return rows.map<WeightEntry>((row) {
        return WeightEntry(
          id: row['id'] as String,
          date: DateTime.parse(row['date'] as String).toLocal(),
          weightKg: (row['weight_kg'] as num).toDouble(),
          notes: row['notes'] as String?,
        );
      }).toList();
    });
  }

  // ---------- SINTOMAS ----------
  Future<CloudResult<bool>> pushSymptom(SymptomReport report) {
    final user = currentUser;
    if (user == null) return Future.value(CloudResult<bool>.notLoggedIn());

    return _guard<bool>(() async {
      await _client.from('symptom_reports').upsert({
        'id': report.id,
        'patient_id': user.id,
        'date': _utc(report.date),
        'symptoms': report.symptoms,
        'difficulties': report.difficulties,
        'notes': report.notes,
      });
      return true;
    });
  }

  Future<CloudResult<List<SymptomReport>>> pullSymptoms() {
    final user = currentUser;
    if (user == null) return Future.value(CloudResult<List<SymptomReport>>.notLoggedIn());

    return _guard<List<SymptomReport>>(() async {
      final rows = await _client
          .from('symptom_reports')
          .select()
          .eq('patient_id', user.id)
          .order('date', ascending: false);

      return rows.map<SymptomReport>((row) {
        return SymptomReport(
          id: row['id'] as String,
          date: DateTime.parse(row['date'] as String).toLocal(),
          symptoms: (row['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
          difficulties: (row['difficulties'] as List<dynamic>?)?.cast<String>() ?? [],
          notes: row['notes'] as String?,
        );
      }).toList();
    });
  }
}