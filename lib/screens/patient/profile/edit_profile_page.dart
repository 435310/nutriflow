import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/patient_profile.dart';

/// ============================================
/// TELA: EDITAR PERFIL
/// ============================================
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers dos campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalWeightController = TextEditingController();
  final _waistController = TextEditingController();
  final _initialWeightController = TextEditingController();

  // Dados selecionados (dropdowns / date picker)
  DateTime? _birthDate;
  Gender? _gender;
  Goal? _goal;
  ActivityLevel? _activityLevel;

  // Paciente atual (vem do mock por enquanto)
  final PatientProfile _profile = PatientProfile.mock();

  @override
  void initState() {
    super.initState();

    // Pré-preenche os controllers com os dados atuais
    _nameController.text = _profile.name;
    _emailController.text = _profile.email;
    _phoneController.text = _profile.phone ?? '';
    _heightController.text = _profile.heightCm?.toStringAsFixed(0) ?? '';
    _weightController.text = _profile.currentWeightKg?.toStringAsFixed(1) ?? '';
    _goalWeightController.text =
        _profile.goalWeightKg?.toStringAsFixed(1) ?? '';
    _waistController.text = _profile.waistCm?.toStringAsFixed(0) ?? '';
    _initialWeightController.text =
        _profile.initialWeightKg?.toStringAsFixed(1) ?? '';

    _birthDate = _profile.birthDate;
    _gender = _profile.gender;
    _goal = _profile.goal;
    _activityLevel = _profile.activityLevel;
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
    super.dispose();
  }

  // ============================================
  // VALIDAÇÕES
  // ============================================
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationNameRequired;
    }
    if (value.trim().length < 3) {
      return AppStrings.validationNameShort;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationEmailRequired;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.validationEmailInvalid;
    }
    return null;
  }

  String? _validateHeight(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return 'Valor inválido';
    if (parsed < 50 || parsed > 250) return 'Altura entre 50 e 250 cm';
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return 'Valor inválido';
    if (parsed < 20 || parsed > 500) return 'Peso entre 20 e 500 kg';
    return null;
  }

  // ============================================
  // AÇÃO: SALVAR
  // ============================================
  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final updated = _profile.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      birthDate: _birthDate,
      gender: _gender,
      heightCm: double.tryParse(_heightController.text.replaceAll(',', '.')),
      initialWeightKg:
          double.tryParse(_initialWeightController.text.replaceAll(',', '.')),
      currentWeightKg:
          double.tryParse(_weightController.text.replaceAll(',', '.')),
      goalWeightKg:
          double.tryParse(_goalWeightController.text.replaceAll(',', '.')),
      waistCm: double.tryParse(_waistController.text.replaceAll(',', '.')),
      goal: _goal,
      activityLevel: _activityLevel,
      updatedAt: DateTime.now(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil atualizado: ${updated.name}'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================
  // AÇÃO: CANCELAR
  // ============================================
  void _handleCancel() {
    AppRoutes.back(context);
  }

  // ============================================
  // DATE PICKER
  // ============================================
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
      setState(() {
        _birthDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não informado';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================
  // BUILD
  // ============================================
  @override
  Widget build(BuildContext context) {
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
                // ============================================
                // SEÇÃO: DADOS PESSOAIS
                // ============================================
                const _SectionTitle(
                  icon: Icons.person_outline,
                  title: 'Dados pessoais',
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: _validateName,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    hintText: '(11) 99999-9999',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                // Data de nascimento
                InkWell(
                  onTap: _pickBirthDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      _formatDate(_birthDate),
                      style: AppTextStyles.body,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sexo
                DropdownButtonFormField<Gender>(
                  value: _gender,
                  decoration: const InputDecoration(
                    labelText: 'Sexo',
                    prefixIcon: Icon(Icons.wc_outlined),
                  ),
                  items: Gender.values.map((g) {
                    return DropdownMenuItem<Gender>(
                      value: g,
                      child: Text(g.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),

                const SizedBox(height: 32),

                // ============================================
                // SEÇÃO: DADOS CLÍNICOS
                // ============================================
                const _SectionTitle(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Dados clínicos',
                ),

                const SizedBox(height: 20),

                // Altura
                TextFormField(
                  controller: _heightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: _validateHeight,
                  decoration: const InputDecoration(
                    labelText: 'Altura (cm)',
                    hintText: 'Ex: 165',
                    prefixIcon: Icon(Icons.height),
                  ),
                ),

                const SizedBox(height: 16),

                // Peso inicial
                TextFormField(
                  controller: _initialWeightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: _validateWeight,
                  decoration: const InputDecoration(
                    labelText: 'Peso inicial (kg)',
                    hintText: 'Ex: 78.0',
                    prefixIcon: Icon(Icons.history),
                  ),
                ),

                const SizedBox(height: 16),

                // Peso atual
                TextFormField(
                  controller: _weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: _validateWeight,
                  decoration: const InputDecoration(
                    labelText: 'Peso atual (kg)',
                    hintText: 'Ex: 72.4',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                // Meta de peso
                TextFormField(
                  controller: _goalWeightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: _validateWeight,
                  decoration: const InputDecoration(
                    labelText: 'Meta de peso (kg)',
                    hintText: 'Ex: 65.0',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                // Circunferência abdominal
                TextFormField(
                  controller: _waistController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Circunferência abdominal (cm)',
                    hintText: 'Ex: 88',
                    prefixIcon: Icon(Icons.straighten),
                  ),
                ),

                const SizedBox(height: 16),

                // Objetivo
                DropdownButtonFormField<Goal>(
                  value: _goal,
                  decoration: const InputDecoration(
                    labelText: 'Objetivo',
                    prefixIcon: Icon(Icons.track_changes_outlined),
                  ),
                  items: Goal.values.map((g) {
                    return DropdownMenuItem<Goal>(
                      value: g,
                      child: Text('${g.icon} ${g.label}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _goal = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Nível de atividade física
                DropdownButtonFormField<ActivityLevel>(
                  value: _activityLevel,
                  decoration: const InputDecoration(
                    labelText: 'Nível de atividade física',
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  items: ActivityLevel.values.map((level) {
                    return DropdownMenuItem<ActivityLevel>(
                      value: level,
                      child: Text('${level.label} — ${level.description}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _activityLevel = value;
                    });
                  },
                ),

                const SizedBox(height: 32),

                // ============================================
                // BOTÕES
                // ============================================
                ElevatedButton(
                  onPressed: _handleSave,
                  child: const Text('Salvar alterações'),
                ),

                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: _handleCancel,
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
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTextStyles.h3),
      ],
    );
  }
}