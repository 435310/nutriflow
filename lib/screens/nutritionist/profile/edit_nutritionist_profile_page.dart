import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../services/auth_service.dart';
import '../../../services/local_storage_service.dart';

class EditNutritionistProfilePage extends StatefulWidget {
  const EditNutritionistProfilePage({super.key});

  @override
  State<EditNutritionistProfilePage> createState() => _EditNutritionistProfilePageState();
}

class _EditNutritionistProfilePageState extends State<EditNutritionistProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _crnController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _bioController = TextEditingController();

  final _storage = LocalStorageService();
  final _authService = AuthService();
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
    _crnController.dispose();
    _specialtyController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('nutritionist_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        if (response != null) {
          _nameController.text = response['name'] ?? '';
          _emailController.text = response['email'] ?? '';
          _crnController.text = response['crn'] ?? '';
          _specialtyController.text = response['specialty'] ?? '';
          _bioController.text = response['bio'] ?? '';
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar perfil: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('Usuário não logado');

      await Supabase.instance.client
          .from('nutritionist_profiles')
          .update({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'crn': _crnController.text.trim(),
            'specialty': _specialtyController.text.trim(),
            'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
          })
          .eq('user_id', user.id);

      if (!mounted) return;

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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
                  validator: (v) => v == null || v.trim().isEmpty ? 'Informe seu nome' : null,
                  decoration: const InputDecoration(labelText: 'Nome completo', prefixIcon: Icon(Icons.badge_outlined)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Informe seu e-mail' : null,
                  decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 32),
                const _SectionTitle(icon: Icons.medical_services_outlined, title: 'Dados profissionais'),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _crnController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Informe o CRN' : null,
                  decoration: const InputDecoration(labelText: 'CRN', prefixIcon: Icon(Icons.assignment_ind_outlined)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _specialtyController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Informe sua especialidade' : null,
                  decoration: const InputDecoration(labelText: 'Especialidade', prefixIcon: Icon(Icons.workspace_premium_outlined)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
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