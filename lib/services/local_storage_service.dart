import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message.dart';
import '../models/meal.dart';
import '../models/nutritionist_profile.dart';
import '../models/patient_profile.dart';
import '../models/symptom_report.dart';
import '../models/sync_operation.dart';
import '../models/weight_entry.dart';

/// ============================================
/// SERVIÇO DE ARMAZENAMENTO LOCAL
/// ============================================
/// Os dados ficam separados por usuário: cada chave é gravada como
/// `<userId>:<chave>`. Assim, outra conta no mesmo navegador não vê
/// os dados da anterior.
class LocalStorageService {
  static const String _keyProfile = 'patient_profile';
  static const String _keyNutritionistProfile = 'nutritionist_profile';
  static const String _keyWeights = 'weight_entries';
  static const String _keyOnboarded = 'is_onboarded'; // global (por aparelho)
  static const String _keyMeals = 'meal_entries';
  static const String _keySymptoms = 'symptom_reports';
  static const String _keyChat = 'chat_messages';
  static const String _keySyncQueue = 'sync_queue';
  static const String _keyFoodCatalog = 'food_catalog';
  static const String _keyFoodCatalogUpdatedAt = 'food_catalog_updated_at';

  /// Chaves antigas (sem escopo de usuário) que são migradas para o primeiro
  /// usuário que entrar depois desta atualização.
  static const List<String> _legacyKeys = [
    _keyProfile,
    _keyNutritionistProfile,
    _keyWeights,
    _keyMeals,
    _keySymptoms,
    _keyChat,
  ];

  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // ============================================
  // ESCOPO POR USUÁRIO
  // ============================================
  String get _scope {
    try {
      return Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    } catch (_) {
      return 'guest';
    }
  }

  String _k(String key) => '$_scope:$key';

  Future<SharedPreferences> _prefs() async {
    final prefs = await SharedPreferences.getInstance();
    final scope = _scope;
    if (scope == 'guest') return prefs;

    final marker = '$scope:legacy_migrated';
    if (prefs.getBool(marker) == true) return prefs;

    for (final key in _legacyKeys) {
      final legacy = prefs.getString(key);
      if (legacy == null) continue;
      if (prefs.getString('$scope:$key') == null) {
        await prefs.setString('$scope:$key', legacy);
      }
      await prefs.remove(key);
    }
    await prefs.setBool(marker, true);
    return prefs;
  }

  // ============================================
  // PERFIL DO PACIENTE
  // ============================================
  Future<bool> saveProfile(PatientProfile profile) async {
    try {
      final prefs = await _prefs();
      return await prefs.setString(_k(_keyProfile), jsonEncode(_profileToJson(profile)));
    } catch (e) {
      return false;
    }
  }

  Future<PatientProfile?> loadProfile() async {
    try {
      final prefs = await _prefs();
      final jsonString = prefs.getString(_k(_keyProfile));
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
      return await prefs.setString(_k(_keyNutritionistProfile), jsonEncode(json));
    } catch (e) {
      return false;
    }
  }

  Future<NutritionistProfile?> loadNutritionistProfile() async {
    try {
      final prefs = await _prefs();
      final jsonString = prefs.getString(_k(_keyNutritionistProfile));
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return NutritionistProfile(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        crn: json['crn'],
        specialty: json['specialty'],
        bio: json['bio'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      );
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // PESOS
  // ============================================
  Future<bool> saveWeight(WeightEntry entry) async {
    try {
      final entries = await loadWeights();
      final today = DateTime(entry.date.year, entry.date.month, entry.date.day);
      entries.removeWhere((e) => DateTime(e.date.year, e.date.month, e.date.day) == today);
      entries.add(entry);
      entries.sort((a, b) => a.date.compareTo(b.date));
      return await _saveAllWeights(entries);
    } catch (e) {
      return false;
    }
  }

  Future<List<WeightEntry>> loadWeights() async {
    try {
      final prefs = await _prefs();
      final jsonString = prefs.getString(_k(_keyWeights));
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
      return await _saveAllWeights(entries);
    } catch (e) {
      return false;
    }
  }

  /// Substitui todos os pesos (usado pelo SyncService ao mesclar dados da nuvem).
  Future<bool> replaceAllWeights(List<WeightEntry> entries) => _saveAllWeights(entries);

  Future<bool> _saveAllWeights(List<WeightEntry> entries) async {
    final prefs = await _prefs();
    return await prefs.setString(_k(_keyWeights), jsonEncode(entries.map((e) => _weightToJson(e)).toList()));
  }

  // ============================================
  // REFEIÇÕES
  // ============================================
  Future<bool> saveMeal(Meal meal) async {
    try {
      final meals = await loadMeals();
      meals.removeWhere((m) => m.id == meal.id); // salvar de novo = atualizar
      meals.add(meal);
      meals.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return await _saveAllMeals(meals);
    } catch (e) {
      return false;
    }
  }

  Future<List<Meal>> loadMeals() async {
    try {
      final prefs = await _prefs();
      final jsonString = prefs.getString(_k(_keyMeals));
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
      return await _saveAllMeals(meals);
    } catch (e) {
      return false;
    }
  }

  /// Substitui todas as refeições (usado pelo SyncService ao mesclar dados da nuvem).
  Future<bool> replaceAllMeals(List<Meal> meals) => _saveAllMeals(meals);

  Future<bool> _saveAllMeals(List<Meal> meals) async {
    final prefs = await _prefs();
    return await prefs.setString(_k(_keyMeals), jsonEncode(meals.map((m) => _mealToJson(m)).toList()));
  }

  // ============================================
  // SINTOMAS
  // ============================================
  Future<bool> saveSymptomReport(SymptomReport report) async {
    try {
      final reports = await loadSymptomReports();
      reports.removeWhere((r) => r.id == report.id); // salvar de novo = atualizar
      reports.add(report);
      reports.sort((a, b) => b.date.compareTo(a.date));
      return await _saveAllSymptomReports(reports);
    } catch (e) {
      return false;
    }
  }

  Future<List<SymptomReport>> loadSymptomReports() async {
    try {
      final prefs = await _prefs();
      final jsonString = prefs.getString(_k(_keySymptoms));
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

  /// Substitui todos os relatórios (usado pelo SyncService ao mesclar dados da nuvem).
  Future<bool> replaceAllSymptomReports(List<SymptomReport> reports) => _saveAllSymptomReports(reports);

  Future<bool> _saveAllSymptomReports(List<SymptomReport> reports) async {
    final prefs = await _prefs();
    return await prefs.setString(_k(_keySymptoms), jsonEncode(reports.map((r) => _symptomToJson(r)).toList()));
  }

  // ============================================
  // CHAT
  // ============================================
  Future<bool> saveChatMessage(ChatMessage message) async {
    try {
      final messages = await loadChatMessages();
      messages.add(message);
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return await _saveAllChatMessages(messages);
    } catch (e) {
      return false;
    }
  }

  Future<List<ChatMessage>> loadChatMessages() async {
    try {
      final prefs = await _prefs();
      final jsonString = prefs.getString(_k(_keyChat));
      if (jsonString == null) return [];
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((item) => _chatMessageFromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> countUnreadMessages({required bool forNutritionist}) async {
    final messages = await loadChatMessages();
    return messages.where((m) {
      final isFromOther = forNutritionist ? m.isFromPatient : !m.isFromPatient;
      return isFromOther && !m.isRead;
    }).length;
  }

  Future<void> markMessagesAsRead({required bool byNutritionist}) async {
    try {
      final messages = await loadChatMessages();
      bool changed = false;
      final updated = messages.map((m) {
        final isFromOther = byNutritionist ? m.isFromPatient : !m.isFromPatient;
        if (isFromOther && !m.isRead) {
          changed = true;
          return m.copyWith(isRead: true);
        }
        return m;
      }).toList();

      if (changed) await _saveAllChatMessages(updated);
    } catch (e) {}
  }

  Future<bool> _saveAllChatMessages(List<ChatMessage> messages) async {
    final prefs = await _prefs();
    return await prefs.setString(_k(_keyChat), jsonEncode(messages.map((m) => _chatMessageToJson(m)).toList()));
  }

  // ============================================
  // FILA DE SINCRONIZAÇÃO
  // ============================================
  Future<List<SyncOperation>> loadSyncOperations() async {
    try {
      final prefs = await _prefs();
      final jsonString = prefs.getString(_k(_keySyncQueue));
      if (jsonString == null) return [];
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((item) => SyncOperation.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveSyncOperations(List<SyncOperation> operations) async {
    try {
      final prefs = await _prefs();
      return await prefs.setString(_k(_keySyncQueue), jsonEncode(operations.map((o) => o.toJson()).toList()));
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // ONBOARDING
  // ============================================
  Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarded) ?? false;
  }

  Future<void> setOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarded, value);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ============================================
  // CATÁLOGO DE ALIMENTOS (TACO)
  // Dados públicos: ficam sem escopo de usuário
  // ============================================
  Future<bool> saveFoodCatalog(List<Map<String, dynamic>> foods) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyFoodCatalogUpdatedAt, DateTime.now().toIso8601String());
      return await prefs.setString(_keyFoodCatalog, jsonEncode(foods));
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> loadFoodCatalog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyFoodCatalog);
      if (jsonString == null) return [];
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<DateTime?> foodCatalogUpdatedAt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_keyFoodCatalogUpdatedAt);
      return value == null ? null : DateTime.parse(value);
    } catch (e) {
      return null;
    }
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

  Map<String, dynamic> _chatMessageToJson(ChatMessage m) => {'id': m.id, 'text': m.text, 'timestamp': m.timestamp.toIso8601String(), 'isFromPatient': m.isFromPatient, 'isRead': m.isRead};
  ChatMessage _chatMessageFromJson(Map<String, dynamic> json) => ChatMessage(id: json['id'], text: json['text'], timestamp: DateTime.parse(json['timestamp']), isFromPatient: json['isFromPatient'], isRead: json['isRead'] ?? true);
}