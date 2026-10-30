import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message.dart';
import '../models/meal.dart';
import '../models/nutritionist_profile.dart';
import '../models/patient_profile.dart';
import '../models/symptom_report.dart';
import '../models/weight_entry.dart';
import '../models/sync_operation.dart';
import '../models/anamnesis.dart';

class LocalStorageService {
  static const String _keyProfile = 'patient_profile';
  static const String _keyNutritionistProfile = 'nutritionist_profile';
  static const String _keyWeights = 'weight_entries';
  static const String _keyOnboarded = 'is_onboarded';
  static const String _keyMeals = 'meal_entries';
  static const String _keySymptoms = 'symptom_reports';
  static const String _keyChat = 'chat_messages';
  static const String _keyAnamnesis = 'anamnesis';
  static const String _keySyncQueue = 'sync_queue';
  static const String _keyFoodCatalog = 'food_catalog';
  static const String _keyFoodCatalogUpdatedAt = 'food_catalog_updated_at';

  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Future<SharedPreferences> _prefs() async => await SharedPreferences.getInstance();

  // ============================================
  // PROTEÇÃO MULTI-USUÁRIO
  // ============================================
  Future<SharedPreferences> getScopedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user != null) {
      await _migrateLegacyDataIfNeeded(prefs, user.id);
    }
    return prefs;
  }

  Future<void> _migrateLegacyDataIfNeeded(SharedPreferences prefs, String userId) async {
    const globalMarker = 'legacy_migration_checked';

    if (prefs.getBool(globalMarker) == true) {
      return;
    }

    final lastUserId = prefs.getString('last_user_id');

    if (lastUserId != null && lastUserId != userId) {
      await prefs.setBool(globalMarker, true);
      await prefs.setString('last_user_id', userId);
      return;
    }

    final legacyKeys = [
      _keyProfile, _keyWeights, _keyMeals, _keySymptoms, _keyAnamnesis, _keyChat
    ];

    for (final key in legacyKeys) {
      final legacy = prefs.getString(key);
      if (legacy != null) {
        if (prefs.getString('$userId:$key') == null) {
          await prefs.setString('$userId:$key', legacy);
        }
        await prefs.remove(key);
      }
    }

    await prefs.setBool(globalMarker, true);
    await prefs.setString('last_user_id', userId);
  }

  // ============================================
  // PERFIL DO PACIENTE
  // ============================================
  Future<bool> saveProfile(PatientProfile profile) async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;
      return await prefs.setString('${user.id}:$_keyProfile', jsonEncode(_profileToJson(profile)));
    } catch (e) {
      return false;
    }
  }

  Future<PatientProfile?> loadProfile() async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;
      final jsonString = prefs.getString('${user.id}:$_keyProfile');
      if (jsonString == null) return null;
      return _profileFromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // PERFIL DO NUTRICIONISTA
  // ============================================
  Future<bool> saveNutritionistProfile(NutritionistProfile profile) async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;
      final json = {
        'id': profile.id,
        'name': profile.name,
        'email': profile.email,
        'crn': profile.crn,
        'specialty': profile.specialty,
        'bio': profile.bio,
        'createdAt': profile.createdAt.toIso8601String(),
        'updatedAt': profile.updatedAt?.toIso8601String(),
      };
      return await prefs.setString('${user.id}:$_keyNutritionistProfile', jsonEncode(json));
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // PESOS
  // ============================================
  Future<bool> saveWeight(WeightEntry entry) async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;
      
      final key = '${user.id}:$_keyWeights';
      final jsonString = prefs.getString(key);
      final List<dynamic> list = jsonString != null ? jsonDecode(jsonString) : [];
      final entries = list.map((item) => _weightFromJson(item)).toList();
      
      final today = DateTime(entry.date.year, entry.date.month, entry.date.day);
      entries.removeWhere((e) => DateTime(e.date.year, e.date.month, e.date.day) == today);
      entries.add(entry);
      entries.sort((a, b) => a.date.compareTo(b.date));
      
      return await prefs.setString(key, jsonEncode(entries.map((e) => _weightToJson(e)).toList()));
    } catch (e) {
      return false;
    }
  }

  Future<List<WeightEntry>> loadWeights() async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];
      final jsonString = prefs.getString('${user.id}:$_keyWeights');
      if (jsonString == null) return [];
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((item) => _weightFromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteWeight(String id) async {
    try {
      final entries = await loadWeights();
      entries.removeWhere((e) => e.id == id);
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;
      return await prefs.setString('${user.id}:$_keyWeights', jsonEncode(entries.map((e) => _weightToJson(e)).toList()));
    } catch (e) {
      return false;
    }
  }

  // ⚠️ ESTA ERA A FUNÇÃO QUE ESTAVA FALTANDO
  Future<bool> replaceAllWeights(List<WeightEntry> entries) async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;
      return await prefs.setString('${user.id}:$_keyWeights', jsonEncode(entries.map((e) => _weightToJson(e)).toList()));
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // REFEIÇÕES
  // ============================================
  Future<bool> saveMeal(Meal meal) async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;

      final key = '${user.id}:$_keyMeals';
      final jsonString = prefs.getString(key);
      final List<dynamic> list = jsonString != null ? jsonDecode(jsonString) : [];
      final meals = list.map((item) => _mealFromJson(item)).toList();
      
      meals.removeWhere((m) => m.id == meal.id);
      meals.add(meal);
      meals.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      return await prefs.setString(key, jsonEncode(meals.map((m) => _mealToJson(m)).toList()));
    } catch (e) {
      return false;
    }
  }

  Future<List<Meal>> loadMeals() async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];
      final jsonString = prefs.getString('${user.id}:$_keyMeals');
      if (jsonString == null) return [];
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((item) => _mealFromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Meal>> loadMealsByDate(DateTime date) async {
    final all = await loadMeals();
    return all.where((meal) => meal.dateTime.year == date.year && meal.dateTime.month == date.month && meal.dateTime.day == date.day).toList();
  }

  Future<bool> deleteMeal(String id) async {
    try {
      final meals = await loadMeals();
      meals.removeWhere((m) => m.id == id);
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;
      return await prefs.setString('${user.id}:$_keyMeals', jsonEncode(meals.map((m) => _mealToJson(m)).toList()));
    } catch (e) {
      return false;
    }
  }

  Future<bool> replaceAllMeals(List<Meal> meals) async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;
      return await prefs.setString('${user.id}:$_keyMeals', jsonEncode(meals.map((m) => _mealToJson(m)).toList()));
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // SINTOMAS
  // ============================================
  Future<bool> saveSymptomReport(SymptomReport report) async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;

      final key = '${user.id}:$_keySymptoms';
      final jsonString = prefs.getString(key);
      final List<dynamic> list = jsonString != null ? jsonDecode(jsonString) : [];
      final reports = list.map((item) => _symptomFromJson(item)).toList();
      
      reports.removeWhere((r) => r.id == report.id);
      reports.add(report);
      reports.sort((a, b) => b.date.compareTo(a.date));
      
      return await prefs.setString(key, jsonEncode(reports.map((r) => _symptomToJson(r)).toList()));
    } catch (e) {
      return false;
    }
  }

  Future<List<SymptomReport>> loadSymptomReports() async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];
      final jsonString = prefs.getString('${user.id}:$_keySymptoms');
      if (jsonString == null) return [];
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((item) => _symptomFromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<SymptomReport?> loadLatestSymptomReport() async {
    final reports = await loadSymptomReports();
    return reports.isEmpty ? null : reports.first;
  }

  Future<bool> replaceAllSymptomReports(List<SymptomReport> reports) async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;
      return await prefs.setString('${user.id}:$_keySymptoms', jsonEncode(reports.map((r) => _symptomToJson(r)).toList()));
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // ANAMNESE
  // ============================================
  Future<bool> saveAnamnesis(Anamnesis anamnesis) async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;
      return await prefs.setString('${user.id}:$_keyAnamnesis', jsonEncode(_anamnesisToJson(anamnesis)));
    } catch (e) {
      return false;
    }
  }

  Future<Anamnesis?> loadAnamnesis() async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;
      final jsonString = prefs.getString('${user.id}:$_keyAnamnesis');
      if (jsonString == null) return null;
      return _anamnesisFromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // CHAT
  // ============================================
  Future<bool> saveChatMessage(ChatMessage message) async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;

      final key = '${user.id}:$_keyChat';
      final jsonString = prefs.getString(key);
      final List<dynamic> list = jsonString != null ? jsonDecode(jsonString) : [];
      final messages = list.map((item) => _chatMessageFromJson(item)).toList();
      
      messages.removeWhere((m) => m.id == message.id);
      messages.add(message);
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      return await prefs.setString(key, jsonEncode(messages.map((m) => _chatMessageToJson(m)).toList()));
    } catch (e) {
      return false;
    }
  }

  Future<List<ChatMessage>> loadChatMessages() async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];
      final jsonString = prefs.getString('${user.id}:$_keyChat');
      if (jsonString == null) return [];
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((item) => _chatMessageFromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // FILA DE SINCRONIZAÇÃO
  // ============================================
  Future<List<SyncOperation>> loadSyncOperations() async {
    try {
      final prefs = await _prefs();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];
      final jsonString = prefs.getString('${user.id}:$_keySyncQueue');
      if (jsonString == null) return [];
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((item) => SyncOperation.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveSyncOperations(List<SyncOperation> ops) async {
    final prefs = await _prefs();
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await prefs.setString('${user.id}:$_keySyncQueue', jsonEncode(ops.map((o) => o.toJson()).toList()));
  }

  // ============================================
  // CATÁLOGO DE ALIMENTOS (TACO)
  // ============================================
  Future<bool> saveFoodCatalog(String json) async {
    try {
      final prefs = await _prefs();
      await prefs.setString(_keyFoodCatalog, json);
      await prefs.setString(_keyFoodCatalogUpdatedAt, DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> loadFoodCatalog() async {
    try {
      final prefs = await _prefs();
      return prefs.getString(_keyFoodCatalog);
    } catch (e) {
      return null;
    }
  }

  Future<DateTime?> foodCatalogUpdatedAt() async {
    try {
      final prefs = await _prefs();
      final str = prefs.getString(_keyFoodCatalogUpdatedAt);
      if (str == null) return null;
      return DateTime.parse(str);
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // ONBOARDING E LIMPEZA
  // ============================================
  Future<bool> isOnboarded() async {
    final prefs = await _prefs();
    return prefs.getBool(_keyOnboarded) ?? false;
  }

  Future<void> setOnboarded(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_keyOnboarded, value);
  }

  Future<void> clearAll() async {
    final prefs = await _prefs();
    await prefs.clear();
  }

  // ============================================
  // CONVERSORES
  // ============================================
  Map<String, dynamic> _profileToJson(PatientProfile p) => {
    'id': p.id, 'name': p.name, 'email': p.email, 'phone': p.phone,
    'birthDate': p.birthDate?.toIso8601String(), 'gender': p.gender?.name,
    'heightCm': p.heightCm, 'initialWeightKg': p.initialWeightKg,
    'currentWeightKg': p.currentWeightKg, 'goalWeightKg': p.goalWeightKg,
    'waistCm': p.waistCm, 'goal': p.goal?.name, 'activityLevel': p.activityLevel?.name,
    'foodRestrictions': p.foodRestrictions, 'allergies': p.allergies,
    'notes': p.notes, 'createdAt': p.createdAt.toIso8601String(),
    'updatedAt': p.updatedAt?.toIso8601String(),
  };

  PatientProfile _profileFromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'], name: json['name'], email: json['email'], phone: json['phone'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      gender: json['gender'] != null ? Gender.values.byName(json['gender']) : null,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      initialWeightKg: (json['initialWeightKg'] as num?)?.toDouble(),
      currentWeightKg: (json['currentWeightKg'] as num?)?.toDouble(),
      goalWeightKg: (json['goalWeightKg'] as num?)?.toDouble(),
      waistCm: (json['waistCm'] as num?)?.toDouble(),
      goal: json['goal'] != null ? Goal.values.byName(json['goal']) : null,
      activityLevel: json['activityLevel'] != null ? ActivityLevel.values.byName(json['activityLevel']) : null,
      foodRestrictions: (json['foodRestrictions'] as List).cast<String>(),
      allergies: (json['allergies'] as List).cast<String>(),
      notes: json['notes'], createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> _weightToJson(WeightEntry w) => {'id': w.id, 'date': w.date.toIso8601String(), 'weightKg': w.weightKg, 'notes': w.notes};
  WeightEntry _weightFromJson(Map<String, dynamic> json) => WeightEntry(id: json['id'], date: DateTime.parse(json['date']), weightKg: (json['weightKg'] as num).toDouble(), notes: json['notes']);

  Map<String, dynamic> _mealToJson(Meal meal) => {
    'id': meal.id, 'type': meal.type.name, 'dateTime': meal.dateTime.toIso8601String(),
    'notes': meal.notes, 'photoPath': meal.photoPath,
    'foods': meal.foods.map((f) => {'name': f.name, 'quantity': f.quantity, 'unit': f.unit, 'calories': f.calories}).toList(),
  };

  Meal _mealFromJson(Map<String, dynamic> json) {
    final foods = (json['foods'] as List).map((f) => FoodItem(name: f['name'], quantity: (f['quantity'] as num).toDouble(), unit: f['unit'], calories: (f['calories'] as num?)?.toDouble())).toList();
    return Meal(id: json['id'], type: MealType.values.firstWhere((t) => t.name == json['type'], orElse: () => MealType.lunch), dateTime: DateTime.parse(json['dateTime']), foods: foods, notes: json['notes'], photoPath: json['photoPath']);
  }

  Map<String, dynamic> _symptomToJson(SymptomReport s) => {'id': s.id, 'date': s.date.toIso8601String(), 'symptoms': s.symptoms, 'difficulties': s.difficulties, 'notes': s.notes};
  SymptomReport _symptomFromJson(Map<String, dynamic> json) => SymptomReport(id: json['id'], date: DateTime.parse(json['date']), symptoms: (json['symptoms'] as List).cast<String>(), difficulties: (json['difficulties'] as List).cast<String>(), notes: json['notes']);

  Map<String, dynamic> _anamnesisToJson(Anamnesis a) => {
    'id': a.id, 'patientId': a.patientId, 'mainGoal': a.mainGoal,
    'healthConditions': a.healthConditions, 'medications': a.medications,
    'supplements': a.supplements, 'bowelHabits': a.bowelHabits,
    'sleepQuality': a.sleepQuality, 'waterIntake': a.waterIntake,
    'alcoholConsumption': a.alcoholConsumption, 'smoking': a.smoking,
    'physicalActivity': a.physicalActivity, 'foodAllergies': a.foodAllergies,
    'foodIntolerances': a.foodIntolerances, 'dietaryPreferences': a.dietaryPreferences,
    'createdAt': a.createdAt.toIso8601String(),
    'updatedAt': a.updatedAt?.toIso8601String(),
  };

  Anamnesis _anamnesisFromJson(Map<String, dynamic> json) => Anamnesis(
    id: json['id'], patientId: json['patientId'], mainGoal: json['mainGoal'],
    healthConditions: json['healthConditions'], medications: json['medications'],
    supplements: json['supplements'], bowelHabits: json['bowelHabits'],
    sleepQuality: json['sleepQuality'], waterIntake: json['waterIntake'],
    alcoholConsumption: json['alcoholConsumption'], smoking: json['smoking'],
    physicalActivity: json['physicalActivity'], foodAllergies: json['foodAllergies'],
    foodIntolerances: json['foodIntolerances'], dietaryPreferences: json['dietaryPreferences'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );

  Map<String, dynamic> _chatMessageToJson(ChatMessage m) => {'id': m.id, 'text': m.text, 'timestamp': m.timestamp.toIso8601String(), 'isFromPatient': m.isFromPatient, 'isRead': m.isRead};
  ChatMessage _chatMessageFromJson(Map<String, dynamic> json) => ChatMessage(id: json['id'], text: json['text'], timestamp: DateTime.parse(json['timestamp']), isFromPatient: json['isFromPatient'], isRead: json['isRead'] ?? true);
}