import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/nutritionist_profile.dart';
import '../../../services/local_storage_service.dart';

class EditNutritionistProfilePage extends StatefulWidget {
  const EditNutritionistProfilePage({super.key});

  @override
  State<EditNutritionistProfilePage> createState() =>
      _EditNutritionistProfilePageState();
}

class _EditNutritionistProfilePageState
    extends State<EditNutritionistProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _crnController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _bioController = TextEditingController();

  NutritionistProfile _profile = NutritionistProfile.mock();
  final _storage = LocalStorageService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _crnController.dispose();
    _specialtyController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final stored = await _storage.loadNutritionistProfile();
    final profile = stored ?? NutritionistProfile.mock();
    if (!mounted) return;

    setState(() {
      _profile = profile;
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _crnController.text = profile.crn;
      _specialtyController.text = profile.specialty;
      _bioController.text = profile.bio ?? '';
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updated = _profile.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      crn: _crnController.text.trim(),
      specialty: _specialtyController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final success = await _storage.saveNutritionistProfile(updated);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
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
        const SnackBar(
          content: Text('Erro ao salvar. Tente novamente.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
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
                const _SectionTitle(icon: Icons.person_outline, title: 'Dados pessoais'),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Informe seu nome' : null,
                  decoration: const InputDecoration(labelText: 'Nome completo', prefixIcon: Icon(Icons.badge_outlined)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Informe seu e-mail' : null,
                  decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 32),
                const _SectionTitle(icon: Icons.medical_services_outlined, title: 'Dados profissionais'),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _crnController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Informe o CRN' : null,
                  decoration: const InputDecoration(labelText: 'CRN', hintText: 'Ex: CRN-3 12345', prefixIcon: Icon(Icons.assignment_ind_outlined)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _specialtyController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Informe sua especialidade' : null,
                  decoration: const InputDecoration(labelText: 'Especialidade', hintText: 'Ex: Nutrição Clínica', prefixIcon: Icon(Icons.workspace_premium_outlined)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Bio (opcional)', prefixIcon: Icon(Icons.notes_outlined)),
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
          height: 36, width: 36,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTextStyles.h3),
      ],
    );
  }
}