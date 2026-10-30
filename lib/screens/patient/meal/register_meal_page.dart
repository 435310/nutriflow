import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/meal.dart';
import '../../../services/auth_service.dart';
import '../../../services/local_storage_service.dart'; // NOVO IMPORT
import '../../../widgets/food_item_field.dart';
import '../../../widgets/meal_type_selector.dart';

/// ============================================
/// TELA: REGISTRAR REFEIÇÃO (com Foto e TACO)
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

  final _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _imageBytes;

  final _authService = AuthService();
  final _localStorage = LocalStorageService(); // Instância do banco local

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ============================================
  // ESCOLHER FOTO
  // ============================================
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      print('Erro ao escolher imagem: $e');
      _showSnackBar('Erro ao escolher imagem', isError: true);
    }
  }

  // ============================================
  // ABRIR MODAL DE BUSCA TACO
  // ============================================
  Future<void> _addFood() async {
    final result = await showModalBottomSheet<FoodItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddFoodModal(authService: _authService),
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
  // SALVAR REFEIÇÃO (LOCAL E NUVEM) - CORRIGIDO
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

    String? photoPath;

    // 1. Tenta enviar a foto (se houver)
    if (_selectedImage != null && _imageBytes != null) {
      photoPath = await _authService.uploadMealPhoto(_imageBytes!, _selectedImage!.name);
      
      if (photoPath == null) {
        setState(() => _isSaving = false);
        _showSnackBar('Erro ao enviar a foto. Tente novamente.', isError: true);
        return;
      }
    }

    // 2. Monta o objeto da refeição
    final meal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType!,
      dateTime: _selectedDateTime,
      foods: List.from(_foods),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      photoPath: photoPath,
    );

    // 3. SALVA NO BANCO LOCAL (Garante que não perde os dados)
    await _localStorage.saveMeal(meal);

    // 4. TENTA SALVAR NA NUVEM (Supabase)
    final error = await _authService.saveMealToCloud(meal);

    if (!mounted) return;
    setState(() => _isSaving = false);

    // 5. Verifica o resultado e fecha a tela avisando o Dashboard
    if (error == null) {
      _showSnackBar('${meal.type.label} salvo com sucesso!');
    } else {
      print('AVISO: Salvo no celular, mas erro na nuvem: $error');
      _showSnackBar('Salvo no celular! (Erro na nuvem)', isError: true);
    }

    // ⚠️ AQUI ESTÁ O SEGREDO: Retorna 'true' para avisar o Dashboard
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context, true); // Passa 'true' de volta
      }
    });
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
          onPressed: () => Navigator.pop(context), // Simples, para não dar conflito
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(icon: Icons.restaurant_menu, title: 'Tipo de refeição'),
              const SizedBox(height: 16),
              MealTypeSelector(
                selected: _selectedType,
                onChanged: (type) => setState(() => _selectedType = type),
              ),
              const SizedBox(height: 32),

              const _SectionTitle(icon: Icons.access_time, title: 'Horário'),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Text(_formatTime(_selectedDateTime), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  const Expanded(child: _SectionTitle(icon: Icons.restaurant, title: 'Alimentos')),
                  TextButton.icon(
                    onPressed: _addFood,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
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
                      Icon(Icons.restaurant_outlined, size: 36, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 8),
                      Text('Nenhum alimento adicionado', style: AppTextStyles.caption, textAlign: TextAlign.center),
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

              const _SectionTitle(icon: Icons.camera_alt_outlined, title: 'Foto da refeição (opcional)'),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: AppColors.primary),
                            const SizedBox(height: 8),
                            Text('Toque para adicionar uma foto', style: AppTextStyles.caption),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),

              const _SectionTitle(icon: Icons.notes_outlined, title: 'Observações (opcional)'),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Como você se sentiu? Alguma observação?'),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check),
                label: Text(_isSaving ? 'Salvando...' : 'Salvar refeição'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
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

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.h3),
      ],
    );
  }
}

// ============================================
// MODAL: BUSCAR ALIMENTOS NA TACO
// ============================================
class _AddFoodModal extends StatefulWidget {
  final AuthService authService;

  const _AddFoodModal({required this.authService});

  @override
  State<_AddFoodModal> createState() => _AddFoodModalState();
}

class _AddFoodModalState extends State<_AddFoodModal> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController(text: '100');
  
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedFood;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Buscar alimentos na TACO
  Future<void> _searchFoods(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    final results = await widget.authService.searchFoods(query);
    
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  // Selecionar um alimento da lista
  void _selectFood(Map<String, dynamic> food) {
    setState(() {
      _selectedFood = food;
      _searchResults = [];
      _searchController.text = food['name'];
    });
  }

  // Calcular e adicionar o alimento
  void _handleAdd() {
    if (_selectedFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um alimento da lista'), backgroundColor: AppColors.error),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text.replaceAll(',', '.'));
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida'), backgroundColor: AppColors.error),
      );
      return;
    }

    // Calcula as calorias com base na quantidade (TACO é por 100g)
    final caloriesPer100g = (_selectedFood!['calories_per_100g'] as num?)?.toDouble() ?? 0;
    final calculatedCalories = (caloriesPer100g / 100) * quantity;

    Navigator.pop(
      context,
      FoodItem(
        name: _selectedFood!['name'],
        quantity: quantity,
        unit: 'g',
        calories: calculatedCalories,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24 + bottomInset),
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Adicionar alimento', style: AppTextStyles.h2),
          const SizedBox(height: 24),
          
          // Campo de busca
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Buscar alimento (TACO)',
              hintText: 'Ex: Arroz, Feijão, Frango...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching 
                  ? const SizedBox(width: 20, height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                  : null,
            ),
            onChanged: _searchFoods,
          ),
          
          // Lista de resultados
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final food = _searchResults[index];
                  return ListTile(
                    tileColor: Colors.transparent,
                    title: Text(food['name'], style: AppTextStyles.body),
                    subtitle: Text(
                      '${(food['calories_per_100g'] as num?)?.toStringAsFixed(0) ?? 0} kcal / 100g',
                      style: AppTextStyles.caption,
                    ),
                    onTap: () => _selectFood(food),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),
          
          // Campo de quantidade
          TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Quantidade (g)',
              prefixIcon: Icon(Icons.numbers),
            ),
          ),

          const SizedBox(height: 24),
          
          // Botões
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