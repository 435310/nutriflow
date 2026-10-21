import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/meal.dart';
import '../models/weight_entry.dart';

/// ============================================
/// SERVIÇO DE AUTENTICAÇÃO E DADOS NA NUVEM
/// ============================================
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // ============================================
  // CADASTRO
  // ============================================
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required bool isNutritionist,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) return 'Erro ao criar usuário.';

      if (isNutritionist) {
        await _supabase.from('nutritionist_profiles').insert({
          'id': user.id,
          'user_id': user.id,
          'name': name.trim(),
          'email': email.trim(),
          'crn': 'A preencher',
          'specialty': 'A preencher',
        });
      } else {
        await _supabase.from('patient_profiles').insert({
          'id': user.id,
          'user_id': user.id,
          'name': name.trim(),
          'email': email.trim(),
        });
      }

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }

  // ============================================
  // LOGIN
  // ============================================
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }

  // ============================================
  // LOGOUT
  // ============================================
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ============================================
  // PERFIL DO PACIENTE (Logado)
  // ============================================
  Future<Map<String, dynamic>?> getPatientProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('patient_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Erro ao buscar perfil: $e');
      return null;
    }
  }

  // ============================================
  // VERIFICAR TIPO DE USUÁRIO
  // ============================================
  Future<bool> isNutritionist() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('nutritionist_profiles')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Erro ao verificar tipo de usuário: $e');
      return false;
    }
  }

  // ============================================
  // REFEIÇÕES
  // ============================================
  Future<String?> saveMealToCloud(Meal meal) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'Usuário não logado';

      final foodsJson = meal.foods.map((f) => {
        'name': f.name,
        'quantity': f.quantity,
        'unit': f.unit,
        'calories': f.calories,
      }).toList();

      await _supabase.from('meal_entries').insert({
        'patient_id': user.id,
        'type': meal.type.name,
        'date_time': meal.dateTime.toIso8601String(),
        'notes': meal.notes,
        'photo_path': meal.photoPath,
        'foods': foodsJson,
      });

      return null;
    } catch (e) {
      print('Erro ao salvar refeição no Supabase: $e');
      return 'Erro ao salvar refeição: $e';
    }
  }

  Future<List<Meal>> getMealsFromCloud({DateTime? date}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final targetDate = date ?? DateTime.now();
      
      final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day).toIso8601String();
      final endOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59).toIso8601String();

      final response = await _supabase
          .from('meal_entries')
          .select()
          .eq('patient_id', user.id)
          .gte('date_time', startOfDay)
          .lte('date_time', endOfDay)
          .order('date_time', ascending: true);

      final List<Meal> meals = [];
      
      for (final row in response) {
        final foodsList = (row['foods'] as List<dynamic>?) ?? [];
        final foods = foodsList.map((f) => FoodItem(
          name: f['name'] as String,
          quantity: (f['quantity'] as num).toDouble(),
          unit: f['unit'] as String? ?? 'g',
          calories: (f['calories'] as num?)?.toDouble(),
        )).toList();

        meals.add(Meal(
          id: row['id'] as String,
          type: MealType.values.firstWhere(
            (t) => t.name == row['type'],
            orElse: () => MealType.lunch,
          ),
          dateTime: DateTime.parse(row['date_time'] as String),
          foods: foods,
          notes: row['notes'] as String?,
          photoPath: row['photo_path'] as String?,
        ));
      }

      return meals;
    } catch (e) {
      print('Erro ao buscar refeições no Supabase: $e');
      return [];
    }
  }

  // ============================================
  // PESOS
  // ============================================
  Future<String?> saveWeightToCloud(WeightEntry entry) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'Usuário não logado';

      final today = DateTime(entry.date.year, entry.date.month, entry.date.day);
      final startOfDay = today.toIso8601String();
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

      await _supabase
          .from('weight_entries')
          .delete()
          .eq('patient_id', user.id)
          .gte('date', startOfDay)
          .lte('date', endOfDay);

      await _supabase.from('weight_entries').insert({
        'patient_id': user.id,
        'date': entry.date.toIso8601String(),
        'weight_kg': entry.weightKg,
        'notes': entry.notes,
      });

      return null;
    } catch (e) {
      print('Erro ao salvar peso no Supabase: $e');
      return 'Erro ao salvar peso: $e';
    }
  }

  Future<List<WeightEntry>> getWeightsFromCloud() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('weight_entries')
          .select()
          .eq('patient_id', user.id)
          .order('date', ascending: true);

      final List<WeightEntry> entries = [];
      
      for (final row in response) {
        entries.add(WeightEntry(
          id: row['id'] as String,
          date: DateTime.parse(row['date'] as String),
          weightKg: (row['weight_kg'] as num).toDouble(),
          notes: row['notes'] as String?,
        ));
      }

      return entries;
    } catch (e) {
      print('Erro ao buscar pesos no Supabase: $e');
      return [];
    }
  }

  // ============================================
  // NUTRICIONISTA: LISTAR PACIENTES
  // ============================================
  Future<List<Map<String, dynamic>>> getAllPatients() async {
    try {
      final response = await _supabase
          .from('patient_profiles')
          .select()
          .order('name', ascending: true);
      return response;
    } catch (e) {
      print('Erro ao buscar pacientes: $e');
      return [];
    }
  }

  // ============================================
  // NUTRICIONISTA: DADOS DE UM PACIENTE ESPECÍFICO
  // ============================================
  Future<List<Meal>> getPatientMeals(String userId) async {
    try {
      final response = await _supabase
          .from('meal_entries')
          .select()
          .eq('patient_id', userId)
          .order('date_time', ascending: false)
          .limit(3);

      final List<Meal> meals = [];
      for (final row in response) {
        final foodsList = (row['foods'] as List<dynamic>?) ?? [];
        final foods = foodsList.map((f) => FoodItem(
          name: f['name'] as String,
          quantity: (f['quantity'] as num).toDouble(),
          unit: f['unit'] as String? ?? 'g',
          calories: (f['calories'] as num?)?.toDouble(),
        )).toList();

        meals.add(Meal(
          id: row['id'] as String,
          type: MealType.values.firstWhere((t) => t.name == row['type'], orElse: () => MealType.lunch),
          dateTime: DateTime.parse(row['date_time'] as String),
          foods: foods,
          notes: row['notes'] as String?,
        ));
      }
      return meals;
    } catch (e) {
      print('Erro ao buscar refeições do paciente: $e');
      return [];
    }
  }

  Future<List<WeightEntry>> getPatientWeights(String userId) async {
    try {
      final response = await _supabase
          .from('weight_entries')
          .select()
          .eq('patient_id', userId)
          .order('date', ascending: true);

      final List<WeightEntry> entries = [];
      for (final row in response) {
        entries.add(WeightEntry(
          id: row['id'] as String,
          date: DateTime.parse(row['date'] as String),
          weightKg: (row['weight_kg'] as num).toDouble(),
          notes: row['notes'] as String?,
        ));
      }
      return entries;
    } catch (e) {
      print('Erro ao buscar pesos do paciente: $e');
      return [];
    }
  }
}