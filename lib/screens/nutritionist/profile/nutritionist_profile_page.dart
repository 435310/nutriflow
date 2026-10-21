import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/user_avatar.dart';

class NutritionistProfilePage extends StatefulWidget {
  const NutritionistProfilePage({super.key});

  @override
  State<NutritionistProfilePage> createState() => _NutritionistProfilePageState();
}

class _NutritionistProfilePageState extends State<NutritionistProfilePage> {
  final _authService = AuthService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
        _profile = response;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) AppRoutes.go(context, AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Meu Perfil')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final name = _profile!['name'] ?? 'Nutricionista';
    final email = _profile!['email'] ?? '';
    final crn = _profile!['crn'] ?? '';
    final specialty = _profile!['specialty'] ?? '';
    final bio = _profile!['bio'] ?? 'Não informado';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => AppRoutes.back(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              UserAvatar(name: name, size: UserAvatarSize.large),
              const SizedBox(height: 20),
              Text(name, style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(email, style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 40, width: 40,
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text('Dados Profissionais', style: AppTextStyles.h3),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow('CRN', crn),
                    _buildInfoRow('Especialidade', specialty),
                    _buildInfoRow('Bio', bio),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRoutes.editNutritionistProfile);
                  _loadProfile();
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar perfil'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Sair', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: AppTextStyles.caption)),
          Expanded(child: Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}