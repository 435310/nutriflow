import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/meal.dart';
import '../../../services/auth_service.dart'; // ADICIONADO
import '../../../services/local_storage_service.dart';
import '../../../services/sync_service.dart';
import '../../../widgets/meal_card.dart';

/// ============================================
/// TELA: DIÁRIO ALIMENTAR (Offline-First)
/// ============================================
class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final _authService = AuthService(); // ADICIONADO (estava faltando no original)
  final _localStorage = LocalStorageService();
  final _syncService = SyncService();
  
  bool _isSyncing = false;
  List<Meal> _meals = [];
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
    _loadMeals();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================
  // CARREGAR REFEIÇÕES (local na hora, nuvem em segundo plano)
  // ============================================
  Future<void> _loadMeals() async {
    await _loadFromLocal();
    _syncInBackground();
  }

  Future<void> _loadFromLocal() async {
    try {
      final meals = await _localStorage.loadMealsByDate(DateTime.now());
      if (!mounted) return;
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar refeições locais: $e');
      if (!mounted) return;
      setState(() {
        _meals = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _syncInBackground() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await _syncService.syncAll();
      if (!mounted) return;
      await _loadFromLocal(); // Atualiza a tela depois de sincronizar
    } catch (e) {
      debugPrint('Erro ao sincronizar diário: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // ============================================
  // REMOVER REFEIÇÃO (Ainda não implementado no Supabase)
  // ============================================
  void _handleDelete(Meal meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir refeição?'),
        content: Text('Deseja realmente excluir "${meal.type.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implementar delete no Supabase (via SyncService)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exclusão em breve (precisa de permissão no banco)'),
                  backgroundColor: AppColors.warning,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    const months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return 'Hoje, ${now.day} de ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Diário alimentar'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => AppRoutes.back(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Diário alimentar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.back(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(), style: AppTextStyles.h2),
                const SizedBox(height: 20),

                // Card total do dia
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total do dia',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_meals.length} refeição${_meals.length != 1 ? 'ões' : ''} registrada${_meals.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Text('Refeições', style: AppTextStyles.h3),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_meals.length}',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (_meals.isEmpty)
                  _buildEmptyState()
                else
                  ..._meals.map((meal) {
                    return MealCard(
                      meal: meal,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Detalhes de ${meal.type.label} em breve'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      onDelete: () => _handleDelete(meal),
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
          await Navigator.pushNamed(context, AppRoutes.registerMeal);
          _loadMeals(); // Recarrega ao voltar
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
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
              Icons.restaurant_menu,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nenhuma refeição registrada',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Comece a registrar suas refeições\ne acompanhe sua alimentação.',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}