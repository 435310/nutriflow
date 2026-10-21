import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/patient_profile.dart';
import '../../../services/auth_service.dart';

/// ============================================
/// TELA: EDITAR PERFIL (Supabase)
/// ============================================
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalWeightController = TextEditingController();
  final _waistController = TextEditingController();
  final _initialWeightController = TextEditingController();
  
  // ⚠️ Novos Controllers
  final _restrictionsController = TextEditingController();
  final _allergiesController = TextEditingController();

  // Estados
  DateTime? _birthDate;
  Gender? _gender;
  Goal? _goal;
  ActivityLevel? _activityLevel;
  
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    _waistController.dispose();
    _initialWeightController.dispose();
    _restrictionsController.dispose(); // ⚠️
    _allergiesController.dispose();    // ⚠️
    super.dispose();
  }

  // ============================================
  // CARREGAR PERFIL DO SUPABASE
  // ============================================
  Future<void> _loadProfile() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('patient_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (response != null) {
        _nameController.text = response['name'] ?? '';
        _emailController.text = response['email'] ?? '';
        _phoneController.text = response['phone'] ?? '';
        
        if (response['birth_date'] != null) {
          _birthDate = DateTime.parse(response['birth_date']);
        }
        
        if (response['gender'] != null) {
          _gender = Gender.values.firstWhere((e) => e.name == response['gender'], orElse: () => Gender.other);
        }
        
        _heightController.text = response['height_cm']?.toString() ?? '';
        _initialWeightController.text = response['initial_weight_kg']?.toString() ?? '';
        _weightController.text = response['current_weight_kg']?.toString() ?? '';
        _goalWeightController.text = response['goal_weight_kg']?.toString() ?? '';
        _waistController.text = response['waist_cm']?.toString() ?? '';
        
        if (response['goal'] != null) {
          _goal = Goal.values.firstWhere((e) => e.name == response['goal'], orElse: () => Goal.maintain);
        }
        
        if (response['activity_level'] != null) {
          _activityLevel = ActivityLevel.values.firstWhere((e) => e.name == response['activity_level'], orElse: () => ActivityLevel.sedentary);
        }

        // ⚠️ Converte as listas do banco para texto separado por vírgula
        final restrictions = (response['food_restrictions'] as List<dynamic>?)?.join(', ') ?? '';
        _restrictionsController.text = restrictions;

        final allergies = (response['allergies'] as List<dynamic>?)?.join(', ') ?? '';
        _allergiesController.text = allergies;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar perfil: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================
  // VALIDAÇÕES
  // ============================================
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.validationNameRequired;
    if (value.trim().length < 3) return AppStrings.validationNameShort;
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.validationEmailRequired;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return AppStrings.validationEmailInvalid;
    return null;
  }

  // ============================================
  // SALVAR NO SUPABASE
  // ============================================
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final error = await _authService.updatePatientProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      birthDate: _birthDate,
      gender: _gender?.name,
      heightCm: double.tryParse(_heightController.text.replaceAll(',', '.')),
      initialWeightKg: double.tryParse(_initialWeightController.text.replaceAll(',', '.')),
      currentWeightKg: double.tryParse(_weightController.text.replaceAll(',', '.')),
      goalWeightKg: double.tryParse(_goalWeightController.text.replaceAll(',', '.')),
      waistCm: double.tryParse(_waistController.text.replaceAll(',', '.')),
      goal: _goal?.name,
      activityLevel: _activityLevel?.name,
      // ⚠️ Envia as listas separadas por vírgula convertidas para array
      foodRestrictions: _restrictionsController.text.trim().isEmpty
          ? null
          : _restrictionsController.text.split(',').map((e) => e.trim()).toList(),
      allergies: _allergiesController.text.trim().isEmpty
          ? null
          : _allergiesController.text.split(',').map((e) => e.trim()).toList(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
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

  void _handleCancel() {
    AppRoutes.back(context);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Selecione sua data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não informado';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar perfil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleCancel,
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
                // DADOS PESSOAIS
                const _SectionTitle(icon: Icons.person_outline, title: 'Dados pessoais'),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  validator: _validateName,
                  decoration: const InputDecoration(labelText: 'Nome completo', prefixIcon: Icon(Icons.badge_outlined)),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Telefone', prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: _pickBirthDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(_formatDate(_birthDate), style: AppTextStyles.body),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<Gender>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Sexo', prefixIcon: Icon(Icons.wc_outlined)),
                  items: Gender.values.map((g) => DropdownMenuItem(value: g, child: Text(g.label))).toList(),
                  onChanged: (value) => setState(() => _gender = value),
                ),
                const SizedBox(height: 32),

                // DADOS CLÍNICOS
                const _SectionTitle(icon: Icons.monitor_weight_outlined, title: 'Dados clínicos'),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Altura (cm)', hintText: 'Ex: 165', prefixIcon: Icon(Icons.height)),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _initialWeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Peso inicial (kg)', hintText: 'Ex: 78.0', prefixIcon: Icon(Icons.history)),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Peso atual (kg)', hintText: 'Ex: 72.4', prefixIcon: Icon(Icons.monitor_weight_outlined)),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _goalWeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Meta de peso (kg)', hintText: 'Ex: 65.0', prefixIcon: Icon(Icons.flag_outlined)),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _waistController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Circunferência abdominal (cm)', hintText: 'Ex: 88', prefixIcon: Icon(Icons.straighten)),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<Goal>(
                  value: _goal,
                  decoration: const InputDecoration(labelText: 'Objetivo', prefixIcon: Icon(Icons.track_changes_outlined)),
                  items: Goal.values.map((g) => DropdownMenuItem(value: g, child: Text('${g.icon} ${g.label}'))).toList(),
                  onChanged: (value) => setState(() => _goal = value),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<ActivityLevel>(
                  value: _activityLevel,
                  decoration: const InputDecoration(labelText: 'Nível de atividade física', prefixIcon: Icon(Icons.fitness_center)),
                  items: ActivityLevel.values.map((level) => DropdownMenuItem(value: level, child: Text('${level.label} — ${level.description}'))).toList(),
                  onChanged: (value) => setState(() => _activityLevel = value),
                ),
                
                const SizedBox(height: 32),
                
                // ⚠️ RESTRIÇÕES E ALERGIAS
                const _SectionTitle(icon: Icons.health_and_safety_outlined, title: 'Restrições e Alergias'),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _restrictionsController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Restrições alimentares',
                    hintText: 'Ex: Lactose, Glúten (separe por vírgula)',
                    prefixIcon: Icon(Icons.no_food_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _allergiesController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Alergias',
                    hintText: 'Ex: Amendoim, Frutos do mar (separe por vírgula)',
                    prefixIcon: Icon(Icons.warning_amber_outlined),
                  ),
                ),
                
                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: _isSaving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check),
                  label: Text(_isSaving ? 'Salvando...' : 'Salvar alterações'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isSaving ? null : _handleCancel,
                  child: const Text('Cancelar'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTextStyles.h3),
      ],
    );
  }
}