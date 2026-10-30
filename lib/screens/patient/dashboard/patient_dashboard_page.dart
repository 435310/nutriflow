import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/patient_profile.dart';
import '../../../models/symptom_report.dart';
import '../../../models/weight_entry.dart';
import '../../../services/auth_service.dart';
import '../../../services/local_storage_service.dart'; // NOVO IMPORT
import '../../../screens/patient/meal/register_meal_page.dart'; // NOVO IMPORT
import '../../../widgets/evolution_card.dart';
import '../../../widgets/greeting_header.dart';
import '../../../widgets/meals_today_card.dart';
import '../../../widgets/next_meal_card.dart';
import '../../../widgets/patient_bottom_nav.dart';
import '../../../widgets/symptom_card.dart';

/// ============================================
/// TELA: DASHBOARD DO PACIENTE
/// ============================================
class PatientDashboardPage extends StatefulWidget {
  const PatientDashboardPage({super.key});

  @override
  State<PatientDashboardPage> createState() => _PatientDashboardPageState();
}

class _PatientDashboardPageState extends State<PatientDashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  int _currentNavIndex = 0;
  final _authService = AuthService();
  final _localStorage = LocalStorageService(); // Instância do banco local
  
  PatientProfile? _profile;
  int _mealsTodayCount = 0;
  SymptomReport? _latestSymptom;
  double? _currentWeight;
  double? _initialWeight;
  double? _goalWeight;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Tenta buscar do Supabase
      final cloudProfile = await _authService.getPatientProfile();
      final cloudMeals = await _authService.getMealsFromCloud(date: DateTime.now());
      final cloudWeights = await _authService.getWeightsFromCloud();
      final cloudSymptom = await _authService.getLatestSymptomFromCloud();

      // PLANO B: Busca do armazenamento local se a nuvem falhar ou vier vazio
      final localMeals = await _localStorage.loadMealsByDate(DateTime.now());
      final localWeights = await _localStorage.loadWeights();
      final localSymptom = await _localStorage.loadLatestSymptomReport();

      if (!mounted) return;

      setState(() {
        if (cloudProfile != null) {
          _profile = PatientProfile.mock().copyWith(
            name: cloudProfile['name'] as String?,
            email: cloudProfile['email'] as String?,
          );
        } else {
          _profile = PatientProfile.mock();
        }

        // Se a nuvem retornar 0 refeições, usa as do celular
        _mealsTodayCount = cloudMeals.isNotEmpty ? cloudMeals.length : localMeals.length;
        
        // Sintomas
        _latestSymptom = cloudSymptom ?? localSymptom;

        // Pesos
        final weightsToUse = cloudWeights.isNotEmpty ? cloudWeights : localWeights;
        if (weightsToUse.isNotEmpty) {
          final sorted = List<WeightEntry>.from(weightsToUse)..sort((a, b) => a.date.compareTo(b.date));
          _initialWeight = sorted.first.weightKg;
          _currentWeight = sorted.last.weightKg;
        } else {
          _initialWeight = null;
          _currentWeight = null;
        }
        _goalWeight = 65.0;

        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dashboard: $e');
      if (!mounted) return;
      setState(() {
        _profile = PatientProfile.mock();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleNavTap(int index) async {
    setState(() => _currentNavIndex = index);
    if (index == 1) {
      await Navigator.pushNamed(context, AppRoutes.diary);
    } else if (index == 2) {
      await Navigator.pushNamed(context, AppRoutes.evolution);
    } else if (index == 3) {
      await Navigator.pushNamed(context, AppRoutes.profile);
    }
    if (mounted) _loadData();
  }

  // ============================================
  // NOVA FUNÇÃO: ABRIR TELA DE REGISTRO DIRETO
  // ============================================
  Future<void> _openRegisterMeal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterMealPage()),
    );

    // Se salvou, recarrega os dados na tela
    if (result == true && mounted) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final profile = _profile!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeIn,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GreetingHeader(
                  name: profile.name,
                  notificationCount: 2,
                  onNotificationTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notificações em breve')));
                  },
                ),

                const SizedBox(height: 28),

                EvolutionCard(
                  currentWeight: _currentWeight ?? 0,
                  initialWeight: _initialWeight,
                  goalWeight: _goalWeight,
                  onTap: () async {
                    await Navigator.pushNamed(context, AppRoutes.evolution);
                    if (mounted) _loadData();
                  },
                ),

                const SizedBox(height: 16),

                MealsTodayCard(
                  registered: _mealsTodayCount,
                  total: 5,
                  onTap: () async {
                    await Navigator.pushNamed(context, AppRoutes.diary);
                    if (mounted) _loadData();
                  },
                ),

                const SizedBox(height: 16),

                SymptomCard(
                  latestReport: _latestSymptom,
                  onTap: () async {
                    await Navigator.pushNamed(context, AppRoutes.reportSymptoms);
                    if (mounted) _loadData();
                  },
                ),

                const SizedBox(height: 16),

                // ATALHO PARA A ANAMNESE
                InkWell(
                  onTap: () async {
                    await Navigator.pushNamed(context, AppRoutes.fillAnamnesis);
                    if (mounted) _loadData();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Questionário de Anamnese',
                                style: AppTextStyles.h3.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Responda para que seu nutricionista te conheça.',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const NextMealCard(
                  mealName: 'Almoço',
                  mealTime: '12:30',
                  description: 'Frango grelhado, arroz integral, salada verde e azeite',
                  icon: Icons.lunch_dining_outlined,
                  color: AppColors.secondary,
                ),

                const SizedBox(height: 16),

                // Atalho para o Chat
                InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.patientChat),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.secondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Falar com a Nutricionista',
                                style: AppTextStyles.h3.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tire dúvidas sobre o seu plano',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const _TipsSection(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openRegisterMeal, // <--- MUDANÇA AQUI: Chama a nova função
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: PatientBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
      ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  const _TipsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('Dica do dia', style: AppTextStyles.h3),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.secondary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('💡', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Beba pelo menos 2 litros de água por dia. '
                  'A hidratação ajuda no funcionamento do metabolismo.',
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}