import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/anamnesis.dart';
import '../models/meal.dart';
import '../models/patient_profile.dart';
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

T? _byName<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

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

  // ---------- PERFIL DO PACIENTE ----------
  Future<CloudResult<bool>> pushProfile(PatientProfile p) {
    final user = currentUser;
    if (user == null) return Future.value(CloudResult<bool>.notLoggedIn());

    return _guard<bool>(() async {
      await _client.from('patient_profiles').update({
        'name': p.name.trim(),
        'email': p.email.trim(),
        'phone': p.phone,
        'birth_date': p.birthDate?.toIso8601String(),
        'gender': p.gender?.name,
        'height_cm': p.heightCm,
        'initial_weight_kg': p.initialWeightKg,
        'current_weight_kg': p.currentWeightKg,
        'goal_weight_kg': p.goalWeightKg,
        'waist_cm': p.waistCm,
        'goal': p.goal?.name,
        'activity_level': p.activityLevel?.name,
        'food_restrictions': p.foodRestrictions,
        'allergies': p.allergies,
      }).eq('user_id', user.id);
      return true;
    });
  }

  Future<CloudResult<PatientProfile?>> pullProfile() {
    final user = currentUser;
    if (user == null) return Future.value(CloudResult<PatientProfile?>.notLoggedIn());

    return _guard<PatientProfile?>(() async {
      final row = await _client.from('patient_profiles').select().eq('user_id', user.id).maybeSingle();
      if (row == null) return null;

      return PatientProfile(
        id: (row['id'] ?? user.id).toString(),
        name: (row['name'] as String?) ?? '',
        email: (row['email'] as String?) ?? '',
        phone: row['phone'] as String?,
        birthDate: row['birth_date'] != null ? DateTime.parse(row['birth_date'] as String) : null,
        gender: _byName(Gender.values, row['gender'] as String?, Gender.other),
        heightCm: (row['height_cm'] as num?)?.toDouble(),
        initialWeightKg: (row['initial_weight_kg'] as num?)?.toDouble(),
        currentWeightKg: (row['current_weight_kg'] as num?)?.toDouble(),
        goalWeightKg: (row['goal_weight_kg'] as num?)?.toDouble(),
        waistCm: (row['waist_cm'] as num?)?.toDouble(),
        goal: _byName(Goal.values, row['goal'] as String?, Goal.maintain),
        activityLevel: _byName(ActivityLevel.values, row['activity_level'] as String?, ActivityLevel.sedentary),
        foodRestrictions: (row['food_restrictions'] as List<dynamic>?)?.cast<String>() ?? <String>[],
        allergies: (row['allergies'] as List<dynamic>?)?.cast<String>() ?? <String>[],
        notes: row['notes'] as String?,
        createdAt: row['created_at'] != null ? DateTime.parse(row['created_at'] as String).toLocal() : DateTime.now(),
        updatedAt: row['updated_at'] != null ? DateTime.parse(row['updated_at'] as String).toLocal() : null,
      );
    });
  }

  // ---------- ANAMNESE ----------
  Future<CloudResult<bool>> pushAnamnesis(Anamnesis a) {
    final user = currentUser;
    if (user == null) return Future.value(CloudResult<bool>.notLoggedIn());

    return _guard<bool>(() async {
      final data = {
        'main_goal': a.mainGoal,
        'health_conditions': a.healthConditions,
        'medications': a.medications,
        'supplements': a.supplements,
        'bowel_habits': a.bowelHabits,
        'sleep_quality': a.sleepQuality,
        'water_intake': a.waterIntake,
        'alcohol_consumption': a.alcoholConsumption,
        'smoking': a.smoking,
        'physical_activity': a.physicalActivity,
        'food_allergies': a.foodAllergies,
        'food_intolerances': a.foodIntolerances,
        'dietary_preferences': a.dietaryPreferences,
      };

      final existing = await _client.from('anamnesis').select('id').eq('patient_id', user.id).maybeSingle();
      if (existing != null) {
        await _client.from('anamnesis').update({...data, 'updated_at': _utc(DateTime.now())}).eq('patient_id', user.id);
      } else {
        await _client.from('anamnesis').insert({'patient_id': user.id, ...data});
      }
      return true;
    });
  }

  Future<CloudResult<Anamnesis?>> pullAnamnesis() {
    final user = currentUser;
    if (user == null) return Future.value(CloudResult<Anamnesis?>.notLoggedIn());

    return _guard<Anamnesis?>(() async {
      final row = await _client.from('anamnesis').select().eq('patient_id', user.id).maybeSingle();
      if (row == null) return null;

      return Anamnesis(
        id: row['id'] as String,
        patientId: row['patient_id'] as String,
        mainGoal: row['main_goal'] as String?,
        healthConditions: row['health_conditions'] as String?,
        medications: row['medications'] as String?,
        supplements: row['supplements'] as String?,
        bowelHabits: row['bowel_habits'] as String?,
        sleepQuality: row['sleep_quality'] as String?,
        waterIntake: row['water_intake'] as String?,
        alcoholConsumption: row['alcohol_consumption'] as String?,
        smoking: row['smoking'] as String?,
        physicalActivity: row['physical_activity'] as String?,
        foodAllergies: row['food_allergies'] as String?,
        foodIntolerances: row['food_intolerances'] as String?,
        dietaryPreferences: row['dietary_preferences'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
        updatedAt: row['updated_at'] != null ? DateTime.parse(row['updated_at'] as String).toLocal() : null,
      );
    });
  }
}