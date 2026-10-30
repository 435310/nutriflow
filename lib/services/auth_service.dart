import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/anamnesis.dart';
import '../models/chat_message.dart';
import '../models/meal.dart';
import '../models/symptom_report.dart';
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
  // PERFIL DO PACIENTE
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

  Future<String?> updatePatientProfile({
    required String name,
    required String email,
    String? phone,
    DateTime? birthDate,
    String? gender,
    double? heightCm,
    double? initialWeightKg,
    double? currentWeightKg,
    double? goalWeightKg,
    double? waistCm,
    String? goal,
    String? activityLevel,
    List<String>? foodRestrictions,
    List<String>? allergies,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'Usuário não logado';

      await _supabase.from('patient_profiles').update({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone,
        'birth_date': birthDate?.toIso8601String(),
        'gender': gender,
        'height_cm': heightCm,
        'initial_weight_kg': initialWeightKg,
        'current_weight_kg': currentWeightKg,
        'goal_weight_kg': goalWeightKg,
        'waist_cm': waistCm,
        'goal': goal,
        'activity_level': activityLevel,
        'food_restrictions': foodRestrictions,
        'allergies': allergies,
      }).eq('user_id', user.id);

      return null;
    } catch (e) {
      print('Erro ao atualizar perfil no Supabase: $e');
      return 'Erro ao atualizar perfil: $e';
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

      print('═══════════════════════════════════');
      print('SALVANDO REFEIÇÃO: ${meal.type.label}');
      print('ALIMENTOS: $foodsJson');
      print('═══════════════════════════════════');

      await _supabase.from('meal_entries').insert({
        'patient_id': user.id,
        'type': meal.type.name,
        'date_time': meal.dateTime.toIso8601String(),
        'notes': meal.notes,
        'photo_path': meal.photoPath,
        'foods': foodsJson,
      });

      return null;
    } catch (e, stacktrace) {
      print('═══════════════════════════════════');
      print('ERRO AO SALVAR REFEIÇÃO: $e');
      print('STACKTRACE: $stacktrace');
      print('═══════════════════════════════════');
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
          type: MealType.values.firstWhere((t) => t.name == row['type'], orElse: () => MealType.lunch),
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
  // SINTOMAS
  // ============================================
  Future<String?> saveSymptomToCloud(SymptomReport report) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'Usuário não logado';

      await _supabase.from('symptom_reports').insert({
        'patient_id': user.id,
        'date': report.date.toIso8601String(),
        'symptoms': report.symptoms,
        'difficulties': report.difficulties,
        'notes': report.notes,
      });

      return null;
    } catch (e) {
      print('Erro ao salvar sintomas no Supabase: $e');
      return 'Erro ao salvar sintomas: $e';
    }
  }

  Future<SymptomReport?> getLatestSymptomFromCloud() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('symptom_reports')
          .select()
          .eq('patient_id', user.id)
          .order('date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return SymptomReport(
        id: response['id'] as String,
        date: DateTime.parse(response['date'] as String),
        symptoms: (response['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
        difficulties: (response['difficulties'] as List<dynamic>?)?.cast<String>() ?? [],
        notes: response['notes'] as String?,
      );
    } catch (e) {
      print('Erro ao buscar sintomas no Supabase: $e');
      return null;
    }
  }

  Future<List<SymptomReport>> getPatientSymptoms(String userId) async {
    try {
      final response = await _supabase
          .from('symptom_reports')
          .select()
          .eq('patient_id', userId)
          .order('date', ascending: false);

      final List<SymptomReport> reports = [];
      for (final row in response) {
        reports.add(SymptomReport(
          id: row['id'] as String,
          date: DateTime.parse(row['date'] as String),
          symptoms: (row['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
          difficulties: (row['difficulties'] as List<dynamic>?)?.cast<String>() ?? [],
          notes: row['notes'] as String?,
        ));
      }
      return reports;
    } catch (e) {
      print('Erro ao buscar sintomas do paciente: $e');
      return [];
    }
  }

  // ============================================
  // CHAT
  // ============================================
  Future<String?> sendMessageToCloud(String text, {required bool isFromPatient}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'Usuário não logado';

      await _supabase.from('chat_messages').insert({
        'sender_id': user.id,
        'receiver_id': '00000000-0000-0000-0000-000000000000',
        'text': text,
        'is_from_patient': isFromPatient,
        'is_read': false,
      });

      return null;
    } catch (e) {
      print('Erro ao enviar mensagem no Supabase: $e');
      return 'Erro ao enviar mensagem: $e';
    }
  }

  Future<List<ChatMessage>> getChatMessagesFromCloud() async {
    try {
      final response = await _supabase
          .from('chat_messages')
          .select()
          .order('created_at', ascending: true);

      final List<ChatMessage> messages = [];
      for (final row in response) {
        messages.add(ChatMessage(
          id: row['id'] as String,
          text: row['text'] as String,
          timestamp: DateTime.parse(row['created_at'] as String),
          isFromPatient: row['is_from_patient'] as bool,
          isRead: row['is_read'] as bool? ?? true,
        ));
      }
      return messages;
    } catch (e) {
      print('Erro ao buscar mensagens no Supabase: $e');
      return [];
    }
  }

  Future<int> countUnreadMessagesFromCloud({required bool forNutritionist}) async {
    try {
      final response = await _supabase
          .from('chat_messages')
          .select('id')
          .eq('is_from_patient', forNutritionist)
          .eq('is_read', false);
      
      return (response as List).length;
    } catch (e) {
      print('Erro ao contar mensagens não lidas: $e');
      return 0;
    }
  }

  Future<void> markMessagesAsReadInCloud({required bool byNutritionist}) async {
    try {
      await _supabase
          .from('chat_messages')
          .update({'is_read': true})
          .eq('is_from_patient', byNutritionist)
          .eq('is_read', false);
    } catch (e) {
      print('Erro ao marcar mensagens como lidas: $e');
    }
  }

  Stream<int> watchUnreadMessages({required bool forNutritionist}) {
    return _supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('is_from_patient', forNutritionist)
        .eq('is_read', false)
        .map((list) => list.length);
  }

  // ============================================
  // UPLOAD DE FOTO (SUPABASE STORAGE)
  // ============================================
  Future<String?> uploadMealPhoto(Uint8List bytes, String fileName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final fileExt = fileName.split('.').last;
      final uniqueName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage.from('meal-photos').uploadBinary(
        uniqueName,
        bytes, 
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );

      return uniqueName;
    } catch (e) {
      print('Erro ao fazer upload da foto: $e');
      return null;
    }
  }

  Future<String?> getMealPhotoUrl(String path) async {
    try {
      final response = await _supabase.storage
          .from('meal-photos')
          .createSignedUrl(path, 3600);
      return response;
    } catch (e) {
      print('Erro ao gerar URL da foto: $e');
      return null;
    }
  }

  // ============================================
  // ANAMNESE
  // ============================================
  Future<String?> saveAnamnesis(Anamnesis anamnesis) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'Usuário não logado';

      final existing = await _supabase
          .from('anamnesis')
          .select('id')
          .eq('patient_id', user.id)
          .maybeSingle();

      if (existing != null) {
        await _supabase.from('anamnesis').update({
          'main_goal': anamnesis.mainGoal,
          'health_conditions': anamnesis.healthConditions,
          'medications': anamnesis.medications,
          'supplements': anamnesis.supplements,
          'bowel_habits': anamnesis.bowelHabits,
          'sleep_quality': anamnesis.sleepQuality,
          'water_intake': anamnesis.waterIntake,
          'alcohol_consumption': anamnesis.alcoholConsumption,
          'smoking': anamnesis.smoking,
          'physical_activity': anamnesis.physicalActivity,
          'food_allergies': anamnesis.foodAllergies,
          'food_intolerances': anamnesis.foodIntolerances,
          'dietary_preferences': anamnesis.dietaryPreferences,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('patient_id', user.id);
      } else {
        await _supabase.from('anamnesis').insert({
          'patient_id': user.id,
          'main_goal': anamnesis.mainGoal,
          'health_conditions': anamnesis.healthConditions,
          'medications': anamnesis.medications,
          'supplements': anamnesis.supplements,
          'bowel_habits': anamnesis.bowelHabits,
          'sleep_quality': anamnesis.sleepQuality,
          'water_intake': anamnesis.waterIntake,
          'alcohol_consumption': anamnesis.alcoholConsumption,
          'smoking': anamnesis.smoking,
          'physical_activity': anamnesis.physicalActivity,
          'food_allergies': anamnesis.foodAllergies,
          'food_intolerances': anamnesis.foodIntolerances,
          'dietary_preferences': anamnesis.dietaryPreferences,
        });
      }

      return null;
    } catch (e) {
      print('Erro ao salvar anamnese: $e');
      return 'Erro ao salvar anamnese: $e';
    }
  }

  Future<Anamnesis?> getAnamnesis(String patientId) async {
    try {
      final response = await _supabase
          .from('anamnesis')
          .select()
          .eq('patient_id', patientId)
          .maybeSingle();

      if (response == null) return null;

      return Anamnesis(
        id: response['id'] as String,
        patientId: response['patient_id'] as String,
        mainGoal: response['main_goal'] as String?,
        healthConditions: response['health_conditions'] as String?,
        medications: response['medications'] as String?,
        supplements: response['supplements'] as String?,
        bowelHabits: response['bowel_habits'] as String?,
        sleepQuality: response['sleep_quality'] as String?,
        waterIntake: response['water_intake'] as String?,
        alcoholConsumption: response['alcohol_consumption'] as String?,
        smoking: response['smoking'] as String?,
        physicalActivity: response['physical_activity'] as String?,
        foodAllergies: response['food_allergies'] as String?,
        foodIntolerances: response['food_intolerances'] as String?,
        dietaryPreferences: response['dietary_preferences'] as String?,
        createdAt: DateTime.parse(response['created_at'] as String),
        updatedAt: response['updated_at'] != null 
            ? DateTime.parse(response['updated_at'] as String) 
            : null,
      );
    } catch (e) {
      print('Erro ao buscar anamnese: $e');
      return null;
    }
  }

  // ============================================
  // TACO (BUSCA DE ALIMENTOS)
  // ============================================
  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    try {
      final response = await _supabase
          .from('foods')
          .select()
          .ilike('name', '%$query%')
          .limit(10);
      return response;
    } catch (e) {
      print('Erro ao buscar alimentos: $e');
      return [];
    }
  }

  // ============================================
  // NUTRICIONISTA: LISTAR PACIENTES E DADOS
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
          photoPath: row['photo_path'] as String?,
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