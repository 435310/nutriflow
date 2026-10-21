import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/meal.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/food_item_field.dart';
import '../../../widgets/meal_type_selector.dart';

/// ============================================
/// TELA: REGISTRAR REFEIÇÃO (Integrada ao Supabase)
/// ============================================
class RegisterMealPage extends StatefulWidget {
  const RegisterMealPage({super.key});

  @override
  State<RegisterMealPage> createState() => _RegisterMealPageState();
}

class _RegisterMealPageState extends State<RegisterMealPage> {
  MealType? _selectedType;
  final List<FoodItem> _foods = [];
  final _notesController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ============================================
  // MODAL ADICIONAR ALIMENTO
  // ============================================
  Future<void> _addFood() async {
    final result = await showModalBottomSheet<FoodItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddFoodModal(),
    );

    if (result != null) {
      setState(() => _foods.add(result));
    }
  }

  void _removeFood(int index) {
    setState(() => _foods.removeAt(index));
  }

  // ============================================
  // ESCOLHER HORÁRIO
  // ============================================
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  // ============================================
  // SALVAR NO SUPABASE
  // ============================================
  Future<void> _handleSave() async {
    if (_selectedType == null) {
      _showSnackBar('Escolha o tipo de refeição', isError: true);
      return;
    }

    if (_foods.isEmpty) {
      _showSnackBar('Adicione pelo menos um alimento', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final meal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType!,
      dateTime: _selectedDateTime,
      foods: List.from(_foods),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    // Salva no Supabase
    final authService = AuthService();
    final error = await authService.saveMealToCloud(meal);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (error == null) {
      _showSnackBar('${meal.type.label} salvo com sucesso!');
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) AppRoutes.back(context);
      });
    } else {
      _showSnackBar(error, isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar refeição'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.back(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.restaurant_menu,
                title: 'Tipo de refeição',
              ),
              const SizedBox(height: 16),
              MealTypeSelector(
                selected: _selectedType,
                onChanged: (type) => setState(() => _selectedType = type),
              ),
              const SizedBox(height: 32),

              const _SectionTitle(
                icon: Icons.access_time,
                title: 'Horário',
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatTime(_selectedDateTime),
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  const Expanded(
                    child: _SectionTitle(
                      icon: Icons.restaurant,
                      title: 'Alimentos',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addFood,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_foods.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_outlined,
                        size: 36,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhum alimento adicionado',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ..._foods.asMap().entries.map((entry) {
                  return FoodItemField(
                    food: entry.value,
                    onRemove: () => _removeFood(entry.key),
                  );
                }),
              const SizedBox(height: 32),

              const _SectionTitle(
                icon: Icons.notes_outlined,
                title: 'Observações (opcional)',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Como você se sentiu? Alguma observação?',
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_isSaving ? 'Salvando...' : 'Salvar refeição'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isSaving ? null : () => AppRoutes.back(context),
                child: const Text('Cancelar'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// WIDGET: TÍTULO DE SEÇÃO
// ============================================
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.h3),
      ],
    );
  }
}

// ============================================
// MODAL: ADICIONAR ALIMENTO
// ============================================
class _AddFoodModal extends StatefulWidget {
  const _AddFoodModal();

  @override
  State<_AddFoodModal> createState() => _AddFoodModalState();
}

class _AddFoodModalState extends State<_AddFoodModal> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '100');
  String _selectedUnit = 'g';

  static const List<String> _units = ['g', 'ml', 'unidade', 'colher', 'prato'];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    final name = _nameController.text.trim();
    final quantity =
        double.tryParse(_quantityController.text.replaceAll(',', '.'));

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Informe o nome do alimento'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Informe uma quantidade válida'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      FoodItem(
        name: name,
        quantity: quantity,
        unit: _selectedUnit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Adicionar alimento', style: AppTextStyles.h2),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome do alimento',
              hintText: 'Ex: Frango grelhado',
              prefixIcon: Icon(Icons.restaurant),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: const InputDecoration(labelText: 'Unidade'),
                  items: _units.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedUnit = value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleAdd,
                  child: const Text('Adicionar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}