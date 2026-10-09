import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';

/// ============================================
/// TELA: CADASTRO (com animações)
/// ============================================
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  // Chave do formulário
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Estados
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  // Animações
  late AnimationController _controller;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _nameFade;
  late Animation<Offset> _nameSlide;
  late Animation<double> _emailFade;
  late Animation<Offset> _emailSlide;
  late Animation<double> _passwordFade;
  late Animation<Offset> _passwordSlide;
  late Animation<double> _confirmFade;
  late Animation<Offset> _confirmSlide;
  late Animation<double> _termsFade;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Título
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
      ),
    );

    // Subtítulo
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.08, 0.35, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.08, 0.35, curve: Curves.easeOutCubic),
      ),
    );

    // Campo Nome
    _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.45, curve: Curves.easeOut),
      ),
    );
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    // Campo E-mail
    _emailFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.57, curve: Curves.easeOut),
      ),
    );
    _emailSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.57, curve: Curves.easeOutCubic),
      ),
    );

    // Campo Senha
    _passwordFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.44, 0.69, curve: Curves.easeOut),
      ),
    );
    _passwordSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.44, 0.69, curve: Curves.easeOutCubic),
      ),
    );

    // Campo Confirmar Senha
    _confirmFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.56, 0.81, curve: Curves.easeOut),
      ),
    );
    _confirmSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.56, 0.81, curve: Curves.easeOutCubic),
      ),
    );

    // Checkbox de Termos
    _termsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.88, curve: Curves.easeOut),
      ),
    );

    // Botão Criar conta
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.78, 0.94, curve: Curves.easeOut),
      ),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.78, 0.94, curve: Curves.easeOutCubic),
      ),
    );

    // Rodapé (Já tem conta)
    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.88, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Validações
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationNameRequired;
    }
    if (value.trim().length < 3) {
      return AppStrings.validationNameShort;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationEmailRequired;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.validationEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationPasswordRequired;
    }
    if (value.length < 6) {
      return AppStrings.validationPasswordShort;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationConfirmPasswordRequired;
    }
    if (value != _passwordController.text) {
      return AppStrings.validationPasswordMismatch;
    }
    return null;
  }

  // Ação do botão Criar conta
  void _handleSignup() {
    final isFormValid = _formKey.currentState!.validate();

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.validationTermsRequired),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cadastro: ${_nameController.text.trim()}'),
          duration: const Duration(seconds: 2),
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
                const SizedBox(height: 20),

                // Título
                FadeTransition(
                  opacity: _titleFade,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: const Text(
                      AppStrings.signupTitle,
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
                      AppStrings.signupSubtitle,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Campo Nome
                FadeTransition(
                  opacity: _nameFade,
                  child: SlideTransition(
                    position: _nameSlide,
                    child: TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: _validateName,
                      decoration: const InputDecoration(
                        labelText: AppStrings.signupNameLabel,
                        hintText: AppStrings.signupNameHint,
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Campo E-mail
                FadeTransition(
                  opacity: _emailFade,
                  child: SlideTransition(
                    position: _emailSlide,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        labelText: AppStrings.signupEmailLabel,
                        hintText: AppStrings.signupEmailHint,
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Campo Senha
                FadeTransition(
                  opacity: _passwordFade,
                  child: SlideTransition(
                    position: _passwordSlide,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      validator: _validatePassword,
                      decoration: InputDecoration(
                        labelText: AppStrings.signupPasswordLabel,
                        hintText: AppStrings.signupPasswordHint,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Campo Confirmar Senha
                FadeTransition(
                  opacity: _confirmFade,
                  child: SlideTransition(
                    position: _confirmSlide,
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      validator: _validateConfirmPassword,
                      onFieldSubmitted: (_) => _handleSignup(),
                      decoration: InputDecoration(
                        labelText: AppStrings.signupConfirmPasswordLabel,
                        hintText: AppStrings.signupConfirmPasswordHint,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Checkbox de Termos
                FadeTransition(
                  opacity: _termsFade,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            AppStrings.signupTermsText,
                            style: AppTextStyles.caption.copyWith(height: 1.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botão Criar conta
                FadeTransition(
                  opacity: _buttonFade,
                  child: SlideTransition(
                    position: _buttonSlide,
                    child: ElevatedButton(
                      onPressed: _handleSignup,
                      child: const Text(AppStrings.signupButton),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Rodapé - Já tem conta
                FadeTransition(
                  opacity: _footerFade,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          AppStrings.signupAlreadyHaveAccount,
                          style: AppTextStyles.caption,
                        ),
                        TextButton(
                          onPressed: () {
                            AppRoutes.go(context, AppRoutes.login);
                          },
                          child: const Text(AppStrings.signupLogin),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}