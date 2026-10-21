import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/patient_profile.dart';
import '../../../models/weight_entry.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/stats_card.dart';
import '../../../widgets/weight_chart.dart';
import '../../../widgets/weight_history_item.dart';

/// ============================================
/// TELA: EVOLUÇÃO (Integrada ao Supabase)
/// ============================================
class EvolutionPage extends StatefulWidget {
  const EvolutionPage({super.key});

  @override
  State<EvolutionPage> createState() => _EvolutionPageState();
}

class _EvolutionPageState extends State<EvolutionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final PatientProfile _profile = PatientProfile.mock();
  final _authService = AuthService();

  List<WeightEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    _loadEntries();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await _authService.getWeightsFromCloud();
      if (!mounted) return;
      setState(() {
        _entries = entries ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar pesos: $e');
      if (!mounted) return;
      setState(() {
        _entries = [];
        _isLoading = false;
      });
    }
  }

  void _handleDelete(WeightEntry entry) {
    // Implementação futura
  }

  WeightEntry? get _latest {
    if (_entries.isEmpty) return null;
    final sorted = List<WeightEntry>.from(_entries)..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first;
  }

  double? get _initialWeight {
    if (_entries.isEmpty) return null;
    final sorted = List<WeightEntry>.from(_entries)..sort((a, b) => a.date.compareTo(b.date));
    return sorted.first.weightKg;
  }

  double? get _currentWeight => _latest?.weightKg;

  double? get _totalDelta {
    if (_initialWeight == null || _currentWeight == null) return null;
    return _currentWeight! - _initialWeight!;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Evolução'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => AppRoutes.back(context)),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final sortedDesc = List<WeightEntry>.from(_entries)..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Evolução'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => AppRoutes.back(context)),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChartCard(),
                const SizedBox(height: 16),
                if (_entries.isNotEmpty)
                  StatsCard(
                    items: [
                      StatItem(label: 'Peso inicial', value: _initialWeight != null ? '${_initialWeight!.toStringAsFixed(1)} kg' : '—', icon: Icons.flag_outlined),
                      StatItem(label: 'Peso atual', value: _currentWeight != null ? '${_currentWeight!.toStringAsFixed(1)} kg' : '—', icon: Icons.monitor_weight_outlined),
                      StatItem(
                        label: 'Variação',
                        value: _totalDelta != null ? '${_totalDelta! < 0 ? '▼' : '▲'} ${_totalDelta!.abs().toStringAsFixed(1)} kg' : '—',
                        icon: _totalDelta != null && _totalDelta! < 0 ? Icons.trending_down : Icons.trending_up,
                        color: _totalDelta == null ? null : _totalDelta! < 0 ? AppColors.success : AppColors.warning,
                      ),
                      StatItem(label: 'IMC', value: _profile.bmi != null ? _profile.bmi!.toStringAsFixed(1) : '—', icon: Icons.calculate_outlined),
                    ],
                  ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text('Histórico', style: AppTextStyles.h3),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                      child: Text('${_entries.length}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_entries.isEmpty)
                  _buildEmptyState()
                else
                  ...sortedDesc.asMap().entries.map((entry) {
                    final index = entry.key;
                    final weightEntry = entry.value;
                    final previousWeight = index < sortedDesc.length - 1 ? sortedDesc[index + 1].weightKg : null;
                    return WeightHistoryItem(
                      entry: weightEntry,
                      previousWeight: previousWeight,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Detalhes de ${weightEntry.formattedDate} em breve'), duration: const Duration(seconds: 1)));
                      },
                      onDelete: () => _handleDelete(weightEntry),
                    );
                  }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.registerWeight);
          _loadEntries();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Registrar peso'),
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36, width: 36,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.show_chart, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Evolução do peso', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_currentWeight != null) ...[
                Text(_currentWeight!.toStringAsFixed(1), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1)),
                const SizedBox(width: 4),
                Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('kg', style: AppTextStyles.bodySecondary.copyWith(fontSize: 16))),
              ] else
                Text('Sem dados', style: AppTextStyles.bodySecondary),
              const Spacer(),
              if (_totalDelta != null && _totalDelta != 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (_totalDelta! < 0 ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_totalDelta! < 0 ? Icons.trending_down : Icons.trending_up, size: 16, color: _totalDelta! < 0 ? AppColors.success : AppColors.warning),
                      const SizedBox(width: 4),
                      Text('${_totalDelta! < 0 ? '▼' : '▲'} ${_totalDelta!.abs().toStringAsFixed(1)} kg', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _totalDelta! < 0 ? AppColors.success : AppColors.warning)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          WeightChart(entries: _entries, goalWeight: _profile.goalWeightKg),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Container(
            height: 72, width: 72,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.show_chart, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('Nenhum registro ainda', style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Registre seu peso regularmente\npara acompanhar sua evolução.', style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}