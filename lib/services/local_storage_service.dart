import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';
import '../models/patient_profile.dart';
import '../models/symptom_report.dart';
import '../models/weight_entry.dart';
import '../models/chat_message.dart';

/// ============================================
/// SERVIÇO DE ARMAZENAMENTO LOCAL
/// ============================================
class LocalStorageService {
  static const String _keyProfile = 'patient_profile';
  static const String _keyWeights = 'weight_entries';
  static const String _keyOnboarded = 'is_onboarded';
  static const String _keyMeals = 'meal_entries';
  static const String _keySymptoms = 'symptom_reports';
  static const String _keyChat = 'chat_messages';

  static final LocalStorageService _instance =
      LocalStorageService._internal();

  factory LocalStorageService() => _instance;

  LocalStorageService._internal();

  // ============================================
  // PERFIL
  // ============================================
  Future<bool> saveProfile(PatientProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = _profileToJson(profile);
      return await prefs.setString(_keyProfile, jsonEncode(json));
    } catch (e) {
      print('Erro ao salvar perfil: $e');
      return false;
    }
  }

  Future<PatientProfile?> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyProfile);
      if (jsonString == null) return null;
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return _profileFromJson(json);
    } catch (e) {
      print('Erro ao carregar perfil: $e');
      return null;
    }
  }

  Future<bool> deleteProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_keyProfile);
  }

  // ============================================
  // REGISTROS DE PESO
  // ============================================
  Future<bool> saveWeight(WeightEntry entry) async {
    try {
      final entries = await loadWeights();

      final today = DateTime(entry.date.year, entry.date.month, entry.date.day);
      entries.removeWhere((e) {
        final d = DateTime(e.date.year, e.date.month, e.date.day);
        return d == today;
      });

      entries.add(entry);
      entries.sort((a, b) => a.date.compareTo(b.date));

      return await _saveAllWeights(entries);
    } catch (e) {
      print('Erro ao salvar peso: $e');
      return false;
    }
  }

  Future<List<WeightEntry>> loadWeights() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyWeights);
      if (jsonString == null) return <WeightEntry>[];

      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((item) => _weightFromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao carregar pesos: $e');
      return <WeightEntry>[];
    }
  }

  Future<bool> deleteWeight(String id) async {
    try {
      final entries = await loadWeights();
      entries.removeWhere((e) => e.id == id);
      return await _saveAllWeights(entries);
    } catch (e) {
      print('Erro ao deletar peso: $e');
      return false;
    }
  }

  Future<bool> _saveAllWeights(List<WeightEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final list = entries.map((e) => _weightToJson(e)).toList();
    return await prefs.setString(_keyWeights, jsonEncode(list));
  }

  // ============================================
  // REFEIÇÕES
  // ============================================
  Future<bool> saveMeal(Meal meal) async {
    try {
      final meals = await loadMeals();
      meals.add(meal);
      meals.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return await _saveAllMeals(meals);
    } catch (e) {
      print('Erro ao salvar refeição: $e');
      return false;
    }
  }

  Future<List<Meal>> loadMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyMeals);
      if (jsonString == null) return <Meal>[];

      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((item) => _mealFromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao carregar refeições: $e');
      return <Meal>[];
    }
  }

  Future<List<Meal>> loadMealsByDate(DateTime date) async {
    final all = await loadMeals();
    return all.where((meal) {
      return meal.dateTime.year == date.year &&
          meal.dateTime.month == date.month &&
          meal.dateTime.day == date.day;
    }).toList();
  }

  Future<bool> deleteMeal(String id) async {
    try {
      final meals = await loadMeals();
      meals.removeWhere((m) => m.id == id);
      return await _saveAllMeals(meals);
    } catch (e) {
      print('Erro ao deletar refeição: $e');
      return false;
    }
  }

  Future<bool> _saveAllMeals(List<Meal> meals) async {
    final prefs = await SharedPreferences.getInstance();
    final list = meals.map((m) => _mealToJson(m)).toList();
    return await prefs.setString(_keyMeals, jsonEncode(list));
  }

  // ============================================
  // SINTOMAS E DIFICULDADES
  // ============================================
  Future<bool> saveSymptomReport(SymptomReport report) async {
    try {
      final reports = await loadSymptomReports();
      reports.add(report);
      reports.sort((a, b) => b.date.compareTo(a.date));
      return await _saveAllSymptomReports(reports);
    } catch (e) {
      print('Erro ao salvar relato: $e');
      return false;
    }
  }

  Future<List<SymptomReport>> loadSymptomReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keySymptoms);
      if (jsonString == null) return <SymptomReport>[];

      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((item) => _symptomFromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao carregar relatos: $e');
      return <SymptomReport>[];
    }
  }

  Future<SymptomReport?> loadLatestSymptomReport() async {
    final reports = await loadSymptomReports();
    if (reports.isEmpty) return null;
    return reports.first;
  }

  Future<bool> deleteSymptomReport(String id) async {
    try {
      final reports = await loadSymptomReports();
      reports.removeWhere((r) => r.id == id);
      return await _saveAllSymptomReports(reports);
    } catch (e) {
      print('Erro ao deletar relato: $e');
      return false;
    }
  }

  Future<bool> _saveAllSymptomReports(List<SymptomReport> reports) async {
    final prefs = await SharedPreferences.getInstance();
    final list = reports.map((r) => _symptomToJson(r)).toList();
    return await prefs.setString(_keySymptoms, jsonEncode(list));
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
      print('Erro ao salvar mensagem: $e');
      return false;
    }
  }

  Future<List<ChatMessage>> loadChatMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyChat);
      if (jsonString == null) return <ChatMessage>[];

      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((item) => _chatMessageFromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao carregar mensagens: $e');
      return <ChatMessage>[];
    }
  }

  Future<bool> _saveAllChatMessages(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final list = messages.map((m) => _chatMessageToJson(m)).toList();
    return await prefs.setString(_keyChat, jsonEncode(list));
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

  // ============================================
  // LIMPAR TUDO
  // ============================================
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ============================================
  // CONVERSÃO PARA JSON — PERFIL
  // ============================================
  Map<String, dynamic> _profileToJson(PatientProfile p) {
    return {
      'id': p.id,
      'name': p.name,
      'email': p.email,
      'phone': p.phone,
      'birthDate': p.birthDate?.toIso8601String(),
      'gender': p.gender?.name,
      'heightCm': p.heightCm,
      'initialWeightKg': p.initialWeightKg,
      'currentWeightKg': p.currentWeightKg,
      'goalWeightKg': p.goalWeightKg,
      'waistCm': p.waistCm,
      'goal': p.goal?.name,
      'activityLevel': p.activityLevel?.name,
      'foodRestrictions': p.foodRestrictions,
      'allergies': p.allergies,
      'notes': p.notes,
      'createdAt': p.createdAt.toIso8601String(),
      'updatedAt': p.updatedAt?.toIso8601String(),
    };
  }

  PatientProfile _profileFromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      gender: json['gender'] != null
          ? Gender.values.byName(json['gender'] as String)
          : null,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      initialWeightKg: (json['initialWeightKg'] as num?)?.toDouble(),
      currentWeightKg: (json['currentWeightKg'] as num?)?.toDouble(),
      goalWeightKg: (json['goalWeightKg'] as num?)?.toDouble(),
      waistCm: (json['waistCm'] as num?)?.toDouble(),
      goal: json['goal'] != null
          ? Goal.values.byName(json['goal'] as String)
          : null,
      activityLevel: json['activityLevel'] != null
          ? ActivityLevel.values.byName(json['activityLevel'] as String)
          : null,
      foodRestrictions:
          (json['foodRestrictions'] as List<dynamic>?)?.cast<String>() ?? [],
      allergies:
          (json['allergies'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // ============================================
  // CONVERSÃO PARA JSON — PESO
  // ============================================
  Map<String, dynamic> _weightToJson(WeightEntry w) {
    return {
      'id': w.id,
      'date': w.date.toIso8601String(),
      'weightKg': w.weightKg,
      'notes': w.notes,
    };
  }

  WeightEntry _weightFromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  // ============================================
  // CONVERSÃO PARA JSON — REFEIÇÕES
  // ============================================
  Map<String, dynamic> _mealToJson(Meal meal) {
    return {
      'id': meal.id,
      'type': meal.type.name,
      'dateTime': meal.dateTime.toIso8601String(),
      'notes': meal.notes,
      'photoPath': meal.photoPath,
      'foods': meal.foods.map((f) => {
            'name': f.name,
            'quantity': f.quantity,
            'unit': f.unit,
            'calories': f.calories,
          }).toList(),
    };
  }

  Meal _mealFromJson(Map<String, dynamic> json) {
    final foodsList = (json['foods'] as List<dynamic>?) ?? [];
    final foods = foodsList.map((f) {
      final map = f as Map<String, dynamic>;
      return FoodItem(
        name: map['name'] as String,
        quantity: (map['quantity'] as num).toDouble(),
        unit: map['unit'] as String? ?? 'g',
        calories: (map['calories'] as num?)?.toDouble(),
      );
    }).toList();

    return Meal(
      id: json['id'] as String,
      type: MealType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MealType.lunch,
      ),
      dateTime: DateTime.parse(json['dateTime'] as String),
      foods: foods,
      notes: json['notes'] as String?,
      photoPath: json['photoPath'] as String?,
    );
  }

  // ============================================
  // CONVERSÃO PARA JSON — SINTOMAS
  // ============================================
  Map<String, dynamic> _symptomToJson(SymptomReport report) {
    return {
      'id': report.id,
      'date': report.date.toIso8601String(),
      'symptoms': report.symptoms,
      'difficulties': report.difficulties,
      'notes': report.notes,
    };
  }

  SymptomReport _symptomFromJson(Map<String, dynamic> json) {
    return SymptomReport(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      symptoms: (json['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
      difficulties:
          (json['difficulties'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: json['notes'] as String?,
    );
  }
}
  // ============================================
  // JSON — CHAT
  // ============================================
  Map<String, dynamic> _chatMessageToJson(ChatMessage m) {
    return {
      'id': m.id,
      'text': m.text,
      'timestamp': m.timestamp.toIso8601String(),
      'isFromPatient': m.isFromPatient,
      'isRead': m.isRead,
    };
  }

  ChatMessage _chatMessageFromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFromPatient: json['isFromPatient'] as bool,
      isRead: json['isRead'] as bool? ?? true,
    );
  }