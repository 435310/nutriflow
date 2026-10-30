import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/anamnesis.dart';
import '../../../services/auth_service.dart';

/// ============================================
/// TELA: PREENCHER ANAMNESE (Paciente)
/// ============================================
class FillAnamnesisPage extends StatefulWidget {
  const FillAnamnesisPage({super.key});

  @override
  State<FillAnamnesisPage> createState() => _FillAnamnesisPageState();
}

class _FillAnamnesisPageState extends State<FillAnamnesisPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controllers
  final _mainGoalController = TextEditingController();
  final _healthConditionsController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _supplementsController = TextEditingController();
  final _bowelHabitsController = TextEditingController();
  final _sleepQualityController = TextEditingController();
  final _waterIntakeController = TextEditingController();
  final _alcoholConsumptionController = TextEditingController();
  final _smokingController = TextEditingController();
  final _physicalActivityController = TextEditingController();
  final _foodAllergiesController = TextEditingController();
  final _foodIntolerancesController = TextEditingController();
  final _dietaryPreferencesController = TextEditingController();

  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnamnesis();
  }

  @override
  void dispose() {
    _mainGoalController.dispose();
    _healthConditionsController.dispose();
    _medicationsController.dispose();
    _supplementsController.dispose();
    _bowelHabitsController.dispose();
    _sleepQualityController.dispose();
    _waterIntakeController.dispose();
    _alcoholConsumptionController.dispose();
    _smokingController.dispose();
    _physicalActivityController.dispose();
    _foodAllergiesController.dispose();
    _foodIntolerancesController.dispose();
    _dietaryPreferencesController.dispose();
    super.dispose();
  }

  Future<void> _loadAnamnesis() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final existing = await _authService.getAnamnesis(user.id);

      if (existing != null) {
        _mainGoalController.text = existing.mainGoal ?? '';
        _healthConditionsController.text = existing.healthConditions ?? '';
        _medicationsController.text = existing.medications ?? '';
        _supplementsController.text = existing.supplements ?? '';
        _bowelHabitsController.text = existing.bowelHabits ?? '';
        _sleepQualityController.text = existing.sleepQuality ?? '';
        _waterIntakeController.text = existing.waterIntake ?? '';
        _alcoholConsumptionController.text = existing.alcoholConsumption ?? '';
        _smokingController.text = existing.smoking ?? '';
        _physicalActivityController.text = existing.physicalActivity ?? '';
        _foodAllergiesController.text = existing.foodAllergies ?? '';
        _foodIntolerancesController.text = existing.foodIntolerances ?? '';
        _dietaryPreferencesController.text = existing.dietaryPreferences ?? '';
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('Erro ao carregar anamnese: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final anamnesis = Anamnesis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: _authService.currentUser!.id,
      mainGoal: _mainGoalController.text.trim(),
      healthConditions: _healthConditionsController.text.trim(),
      medications: _medicationsController.text.trim(),
      supplements: _supplementsController.text.trim(),
      bowelHabits: _bowelHabitsController.text.trim(),
      sleepQuality: _sleepQualityController.text.trim(),
      waterIntake: _waterIntakeController.text.trim(),
      alcoholConsumption: _alcoholConsumptionController.text.trim(),
      smoking: _smokingController.text.trim(),
      physicalActivity: _physicalActivityController.text.trim(),
      foodAllergies: _foodAllergiesController.text.trim(),
      foodIntolerances: _foodIntolerancesController.text.trim(),
      dietaryPreferences: _dietaryPreferencesController.text.trim(),
      createdAt: DateTime.now(),
    );

    final error = await _authService.saveAnamnesis(anamnesis);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anamnese salva com sucesso!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) AppRoutes.back(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Anamnese')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Anamnese'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.back(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preencha o questionário abaixo para que seu nutricionista possa te conhecer melhor.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                _buildTextField(_mainGoalController, 'Qual é o seu principal objetivo?', 'Ex: Emagrecer, ganhar massa, manter a saúde...'),
                _buildTextField(_healthConditionsController, 'Você tem alguma condição de saúde?', 'Ex: Diabetes, hipertensão, colesterol alto...'),
                _buildTextField(_medicationsController, 'Faz uso de algum medicamento?', 'Se sim, quais?'),
                _buildTextField(_supplementsController, 'Faz uso de suplementos?', 'Ex: Whey, creatina, multivitamínico...'),
                _buildTextField(_bowelHabitsController, 'Como está o funcionamento do seu intestino?', 'Ex: Regular, preso, solto...'),
                _buildTextField(_sleepQualityController, 'Como está a qualidade do seu sono?', 'Quantas horas dorme por noite?'),
                _buildTextField(_waterIntakeController, 'Quantidade de água que bebe por dia?', 'Ex: 1,5 litros, 2 litros...'),
                _buildTextField(_alcoholConsumptionController, 'Consome bebida alcoólica?', 'Com que frequência?'),
                _buildTextField(_smokingController, 'Você fuma?', 'Se sim, quantos cigarros por dia?'),
                _buildTextField(_physicalActivityController, 'Pratica atividade física?', 'Qual e com que frequência?'),
                _buildTextField(_foodAllergiesController, 'Possui alguma alergia alimentar?', 'Ex: Amendoim, frutos do mar...'),
                _buildTextField(_foodIntolerancesController, 'Possui alguma intolerância alimentar?', 'Ex: Lactose, glúten...'),
                _buildTextField(_dietaryPreferencesController, 'Preferências alimentares', 'Ex: Não gosta de peixe, adora frutas...'),

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
                  label: Text(_isSaving ? 'Salvando...' : 'Salvar Anamnese'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isSaving ? null : () => AppRoutes.back(context),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: true,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor, preencha este campo.';
          }
          return null;
        },
      ),
    );
  }
}