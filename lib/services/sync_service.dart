import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/utils/id_generator.dart';
import '../models/meal.dart';
import '../models/symptom_report.dart';
import '../models/sync_operation.dart';
import '../models/weight_entry.dart';
import 'auth_service.dart';
import 'auth_service_sync.dart';
import 'local_storage_service.dart';

/// Resultado de um salvamento feito pelo SyncService.
enum SyncStatus {
  /// Salvo no aparelho e já confirmado na nuvem.
  synced,

  /// Salvo no aparelho; o envio para a nuvem ficou na fila.
  pending,

  /// Não foi possível nem salvar no aparelho.
  localFailed,
}

/// ============================================
/// SERVIÇO DE SINCRONIZAÇÃO (OFFLINE-FIRST)
/// ============================================
/// Fluxo de escrita: salva local -> registra na fila -> tenta enviar.
/// Se falhar, o item continua na fila e é reenviado na próxima sincronização.
/// Fluxo de leitura: as telas leem do LocalStorageService; `pullFromCloud`
/// traz para o local o que veio de outros aparelhos.
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _local = LocalStorageService();
  final _auth = AuthService();

  bool _pushing = false;
  Future<void> _lockTail = Future.value();

  /// Serializa tudo que lê e altera dados locais ou a fila (chamadas de rede ficam fora).
  Future<T> _withLock<T>(Future<T> Function() action) {
    final completer = Completer<void>();
    final previous = _lockTail;
    _lockTail = completer.future;
    return previous.then((_) => action()).whenComplete(completer.complete);
  }

  // ============================================
  // REFEIÇÕES
  // ============================================
  Future<SyncStatus> saveMeal(Meal meal) async {
    final normalized = IdGenerator.isUuid(meal.id)
        ? meal
        : Meal(
            id: IdGenerator.uuid(),
            type: meal.type,
            dateTime: meal.dateTime,
            foods: meal.foods,
            notes: meal.notes,
            photoPath: meal.photoPath,
          );

    final saved = await _withLock(() async {
      if (!await _local.saveMeal(normalized)) return false;
      await _enqueue(SyncEntity.meal, normalized.id, SyncAction.upsert);
      return true;
    });
    if (!saved) return SyncStatus.localFailed;

    return _pushAndReport(SyncEntity.meal, normalized.id);
  }

  Future<SyncStatus> deleteMeal(String id) async {
    final done = await _withLock(() async {
      if (!await _local.deleteMeal(id)) return false;
      // Ids antigos (não-UUID) nunca existiram na nuvem: não há o que apagar lá
      if (IdGenerator.isUuid(id)) await _enqueue(SyncEntity.meal, id, SyncAction.delete);
    return true;
    });
    if (!done) return SyncStatus.localFailed;

    return _pushAndReport(SyncEntity.meal, id);
  }

  // ============================================
  // PESOS (um registro por dia)
  // ============================================
  Future<SyncStatus> saveWeight(WeightEntry entry) async {
    final saved = await _withLock(() async {
      final existing = await _local.loadWeights();
      WeightEntry? sameDay;
      for (final w in existing) {
        if (_isSameDay(w.date, entry.date)) {
          sameDay = w;
          break;
        }
      }

      // Reaproveita o id do dia para a nuvem continuar com uma única linha por dia.
      final id = (sameDay != null && IdGenerator.isUuid(sameDay.id))
          ? sameDay.id
          : (IdGenerator.isUuid(entry.id) ? entry.id : IdGenerator.uuid());

      final normalized = WeightEntry(id: id, date: entry.date, weightKg: entry.weightKg, notes: entry.notes);
      if (!await _local.saveWeight(normalized)) return null;
      await _enqueue(SyncEntity.weight, id, SyncAction.upsert);
      return id;
    });
    if (saved == null) return SyncStatus.localFailed;

    return _pushAndReport(SyncEntity.weight, saved);
  }

  Future<SyncStatus> deleteWeight(String id) async {
    final done = await _withLock(() async {
      if (!await _local.deleteWeight(id)) return false;
      if (IdGenerator.isUuid(id)) await _enqueue(SyncEntity.weight, id, SyncAction.delete);
    return true;
    });
    if (!done) return SyncStatus.localFailed;

    return _pushAndReport(SyncEntity.weight, id);
  }

  // ============================================
  // SINTOMAS
  // ============================================
  Future<SyncStatus> saveSymptomReport(SymptomReport report) async {
    final normalized = IdGenerator.isUuid(report.id)
        ? report
        : SymptomReport(
            id: IdGenerator.uuid(),
            date: report.date,
            symptoms: report.symptoms,
            difficulties: report.difficulties,
            notes: report.notes,
          );

    final saved = await _withLock(() async {
      if (!await _local.saveSymptomReport(normalized)) return false;
      await _enqueue(SyncEntity.symptom, normalized.id, SyncAction.upsert);
      return true;
    });
    if (!saved) return SyncStatus.localFailed;

    return _pushAndReport(SyncEntity.symptom, normalized.id);
  }

  // ============================================
  // SINCRONIZAÇÃO COMPLETA
  // ============================================
  /// Envia o que está pendente e depois traz as novidades da nuvem.
  /// Nunca lança exceção: chame sem medo no início das telas.
  Future<void> syncAll() async {
    try {
      await pushPending();
      await pullFromCloud();
    } catch (e) {
      debugPrint('[Sync] syncAll falhou: $e');
    }
  }

  Future<int> pendingCount() async {
    final ops = await _withLock(_local.loadSyncOperations);
    return ops.length;
  }

  // ============================================
  // ENVIO (LOCAL -> NUVEM)
  // ============================================
  Future<void> pushPending() async {
    if (_pushing || !_auth.isLoggedIn) return;
    _pushing = true;

    try {
      final snapshot = await _withLock(_local.loadSyncOperations);
      if (snapshot.isEmpty) return;

      final completed = <String>{};
      final failed = <String, SyncOperation>{};
      var offline = false;

      for (final op in snapshot) {
        if (offline) break; // sem conexão: mantém o resto da fila intacto

        final result = await _execute(op);
        if (result.ok) {
          completed.add(op.opId);
        } else {
          failed[op.opId] = op.copyWith(attempts: op.attempts + 1, lastError: result.error);
          if (result.isNetworkError) offline = true;
        }
      }

      // Reconcilia com a fila atual: itens salvos durante o envio continuam nela.
      await _withLock(() async {
        final current = await _local.loadSyncOperations();
        final next = <SyncOperation>[];
        for (final op in current) {
          if (completed.contains(op.opId)) continue;
          next.add(failed[op.opId] ?? op);
        }
        await _local.saveSyncOperations(next);
      });
    } finally {
      _pushing = false;
    }
  }

  Future<CloudResult<bool>> _execute(SyncOperation op) async {
    switch (op.entity) {
      case SyncEntity.meal:
        if (op.action == SyncAction.delete) return _auth.removeMeal(op.entityId);
        final meal = (await _local.loadMeals()).where((m) => m.id == op.entityId).firstOrNull;
        if (meal == null) return CloudResult<bool>.success(true); // já removido localmente
        return _auth.pushMeal(meal);

      case SyncEntity.weight:
        if (op.action == SyncAction.delete) return _auth.removeWeight(op.entityId);
        final weight = (await _local.loadWeights()).where((w) => w.id == op.entityId).firstOrNull;
        if (weight == null) return CloudResult<bool>.success(true);
        return _auth.pushWeight(weight);

      case SyncEntity.symptom:
        final report = (await _local.loadSymptomReports()).where((r) => r.id == op.entityId).firstOrNull;
        if (report == null) return CloudResult<bool>.success(true);
        return _auth.pushSymptom(report);
    }
  }

  Future<SyncStatus> _pushAndReport(SyncEntity entity, String id) async {
    await pushPending();
    final ops = await _withLock(_local.loadSyncOperations);
    final stillPending = ops.any((o) => o.entity == entity && o.entityId == id);
    return stillPending ? SyncStatus.pending : SyncStatus.synced;
  }

  // ============================================
  // RECEBIMENTO (NUVEM -> LOCAL)
  // ============================================
  Future<void> pullFromCloud({int mealDays = 30}) async {
    if (!_auth.isLoggedIn) return;

    final since = DateTime.now().subtract(Duration(days: mealDays));
    final meals = await _auth.pullMealsSince(since);
    final weights = await _auth.pullWeights();
    final symptoms = await _auth.pullSymptoms();

    await _withLock(() async {
      final ops = await _local.loadSyncOperations();
      Set<String> idsOf(SyncEntity e) => ops.where((o) => o.entity == e).map((o) => o.entityId).toSet();

      if (meals.ok) await _mergeMeals(meals.data ?? [], skip: idsOf(SyncEntity.meal));
      if (weights.ok) {
        final pendingUpserts = ops.where((o) => o.entity == SyncEntity.weight && o.action == SyncAction.upsert).map((o) => o.entityId).toSet();
        final pendingDeletes = ops.where((o) => o.entity == SyncEntity.weight && o.action == SyncAction.delete).map((o) => o.entityId).toSet();
        await _mergeWeights(weights.data ?? [], pendingUpserts: pendingUpserts, pendingDeletes: pendingDeletes);
      }
      if (symptoms.ok) await _mergeSymptoms(symptoms.data ?? [], skip: idsOf(SyncEntity.symptom));
    });
  }

  /// Nuvem vence, exceto para itens com operação pendente (o que o usuário
  /// acabou de fazer neste aparelho tem prioridade).
  Future<void> _mergeMeals(List<Meal> cloud, {required Set<String> skip}) async {
    final byId = {for (final m in await _local.loadMeals()) m.id: m};

    for (final c in cloud) {
      if (skip.contains(c.id)) continue;
      // Cópia local antiga (id não-UUID) da mesma refeição: a versão da nuvem a substitui.
      byId.removeWhere((id, m) =>
          !IdGenerator.isUuid(id) &&
          m.type == c.type &&
          m.dateTime.millisecondsSinceEpoch == c.dateTime.millisecondsSinceEpoch);
      byId[c.id] = c;
    }

    final merged = byId.values.toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    await _local.replaceAllMeals(merged);
  }

  Future<void> _mergeWeights(
    List<WeightEntry> cloud, {
    required Set<String> pendingUpserts,
    required Set<String> pendingDeletes,
  }) async {
    DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
    final local = await _local.loadWeights();
    final byDay = <DateTime, WeightEntry>{};

    for (final w in local) {
      if (!pendingUpserts.contains(w.id)) byDay[day(w.date)] = w;
    }
    for (final c in cloud) {
      if (!pendingDeletes.contains(c.id)) byDay[day(c.date)] = c;
    }
    for (final w in local) {
      if (pendingUpserts.contains(w.id)) byDay[day(w.date)] = w;
    }

    final merged = byDay.values.toList()..sort((a, b) => a.date.compareTo(b.date));
    await _local.replaceAllWeights(merged);
  }

  Future<void> _mergeSymptoms(List<SymptomReport> cloud, {required Set<String> skip}) async {
    final byId = {for (final r in await _local.loadSymptomReports()) r.id: r};

    for (final c in cloud) {
      if (skip.contains(c.id)) continue;
      byId.removeWhere((id, r) =>
          !IdGenerator.isUuid(id) && r.date.millisecondsSinceEpoch == c.date.millisecondsSinceEpoch);
      byId[c.id] = c;
    }

    final merged = byId.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    await _local.replaceAllSymptomReports(merged);
  }

  // ============================================
  // AUXILIARES
  // ============================================
  /// Só chamar dentro de `_withLock`.
  Future<void> _enqueue(SyncEntity entity, String id, SyncAction action) async {
    final ops = await _local.loadSyncOperations();
    final key = '${entity.name}:$id';
    ops.removeWhere((o) => o.key == key); // a operação mais recente substitui a anterior
    ops.add(SyncOperation(
      opId: IdGenerator.uuid(),
      entity: entity,
      entityId: id,
      action: action,
      createdAt: DateTime.now(),
    ));
    await _local.saveSyncOperations(ops);
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}