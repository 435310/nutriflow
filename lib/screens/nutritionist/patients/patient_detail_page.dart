import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/anamnesis.dart';
import '../../../models/meal.dart';
import '../../../models/weight_entry.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/mini_weight_chart.dart';
import '../../../widgets/patient_detail_section.dart';
import '../../../widgets/user_avatar.dart';

/// ============================================
/// TELA: PERFIL DO PACIENTE (visão do nutricionista)
/// ============================================
class PatientDetailPage extends StatefulWidget {
  const PatientDetailPage({super.key});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final _authService = AuthService();
  
  String? _patientId;
  Map<String, dynamic>? _profile;
  Anamnesis? _anamnesis;
  List<WeightEntry> _weightHistory = [];
  List<Meal> _recentMeals = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String && _patientId == null) {
      _patientId = args;
      _initController();
      _loadData();
    }
  }

  void _initController() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_patientId == null) return;

    try {
      final profileResponse = await Supabase.instance.client
          .from('patient_profiles')
          .select()
          .eq('id', _patientId!)
          .maybeSingle();

      final weights = await _authService.getPatientWeights(_patientId!);
      final meals = await _authService.getPatientMeals(_patientId!);
      final anamnesis = await _authService.getAnamnesis(_patientId!);

      if (!mounted) return;

      setState(() {
        _profile = profileResponse;
        _weightHistory = weights;
        _recentMeals = meals;
        _anamnesis = anamnesis;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados do paciente: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMealDetails(Meal meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(meal.type.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meal.type.label, style: AppTextStyles.h2),
                        Text('${meal.dateTime.hour.toString().padLeft(2, '0')}:${meal.dateTime.minute.toString().padLeft(2, '0')}', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Alimentos', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              ...meal.foods.map((food) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(food.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500))),
                      Text('${food.quantity.toStringAsFixed(food.quantity.truncate() == food.quantity ? 0 : 1)} ${food.unit}', style: AppTextStyles.caption),
                    ],
                  ),
                ),
              )),
              if (meal.notes != null && meal.notes!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Observações', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(meal.notes!, style: AppTextStyles.bodySecondary.copyWith(fontStyle: FontStyle.italic)),
              ],
              if (meal.photoPath != null) ...[
                const SizedBox(height: 20),
                Text('Foto', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                FutureBuilder<String?>(
                  future: _authService.getMealPhotoUrl(meal.photoPath!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          snapshot.data!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 200,
                        ),
                      );
                    }
                    return const Text('Não foi possível carregar a foto.');
                  },
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Paciente')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Paciente')),
        body: const Center(child: Text('Paciente não encontrado')),
      );
    }

    final name = _profile!['name'] ?? 'Sem nome';
    final email = _profile!['email'] ?? 'Sem e-mail';

    double? currentWeight = _weightHistory.isNotEmpty ? _weightHistory.last.weightKg : null;
    double? initialWeight = _weightHistory.isNotEmpty ? _weightHistory.first.weightKg : null;
    double? delta = (currentWeight != null && initialWeight != null) ? currentWeight - initialWeight : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(name),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => AppRoutes.back(context)),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                UserAvatar(name: name, size: UserAvatarSize.large),
                const SizedBox(height: 16),
                Text(name, style: AppTextStyles.h2, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(email, style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
                const SizedBox(height: 28),

                PatientDetailSection(
                  icon: Icons.insights_outlined,
                  title: 'Resumo',
                  child: Column(
                    children: [
                      _buildInfoRow('Peso atual', currentWeight != null ? '${currentWeight.toStringAsFixed(1)} kg' : 'Não registrado'),
                      _buildInfoRow('Variação', delta != null ? '${delta < 0 ? '▼' : '▲'} ${delta.abs().toStringAsFixed(1)} kg' : '—', valueColor: delta == null ? null : delta < 0 ? AppColors.success : AppColors.warning),
                      _buildInfoRow('Peso inicial', initialWeight != null ? '${initialWeight.toStringAsFixed(1)} kg' : 'Não registrado'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                PatientDetailSection(
                  icon: Icons.show_chart,
                  title: 'Evolução de peso',
                  child: Column(
                    children: [
                      MiniWeightChart(entries: _weightHistory, height: 70),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('${_weightHistory.length} registros', style: AppTextStyles.caption),
                          const Spacer(),
                          Text('Últimos 90 dias', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                PatientDetailSection(
                  icon: Icons.restaurant_menu,
                  title: 'Últimas refeições',
                  child: _recentMeals.isEmpty
                      ? _buildEmptyInfo('Nenhuma refeição registrada')
                      : Column(
                          children: _recentMeals.map((meal) {
                            return InkWell(
                              onTap: () => _showMealDetails(meal),
                              borderRadius: BorderRadius.circular(10),
                              child: _buildMealRow(meal),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 16),

                // ⚠️ ANAMNESE
                PatientDetailSection(
                  icon: Icons.assignment_outlined,
                  title: 'Anamnese (Primeira Consulta)',
                  child: _anamnesis == null
                      ? _buildEmptyInfo('Anamnese não preenchida pelo paciente')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_anamnesis!.mainGoal != null) _buildAnamnesisItem('Objetivo', _anamnesis!.mainGoal!),
                            if (_anamnesis!.healthConditions != null) _buildAnamnesisItem('Condições de saúde', _anamnesis!.healthConditions!),
                            if (_anamnesis!.medications != null) _buildAnamnesisItem('Medicamentos', _anamnesis!.medications!),
                            if (_anamnesis!.supplements != null) _buildAnamnesisItem('Suplementos', _anamnesis!.supplements!),
                            if (_anamnesis!.bowelHabits != null) _buildAnamnesisItem('Intestino', _anamnesis!.bowelHabits!),
                            if (_anamnesis!.sleepQuality != null) _buildAnamnesisItem('Sono', _anamnesis!.sleepQuality!),
                            if (_anamnesis!.waterIntake != null) _buildAnamnesisItem('Água/dia', _anamnesis!.waterIntake!),
                            if (_anamnesis!.alcoholConsumption != null) _buildAnamnesisItem('Álcool', _anamnesis!.alcoholConsumption!),
                            if (_anamnesis!.smoking != null) _buildAnamnesisItem('Tabagismo', _anamnesis!.smoking!),
                            if (_anamnesis!.physicalActivity != null) _buildAnamnesisItem('Atividade física', _anamnesis!.physicalActivity!),
                            if (_anamnesis!.foodAllergies != null) _buildAnamnesisItem('Alergias alimentares', _anamnesis!.foodAllergies!),
                            if (_anamnesis!.foodIntolerances != null) _buildAnamnesisItem('Intolerâncias', _anamnesis!.foodIntolerances!),
                            if (_anamnesis!.dietaryPreferences != null) _buildAnamnesisItem('Preferências', _anamnesis!.dietaryPreferences!),
                          ],
                        ),
                ),

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.nutritionistChat),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Enviar mensagem'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: AppTextStyles.caption)),
          Expanded(child: Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: valueColor ?? AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _buildMealRow(Meal meal) {
    final time = '${meal.dateTime.hour.toString().padLeft(2, '0')}:${meal.dateTime.minute.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Text(meal.type.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.type.label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                Text('${meal.foods.length} alimento${meal.foods.length > 1 ? 's' : ''}', style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(time, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildAnamnesisItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: AppTextStyles.caption)),
          Expanded(child: Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildEmptyInfo(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text, style: AppTextStyles.caption, textAlign: TextAlign.center),
    );
  }
}