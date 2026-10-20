import 'package:flutter/material.dart';

import '../core/theme/colors.dart';

/// ============================================
/// WIDGET: NAVEGAÇÃO INFERIOR DO NUTRICIONISTA
/// ============================================
class NutritionistBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadCount; // ⚠️ Novo parâmetro para o badge

  const NutritionistBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Pacientes',
            ),
            // ⚠️ ABA DE MENSAGENS COM BADGE
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text('${unreadCount > 99 ? '99+' : unreadCount}'),
                backgroundColor: AppColors.error,
                child: const Icon(Icons.chat_bubble_outline),
              ),
              activeIcon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text('$unreadCount'),
                backgroundColor: AppColors.error,
                child: const Icon(Icons.chat_bubble),
              ),
              label: 'Mensagens',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}