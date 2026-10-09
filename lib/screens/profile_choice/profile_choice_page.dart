import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/profile_card.dart';

/// ============================================
/// TELA: ESCOLHA DE PERFIL (com animações)
/// ============================================
class ProfileChoicePage extends StatefulWidget {
  const ProfileChoicePage({super.key});

  @override
  State<ProfileChoicePage> createState() => _ProfileChoicePageState();
}

class _ProfileChoicePageState extends State<ProfileChoicePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animações
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _card1Fade;
  late Animation<Offset> _card1Slide;
  late Animation<double> _card2Fade;
  late Animation<Offset> _card2Slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Título
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    // Subtítulo
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Card 1 (Paciente)
    _card1Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
      ),
    );
    _card1Slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Card 2 (Nutricionista)
    _card2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.9, curve: Curves.easeOut),
      ),
    );
    _card2Slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.9, curve: Curves.easeOutCubic),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.back(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Título
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: const Text(
                    AppStrings.profileChoiceTitle,
                    style: AppTextStyles.h1,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Subtítulo
              FadeTransition(
                opacity: _subtitleFade,
                child: SlideTransition(
                  position: _subtitleSlide,
                  child: const Text(
                    AppStrings.profileChoiceSubtitle,
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Card Paciente
              FadeTransition(
                opacity: _card1Fade,
                child: SlideTransition(
                  position: _card1Slide,
                  child: ProfileCard(
                    icon: Icons.person_outline,
                    title: AppStrings.profilePatientTitle,
                    subtitle: AppStrings.profilePatientSubtitle,
                    color: AppColors.primary,
                    onTap: () {
                      AppRoutes.go(context, AppRoutes.authChoice);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Card Nutricionista
              FadeTransition(
                opacity: _card2Fade,
                child: SlideTransition(
                  position: _card2Slide,
                  child: ProfileCard(
                    icon: Icons.medical_services_outlined,
                    title: AppStrings.profileNutritionistTitle,
                    subtitle: AppStrings.profileNutritionistSubtitle,
                    color: AppColors.secondary,
                    onTap: () {
                      AppRoutes.go(context, AppRoutes.authChoice);
                    },
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