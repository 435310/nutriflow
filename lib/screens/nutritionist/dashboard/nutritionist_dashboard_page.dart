import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/nutritionist_dashboard.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/nutritionist_bottom_nav.dart';
import '../../../widgets/patient_list_item.dart';
import '../../../widgets/patient_summary_card.dart';
import '../../../widgets/status_count_chip.dart';
import '../../../widgets/user_avatar.dart';

/// ============================================
/// TELA: DASHBOARD DO NUTRICIONISTA (Nuvem)
/// ============================================
class NutritionistDashboardPage extends StatefulWidget {
  const NutritionistDashboardPage({super.key});

  @override
  State<NutritionistDashboardPage> createState() =>
      _NutritionistDashboardPageState();
}

class _NutritionistDashboardPageState extends State<NutritionistDashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final _authService = AuthService();
  
  int _currentNavIndex = 0;
  int _unreadMessages = 0;
  String _nutritionistName = 'Nutricionista';
  
  int _totalPatients = 0;
  List<PatientSummary> _recentPatients = [];
  bool _isLoading = true;

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
    _loadDashboardData();
    _loadUnreadMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUnreadMessages() async {
    final count = await _authService.countUnreadMessagesFromCloud(forNutritionist: true);
    if (mounted) {
      setState(() {
        _unreadMessages = count;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final nutriProfile = await Supabase.instance.client
            .from('nutritionist_profiles')
            .select('name')
            .eq('user_id', user.id)
            .maybeSingle();
        if (nutriProfile != null) {
          _nutritionistName = nutriProfile['name'] as String? ?? 'Nutricionista';
        }
      }

      final patientsData = await _authService.getAllPatients();
      _totalPatients = patientsData.length;
      
      _recentPatients = patientsData.take(5).map((p) {
        return PatientSummary(
          id: p['id'] as String,
          name: p['name'] as String? ?? 'Sem nome',
          status: PatientStatus.evolving,
          lastActivity: 'Cadastrado recentemente',
          lastActivityTime: DateTime.parse(p['created_at'] as String),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar dashboard: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleNavTap(int index) async {
    setState(() {
      _currentNavIndex = index;
    });

    if (index == 1) {
      await Navigator.pushNamed(context, AppRoutes.nutritionistPatients);
    } else if (index == 2) {
      // ⚠️ Vai para Mensagens e espera o retorno
      await Navigator.pushNamed(context, AppRoutes.nutritionistMessages);
    } else if (index == 3) {
      await Navigator.pushNamed(context, AppRoutes.nutritionistProfile);
    }

    // ⚠️ Atualiza o badge SEMPRE que voltar de qualquer aba
    _loadUnreadMessages();
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

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
                  total: _totalPatients,
                  label: 'Pacientes ativos',
                  onTap: () => _handleNavTap(1),
                ),

                const SizedBox(height: 20),

                Text('Status dos pacientes', style: AppTextStyles.h3),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: StatusCountChip(
                        status: PatientStatus.evolving,
                        count: _totalPatients,
                        onTap: () => _handleNavTap(1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatusCountChip(
                        status: PatientStatus.attention,
                        count: 0,
                        onTap: () => _showComingSoon('Filtro: Atenção'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatusCountChip(
                        status: PatientStatus.noInteraction,
                        count: 0,
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
                      onPressed: () => _handleNavTap(1),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (_recentPatients.isEmpty)
                  _buildEmptyState()
                else
                  ..._recentPatients.map((patient) {
                    return PatientListItem(
                      patient: patient,
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          AppRoutes.nutritionistPatientDetail,
                          arguments: patient.id,
                        );
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
    final displayName = _nutritionistName.startsWith('Dra.') || _nutritionistName.startsWith('Dr.')
        ? _nutritionistName
        : 'Dra. $_nutritionistName';

    return Row(
      children: [
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
                'Você tem $_totalPatients pacientes',
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