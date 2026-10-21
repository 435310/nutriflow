import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/nutritionist_dashboard.dart';
import '../../../services/auth_service.dart';
import '../../../services/local_storage_service.dart';
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

  final _storage = LocalStorageService();
  final _authService = AuthService();
  
  int _currentNavIndex = 0;
  int _unreadMessages = 0;
  String _nutritionistName = 'Nutricionista'; // ⚠️ Nome vindo do banco

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
    _loadUnreadMessages();
    _loadNutritionistName(); // ⚠️ Busca o nome real
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ⚠️ CARREGA O NOME REAL DO SUPABASE
  Future<void> _loadNutritionistName() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;
      
      final response = await Supabase.instance.client
          .from('nutritionist_profiles')
          .select('name')
          .eq('user_id', user.id)
          .maybeSingle();
          
      if (mounted && response != null) {
        setState(() {
          _nutritionistName = response['name'] as String? ?? 'Nutricionista';
        });
      }
    } catch (e) {
      print('Erro ao buscar nome do nutri: $e');
    }
  }

  Future<void> _loadUnreadMessages() async {
    final count = await _storage.countUnreadMessages(forNutritionist: true);
    if (mounted) {
      setState(() {
        _unreadMessages = count;
      });
    }
  }

  Future<void> _handleNavTap(int index) async {
    setState(() {
      _currentNavIndex = index;
    });

    if (index == 1) {
      await Navigator.pushNamed(context, AppRoutes.nutritionistPatients);
      _loadUnreadMessages();
    } else if (index == 2) {
      await Navigator.pushNamed(context, AppRoutes.nutritionistMessages);
      _loadUnreadMessages();
    } else if (index == 3) {
      await Navigator.pushNamed(context, AppRoutes.nutritionistProfile);
      _loadUnreadMessages();
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
                _buildHeader(),

                const SizedBox(height: 28),

                PatientSummaryCard(
                  total: _dashboard.totalPatients,
                  label: 'Pacientes ativos',
                  onTap: () => _showComingSoon('Lista completa'),
                ),

                const SizedBox(height: 20),

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
                        onTap: () => _showComingSoon('Filtro: Sem interação'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Text('Atividade recente', style: AppTextStyles.h3),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _handleNavTap(1);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (_dashboard.recentPatients.isEmpty)
                  _buildEmptyState()
                else
                  ..._dashboard.recentPatients.map((patient) {
                    return PatientListItem(
                      patient: patient,
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          AppRoutes.nutritionistPatientDetail,
                        );
                        _loadUnreadMessages();
                      },
                    );
                  }),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComingSoon('Novo paciente'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Novo paciente'),
      ),

      bottomNavigationBar: NutritionistBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
        unreadCount: _unreadMessages,
      ),
    );
  }

  Widget _buildHeader() {
    // Remove o prefixo "Dra." se o nome já começar com ele
    final displayName = _nutritionistName.startsWith('Dra.') || _nutritionistName.startsWith('Dr.')
        ? _nutritionistName
        : 'Dra. $_nutritionistName';

    return Row(
      children: [
        // Avatar com o nome real
        UserAvatar(
          name: _nutritionistName,
          size: UserAvatarSize.medium,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()}, $displayName!',
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