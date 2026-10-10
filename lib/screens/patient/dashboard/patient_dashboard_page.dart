import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/patient_profile.dart';
import '../../../widgets/evolution_card.dart';
import '../../../widgets/greeting_header.dart';
import '../../../widgets/meals_today_card.dart';
import '../../../widgets/next_meal_card.dart';
import '../../../widgets/patient_bottom_nav.dart';

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

  final PatientProfile _profile = PatientProfile.mock();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diário alimentar em breve'),
          duration: Duration(seconds: 1),
        ),
      );
    } else if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evolução detalhada em breve'),
          duration: Duration(seconds: 1),
        ),
      );
    } else if (index == 3) {
      AppRoutes.go(context, AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                // Cabeçalho
                GreetingHeader(
                  name: _profile.name,
                  notificationCount: 2,
                  onNotificationTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notificações em breve'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Card de Evolução
                EvolutionCard(
                  currentWeight: _profile.currentWeightKg ?? 0,
                  initialWeight: _profile.initialWeightKg,
                  goalWeight: _profile.goalWeightKg,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Evolução detalhada em breve'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Card de Refeições
                MealsTodayCard(
                  registered: 2,
                  total: 5,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Diário alimentar em breve'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Card de Próxima refeição
                const NextMealCard(
                  mealName: 'Almoço',
                  mealTime: '12:30',
                  description:
                      'Frango grelhado, arroz integral, salada verde e azeite',
                  icon: Icons.lunch_dining_outlined,
                  color: AppColors.secondary,
                ),

                const SizedBox(height: 16),

                // Dica do dia
                const _TipsSection(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),

      // Botão flutuante
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRoutes.go(context, AppRoutes.registerMeal);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),

      // Navegação inferior
      bottomNavigationBar: PatientBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
      ),
    );
  }
}

// ============================================
// WIDGET: SEÇÃO DE DICAS
// ============================================
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