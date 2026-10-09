import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/user_avatar.dart';

/// ============================================
/// TELA TEMPORÁRIA: teste do avatar
/// ============================================
class AvatarTestPage extends StatelessWidget {
  const AvatarTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste do Avatar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tamanhos', style: AppTextStyles.h2),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                UserAvatar(name: 'Maria Silva', size: UserAvatarSize.small),
                UserAvatar(name: 'Maria Silva', size: UserAvatarSize.medium),
                UserAvatar(name: 'Maria Silva', size: UserAvatarSize.large),
              ],
            ),

            const SizedBox(height: 40),
            const Text('Nomes diferentes', style: AppTextStyles.h2),
            const SizedBox(height: 20),

            const _AvatarRow('Maria Silva'),
            const _AvatarRow('João Pedro'),
            const _AvatarRow('Ana Costa'),
            const _AvatarRow('Carlos Eduardo Souza'),
            const _AvatarRow('Beatriz'),
            const _AvatarRow('Zé'),
            const _AvatarRow(''),

            const SizedBox(height: 40),
            const Text('Cor customizada', style: AppTextStyles.h2),
            const SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                UserAvatar(
                  name: 'Maria',
                  size: UserAvatarSize.medium,
                  customColor: AppColors.error,
                ),
                UserAvatar(
                  name: 'Maria',
                  size: UserAvatarSize.medium,
                  customColor: AppColors.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarRow extends StatelessWidget {
  final String name;
  const _AvatarRow(this.name);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          UserAvatar(name: name, size: UserAvatarSize.small),
          const SizedBox(width: 16),
          Text(
            name.isEmpty ? '(nome vazio)' : name,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}