import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/patient_profile.dart';
import '../models/weight_entry.dart';

/// ============================================
/// SERVIÇO DE ARMAZENAMENTO LOCAL
/// ============================================
/// Salva e carrega dados no dispositivo usando SharedPreferences.
/// Funciona como uma "camada" entre o app e o storage.
class LocalStorageService {
  // ============================================
  // CHAVES
  // ============================================
  static const String _keyProfile = 'patient_profile';
  static const String _keyWeights = 'weight_entries';
  static const String _keyOnboarded = 'is_onboarded';

  // ============================================
  // INSTÂNCIA ÚNICA (singleton)
  // ============================================
  static final LocalStorageService _instance =
      LocalStorageService._internal();

  factory LocalStorageService() => _instance;

  LocalStorageService._internal();

  // ============================================
  // PERFIL DO PACIENTE
  // ============================================

  /// Salva o perfil do paciente
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

  /// Carrega o perfil do paciente
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

  /// Remove o perfil
  Future<bool> deleteProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_keyProfile);
  }

  // ============================================
  // REGISTROS DE PESO
  // ============================================

  /// Salva um novo peso (adiciona à lista)
  Future<bool> saveWeight(WeightEntry entry) async {
    try {
      final entries = await loadWeights();

      // Evita duplicata por data (mesmo dia = substitui)
      final today = DateTime(entry.date.year, entry.date.month, entry.date.day);
      entries.removeWhere((e) {
        final d = DateTime(e.date.year, e.date.month, e.date.day);
        return d == today;
      });

      entries.add(entry);

      // Ordena por data (mais antigo primeiro)
      entries.sort((a, b) => a.date.compareTo(b.date));

      return await _saveAllWeights(entries);
    } catch (e) {
      print('Erro ao salvar peso: $e');
      return false;
    }
  }

  /// Carrega todos os pesos
  Future<List<WeightEntry>> loadWeights() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyWeights);
      if (jsonString == null) return [];

      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((item) => _weightFromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao carregar pesos: $e');
      return [];
    }
  }

  /// Remove um peso pelo ID
  Future<bool> deleteWeight(String id) async {
    final entries = await loadWeights();
    entries.removeWhere((e) => e.id == id);
    return await _saveAllWeights(entries);
  }

  /// Salva a lista inteira de pesos
  Future<bool> _saveAllWeights(List<WeightEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final list = entries.map((e) => _weightToJson(e)).toList();
    return await prefs.setString(_keyWeights, jsonEncode(list));
  }

  // ============================================
  // FLAG: JÁ PASSOU PELO ONBOARDING?
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
  // LIMPAR TUDO (útil em logout)
  // ============================================
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ============================================
  // CONVERSÃO PARA JSON
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
      foodRestrictions: (json['foodRestrictions'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      allergies: (json['allergies'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

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
}