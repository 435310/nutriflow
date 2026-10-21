import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/user_avatar.dart';

/// ============================================
/// TELA: LISTA DE MENSAGENS DO NUTRICIONISTA (Nuvem)
/// ============================================
class NutritionistMessagesPage extends StatefulWidget {
  const NutritionistMessagesPage({super.key});

  @override
  State<NutritionistMessagesPage> createState() => _NutritionistMessagesPageState();
}

class _NutritionistMessagesPageState extends State<NutritionistMessagesPage> {
  final _authService = AuthService();
  int _unreadCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final count = await _authService.countUnreadMessagesFromCloud(forNutritionist: true);
    if (!mounted) return;
    setState(() {
      _unreadCount = count;
      _isLoading = false;
    });
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
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                InkWell(
                  onTap: () async {
                    // ⚠️ Aguarda a tela de chat fechar
                    await Navigator.pushNamed(context, AppRoutes.nutritionistChat);
                    // ⚠️ Quando voltar, recarrega os dados para zerar o badge local
                    _loadData();
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
                        const UserAvatar(name: 'Paciente', size: UserAvatarSize.medium),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Paciente', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  Text('Agora', style: AppTextStyles.caption),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _unreadCount > 0 ? 'Você tem $_unreadCount novas mensagens' : 'Toque para abrir a conversa',
                                style: AppTextStyles.caption.copyWith(
                                  color: _unreadCount > 0 ? AppColors.primary : AppColors.textSecondary,
                                  fontWeight: _unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (_unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                            child: Text('$_unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}