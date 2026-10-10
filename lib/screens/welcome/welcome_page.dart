import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../test/avatar_test_page.dart';

/// ============================================
/// TELA: BOAS-VINDAS (com animações)
/// ============================================
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  // Controller principal das animações de entrada
  late AnimationController _entryController;

  // Controller do pulse contínuo do logo
  late AnimationController _pulseController;

  // Animações individuais
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _iconFade;
  late Animation<double> _iconScale;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _loginButtonFade;
  late Animation<Offset> _loginButtonSlide;
  late Animation<double> _signupButtonFade;
  late Animation<Offset> _signupButtonSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    // ============================================
    // ANIMAÇÃO DE ENTRADA (1.4s total)
    // ============================================
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Logo — fade + scale + leve rotação
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );
    _logoRotation = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    // Ícone interno
    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // Título
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.6, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Subtítulo
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // Botão Entrar
    _loginButtonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.65, 0.85, curve: Curves.easeOut),
      ),
    );
    _loginButtonSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.65, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // Botão Criar conta
    _signupButtonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );
    _signupButtonSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // ============================================
    // PULSE DO LOGO (contínuo)
    // ============================================
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulse = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _entryController.forward();

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF7),
              Color(0xFFF8FAFC),
            ],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // ============================================
                // LOGO ANIMADO
                // ============================================
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: RotationTransition(
                      turns: _logoRotation,
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulse.value,
                            child: child,
                          );
                        },
                        child: Container(
                          height: 110,
                          width: 110,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: FadeTransition(
                            opacity: _iconFade,
                            child: ScaleTransition(
                              scale: _iconScale,
                              child: const Icon(
                                Icons.restaurant_menu,
                                size: 58,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // ============================================
                // TÍTULO
                // ============================================
                FadeTransition(
                  opacity: _titleFade,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: const Text(
                      AppStrings.welcomeTitle,
                      style: AppTextStyles.h1,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ============================================
                // SUBTÍTULO
                // ============================================
                FadeTransition(
                  opacity: _subtitleFade,
                  child: SlideTransition(
                    position: _subtitleSlide,
                    child: const Text(
                      AppStrings.welcomeSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                ),

                const Spacer(),

                // ============================================
                // BOTÃO ENTRAR
                // ============================================
                FadeTransition(
                  opacity: _loginButtonFade,
                  child: SlideTransition(
                    position: _loginButtonSlide,
                    child: _PressableButton(
                      onPressed: () {
                        AppRoutes.go(context, AppRoutes.profileChoice);
                      },
                      child: ElevatedButton(
                        onPressed: () {
                          AppRoutes.go(context, AppRoutes.profileChoice);
                        },
                        child: const Text(AppStrings.welcomeButtonLogin),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ============================================
                // BOTÃO CRIAR CONTA
                // ============================================
                FadeTransition(
                  opacity: _signupButtonFade,
                  child: SlideTransition(
                    position: _signupButtonSlide,
                    child: _PressableButton(
                      onPressed: () {
                        AppRoutes.go(context, AppRoutes.profileChoice);
                      },
                      child: OutlinedButton(
                        onPressed: () {
                          AppRoutes.go(context, AppRoutes.profileChoice);
                        },
                        child: const Text(AppStrings.welcomeButtonSignup),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ============================================
                // BOTÕES TEMPORÁRIOS PARA TESTE
                // ⚠️ REMOVER QUANDO O APP ESTIVER PRONTO
                // ============================================

                // Testar Avatar
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AvatarTestPage(),
                      ),
                    );
                  },
                  child: const Text('🧪 Testar Avatar (temporário)'),
                ),

                // Testar Perfil
                TextButton(
                  onPressed: () {
                    AppRoutes.go(context, AppRoutes.profile);
                  },
                  child: const Text('👤 Testar Perfil (temporário)'),
                ),

                // Testar Dashboard
                TextButton(
                  onPressed: () {
                    AppRoutes.go(context, AppRoutes.patientDashboard);
                  },
                  child: const Text('🏠 Testar Dashboard (temporário)'),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================
/// WIDGET: BOTÃO COM MICRO-INTERAÇÃO
/// ============================================
class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _PressableButton({
    required this.child,
    required this.onPressed,
  });

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}