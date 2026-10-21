import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../services/auth_service.dart';

/// ============================================
/// TELA: LOGIN (com Supabase)
/// ============================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSaving = false;

  // Animações
  late AnimationController _controller;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _emailFade;
  late Animation<Offset> _emailSlide;
  late Animation<double> _passwordFade;
  late Animation<Offset> _passwordSlide;
  late Animation<double> _forgotFade;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.35, curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic)));
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.4, curve: Curves.easeOut)));
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.4, curve: Curves.easeOutCubic)));
    _emailFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.55, curve: Curves.easeOut)));
    _emailSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic)));
    _passwordFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)));
    _passwordSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic)));
    _forgotFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.55, 0.75, curve: Curves.easeOut)));
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.65, 0.85, curve: Curves.easeOut)));
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.65, 0.85, curve: Curves.easeOutCubic)));
    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0, curve: Curves.easeOut)));

    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.validationEmailRequired;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return AppStrings.validationEmailInvalid;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return AppStrings.validationPasswordRequired;
    if (value.length < 6) return AppStrings.validationPasswordShort;
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final authService = AuthService();
    final error = await authService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (error == null) {
      // ⚠️ Verifica se é nutricionista ou paciente
      final isNutri = await authService.isNutritionist();
      
      // ⚠️ ADICIONE ESTA LINHA PARA DEBUG
      print('É NUTRICIONISTA? $isNutri');

      if (!mounted) return;
      
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          if (isNutri) {
            AppRoutes.go(context, AppRoutes.nutritionistDashboard);
          } else {
            AppRoutes.go(context, AppRoutes.patientDashboard);
          }
        }
      });
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(opacity: _titleFade, child: SlideTransition(position: _titleSlide, child: const Text(AppStrings.loginTitle, style: AppTextStyles.h1))),
                const SizedBox(height: 12),
                FadeTransition(opacity: _subtitleFade, child: SlideTransition(position: _subtitleSlide, child: const Text(AppStrings.loginSubtitle, style: AppTextStyles.bodySecondary))),
                const SizedBox(height: 40),

                FadeTransition(opacity: _emailFade, child: SlideTransition(position: _emailSlide, child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  decoration: const InputDecoration(labelText: AppStrings.loginEmailLabel, prefixIcon: Icon(Icons.email_outlined)),
                ))),
                const SizedBox(height: 20),

                FadeTransition(opacity: _passwordFade, child: SlideTransition(position: _passwordSlide, child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: AppStrings.loginPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ))),
                const SizedBox(height: 12),

                FadeTransition(opacity: _forgotFade, child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recuperação de senha em breve'))),
                    child: const Text(AppStrings.loginForgotPassword),
                  ),
                )),
                const SizedBox(height: 20),

                FadeTransition(opacity: _buttonFade, child: SlideTransition(position: _buttonSlide, child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleLogin,
                  icon: _isSaving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.login),
                  label: Text(_isSaving ? 'Entrando...' : AppStrings.loginButton),
                ))),
                const SizedBox(height: 24),

                FadeTransition(opacity: _footerFade, child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(AppStrings.loginNoAccount, style: AppTextStyles.caption),
                      TextButton(onPressed: () => AppRoutes.go(context, AppRoutes.signup), child: const Text(AppStrings.loginCreateAccount)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}