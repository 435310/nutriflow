import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/patient_profile.dart';
import '../../../widgets/user_avatar.dart';

/// ============================================
/// TELA: PERFIL DO PACIENTE
/// ============================================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _avatarFade;
  late Animation<double> _nameFade;
  late Animation<double> _emailFade;
  late Animation<double> _card1Fade;
  late Animation<Offset> _card1Slide;
  late Animation<double> _card2Fade;
  late Animation<Offset> _card2Slide;
  late Animation<double> _card3Fade;
  late Animation<Offset> _card3Slide;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

  // Paciente mock (dados fictícios por enquanto)
  final PatientProfile _profile = PatientProfile.mock();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
      ),
    );

    _avatarFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.45, curve: Curves.easeOut),
      ),
    );

    _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.55, curve: Curves.easeOut),
      ),
    );

    _emailFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.65, curve: Curves.easeOut),
      ),
    );

    _card1Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );
    _card1Slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _card2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOut),
      ),
    );
    _card2Slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _card3Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.9, curve: Curves.easeOut),
      ),
    );
    _card3Slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
      ),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.back(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar
              FadeTransition(
                opacity: _avatarFade,
                child: UserAvatar(
                  name: _profile.name,
                  size: UserAvatarSize.large,
                ),
              ),

              const SizedBox(height: 20),

              // Nome
              FadeTransition(
                opacity: _nameFade,
                child: Text(
                  _profile.name,
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 6),

              // E-mail
              FadeTransition(
                opacity: _emailFade,
                child: Text(
                  _profile.email,
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              // Card 1: Dados pessoais
              FadeTransition(
                opacity: _card1Fade,
                child: SlideTransition(
                  position: _card1Slide,
                  child: _InfoCard(
                    icon: Icons.person_outline,
                    title: 'Dados pessoais',
                    items: [
                      _InfoItem(
                        label: 'Telefone',
                        value: _profile.phone ?? 'Não informado',
                      ),
                      _InfoItem(
                        label: 'Idade',
                        value: _profile.age != null
                            ? '${_profile.age} anos'
                            : 'Não informado',
                      ),
                      _InfoItem(
                        label: 'Sexo',
                        value: _profile.gender?.label ?? 'Não informado',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Card 2: Dados clínicos
              FadeTransition(
                opacity: _card2Fade,
                child: SlideTransition(
                  position: _card2Slide,
                  child: _InfoCard(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Dados clínicos',
                    items: [
                      _InfoItem(
                        label: 'Altura',
                        value: _profile.heightCm != null
                            ? '${(_profile.heightCm! / 100).toStringAsFixed(2)} m'
                            : 'Não informado',
                      ),
                      _InfoItem(
                        label: 'Peso atual',
                        value: _profile.currentWeightKg != null
                            ? '${_profile.currentWeightKg!.toStringAsFixed(1)} kg'
                            : 'Não informado',
                      ),
                      _InfoItem(
                        label: 'Meta',
                        value: _profile.goalWeightKg != null
                            ? '${_profile.goalWeightKg!.toStringAsFixed(1)} kg'
                            : 'Não informado',
                      ),
                      _InfoItem(
                        label: 'IMC',
                        value: _profile.bmi != null
                            ? '${_profile.bmi!.toStringAsFixed(1)} (${_profile.bmiCategory})'
                            : 'Não informado',
                      ),
                      _InfoItem(
                        label: 'Objetivo',
                        value: _profile.goal != null
                            ? '${_profile.goal!.icon} ${_profile.goal!.label}'
                            : 'Não informado',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Card 3: Restrições
              FadeTransition(
                opacity: _card3Fade,
                child: SlideTransition(
                  position: _card3Slide,
                  child: _InfoCard(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Restrições e alergias',
                    items: [
                      _InfoItem(
                        label: 'Restrições',
                        value: _profile.foodRestrictions.isEmpty
                            ? 'Nenhuma'
                            : _profile.foodRestrictions.join(', '),
                      ),
                      _InfoItem(
                        label: 'Alergias',
                        value: _profile.allergies.isEmpty
                            ? 'Nenhuma'
                            : _profile.allergies.join(', '),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botão Editar Perfil
              FadeTransition(
                opacity: _buttonFade,
                child: SlideTransition(
                  position: _buttonSlide,
                  child: ElevatedButton.icon(
                    onPressed: () {
  AppRoutes.go(context, AppRoutes.editProfile);
},
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar perfil'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// WIDGET: CARD DE INFORMAÇÕES
// ============================================
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_InfoItem> items;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do card
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.h3),
            ],
          ),

          const SizedBox(height: 20),

          // Itens
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        item.label,
                        style: AppTextStyles.caption,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });
}