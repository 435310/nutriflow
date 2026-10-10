import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import 'user_avatar.dart';

/// ============================================
/// WIDGET: CABEÇALHO COM SAUDAÇÃO
/// ============================================
class GreetingHeader extends StatelessWidget {
  final String name;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  const GreetingHeader({
    super.key,
    required this.name,
    this.onNotificationTap,
    this.notificationCount = 0,
  });

  /// Retorna a saudação baseada no horário atual
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  /// Pega só o primeiro nome
  String _getFirstName() {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : name;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        UserAvatar(
          name: name,
          size: UserAvatarSize.medium,
        ),

        const SizedBox(width: 14),

        // Textos (saudação + subtítulo)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()}, ${_getFirstName()}!',
                style: AppTextStyles.h3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Vamos ver como foi hoje?',
                style: AppTextStyles.caption,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Ícone de notificações
        _NotificationButton(
          count: notificationCount,
          onTap: onNotificationTap,
        ),
      ],
    );
  }
}

// ============================================
// BOTÃO DE NOTIFICAÇÕES
// ============================================
class _NotificationButton extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _NotificationButton({
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: onTap,
          ),
        ),

        // Badge de notificação (se tiver)
        if (count > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.background, width: 2),
              ),
              constraints: const BoxConstraints(minWidth: 20),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}