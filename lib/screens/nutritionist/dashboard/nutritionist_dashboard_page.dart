import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/nutritionist_dashboard.dart';
import '../../../widgets/nutritionist_bottom_nav.dart';
import '../../../widgets/patient_list_item.dart';
import '../../../widgets/patient_summary_card.dart';
import '../../../widgets/status_count_chip.dart';
import '../../../widgets/user_avatar.dart';

/// ============================================
/// TELA: DASHBOARD DO NUTRICIONISTA
/// ============================================
class NutritionistDashboardPage extends StatefulWidget {
  const NutritionistDashboardPage({super.key});

  @override
  State<NutritionistDashboardPage> createState() =>
      _NutritionistDashboardPageState();
}

class _NutritionistDashboardPageState
    extends State<NutritionistDashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  int _currentNavIndex = 0;

  final NutritionistDashboard _dashboard = NutritionistDashboard.mock();

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
      _showComingSoon('Lista de pacientes');
    } else if (index == 2) {
      _showComingSoon('Mensagens');
    } else if (index == 3) {
      _showComingSoon('Perfil do nutricionista');
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature em breve'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ============================================
  // SAUDAÇÃO
  // ============================================
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
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
                // ============================================
                // CABEÇALHO
                // ============================================
                _buildHeader(),

                const SizedBox(height: 28),

                // ============================================
                // CARD DE TOTAL DE PACIENTES
                // ============================================
                PatientSummaryCard(
                  total: _dashboard.totalPatients,
                  label: 'Pacientes ativos',
                  onTap: () => _showComingSoon('Lista completa'),
                ),

                const SizedBox(height: 20),

                // ============================================
                // STATUS DOS PACIENTES
                // ============================================
                Text('Status dos pacientes', style: AppTextStyles.h3),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: StatusCountChip(
                        status: PatientStatus.evolving,
                        count: _dashboard.evolvingCount,
                        onTap: () => _showComingSoon('Filtro: Evoluindo'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatusCountChip(
                        status: PatientStatus.attention,
                        count: _dashboard.attentionCount,
                        onTap: () => _showComingSoon('Filtro: Atenção'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatusCountChip(
                        status: PatientStatus.noInteraction,
                        count: _dashboard.noInteractionCount,
                        onTap: () =>
                            _showComingSoon('Filtro: Sem interação'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ============================================
                // PACIENTES RECENTES
                // ============================================
                Row(
                  children: [
                    Text('Atividade recente', style: AppTextStyles.h3),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showComingSoon('Ver todos'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Lista de pacientes
                if (_dashboard.recentPatients.isEmpty)
                  _buildEmptyState()
                else
                  ..._dashboard.recentPatients.map((patient) {
                    return PatientListItem(
                      patient: patient,
                      onTap: () {
                        _showComingSoon('Perfil de ${patient.name}');
                      },
                    );
                  }),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),

      // Botão flutuante
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComingSoon('Novo paciente'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Novo paciente'),
      ),

      // Navegação inferior
      bottomNavigationBar: NutritionistBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
      ),
    );
  }

  // ============================================
  // CABEÇALHO
  // ============================================
  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar
        const UserAvatar(
          name: 'Dra. Ana Costa',
          size: UserAvatarSize.medium,
        ),

        const SizedBox(width: 14),

        // Textos
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()}, Dra. Ana!',
                style: AppTextStyles.h3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Você tem ${_dashboard.totalPatients} pacientes',
                style: AppTextStyles.caption,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Notificações
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
                onPressed: () => _showComingSoon('Notificações'),
              ),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 20),
                child: const Text(
                  '3',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================
  // ESTADO VAZIO
  // ============================================
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.people_outline,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nenhum paciente cadastrado',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Comece adicionando seu primeiro paciente.',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}