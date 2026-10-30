import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/user_avatar.dart';

/// ============================================
/// TELA: LISTA DE MENSAGENS DO NUTRICIONISTA (Seguro)
/// ============================================
class NutritionistMessagesPage extends StatefulWidget {
  const NutritionistMessagesPage({super.key});

  @override
  State<NutritionistMessagesPage> createState() => _NutritionistMessagesPageState();
}

class _NutritionistMessagesPageState extends State<NutritionistMessagesPage> {
  final _authService = AuthService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _patients = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Pega a lista de pacientes vinculados a esta nutricionista
      final patients = await _authService.getAllPatients();
      
      if (!mounted) return;
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar pacientes: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mensagens'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => AppRoutes.back(context)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
              ? const Center(child: Text('Nenhum paciente vinculado para conversar.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _patients.length,
                  itemBuilder: (context, index) {
                    final patient = _patients[index];
                    final name = patient['name'] as String? ?? 'Paciente';
                    final id = patient['id'] as String;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () async {
                          // Abre o chat passando o ID e o NOME do paciente
                          await Navigator.pushNamed(
                            context, 
                            AppRoutes.nutritionistChat,
                            arguments: {
                              'patientId': id,
                              'name': name,
                            },
                          );
                          _loadData(); // Atualiza ao voltar
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              UserAvatar(name: name, size: UserAvatarSize.medium),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('Toque para abrir a conversa', style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}