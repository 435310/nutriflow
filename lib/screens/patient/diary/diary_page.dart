import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/meal.dart';
import '../../../widgets/daily_total_card.dart';
import '../../../widgets/meal_card.dart';

/// ============================================
/// TELA: DIÁRIO ALIMENTAR
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

  // Refeições de exemplo (mock)
  late List<Meal> _meals;

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

    // Mock de refeições
    _meals = _buildMockMeals();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================
  // MOCK DE REFEIÇÕES
  // ============================================
  List<Meal> _buildMockMeals() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      Meal(
        id: '1',
        type: MealType.breakfast,
        dateTime: today.add(const Duration(hours: 7, minutes: 30)),
        foods: const [
          FoodItem(name: 'Pão integral', quantity: 2, unit: 'fatias'),
          FoodItem(name: 'Ovo mexido', quantity: 2, unit: 'unidades'),
          FoodItem(name: 'Café com leite', quantity: 200, unit: 'ml'),
        ],
      ),
      Meal(
        id: '2',
        type: MealType.lunch,
        dateTime: today.add(const Duration(hours: 12, minutes: 30)),
        foods: const [
          FoodItem(name: 'Frango grelhado', quantity: 150, unit: 'g'),
          FoodItem(name: 'Arroz integral', quantity: 100, unit: 'g'),
          FoodItem(name: 'Salada verde', quantity: 1, unit: 'prato'),
          FoodItem(name: 'Azeite', quantity: 1, unit: 'colher'),
        ],
        notes: 'Almoço em casa',
      ),
    ];
  }

  // ============================================
  // REMOVER REFEIÇÃO
  // ============================================
  void _handleDelete(Meal meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir refeição?'),
        content: Text(
          'Deseja realmente excluir "${meal.type.label}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _meals.removeWhere((m) => m.id == meal.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${meal.type.label} excluído'),
                  duration: const Duration(seconds: 2),
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

  // ============================================
  // FORMATAR DATA
  // ============================================
  String _formatDate() {
    final now = DateTime.now();
    const months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return 'Hoje, ${now.day} de ${months[now.month - 1]}';
  }

  // ============================================
  // CALCULAR TOTAL DE CALORIAS
  // ============================================
  double? _getTotalCalories() {
    double total = 0;
    bool hasAny = false;
    for (final meal in _meals) {
      final cal = meal.estimatedCalories;
      if (cal != null) {
        total += cal;
        hasAny = true;
      }
    }
    return hasAny ? total : null;
  }

  @override
  Widget build(BuildContext context) {
    final totalCalories = _getTotalCalories();

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
                // Data
                Text(
                  _formatDate(),
                  style: AppTextStyles.h2,
                ),

                const SizedBox(height: 20),

                // Card de total do dia
                DailyTotalCard(
                  mealCount: _meals.length,
                  totalCalories: totalCalories,
                  goalCalories: null,
                ),

                const SizedBox(height: 28),

                // Título da seção
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

                // Lista de refeições ou estado vazio
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

      // Botão flutuante
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppRoutes.go(context, AppRoutes.registerMeal);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
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