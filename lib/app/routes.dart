import 'package:flutter/material.dart';


import '../screens/welcome/welcome_page.dart';
import '../screens/profile_choice/profile_choice_page.dart';
import '../screens/auth/auth_choice_page.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/signup_page.dart';
import '../screens/patient/profile/profile_page.dart';  // ← NOVO
import '../screens/test/avatar_test_page.dart';

/// ============================================
/// ROTAS DO NUTRIFLOW
/// ============================================
/// Centraliza a navegação do app.
/// Cada tela tem um nome único (routeName).
class AppRoutes {
  AppRoutes._();

  // Nomes das rotas
  static const String welcome = '/';
  static const String profileChoice = '/profile-choice';
  static const String authChoice = '/auth-choice';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profile = '/profile';

  // Mapa de rotas: nome → builder da tela
  static Map<String, WidgetBuilder> get routes {
  return {
    welcome: (_) => const WelcomePage(),
    profileChoice: (_) => const ProfileChoicePage(),
    authChoice: (_) => const AuthChoicePage(),
    login: (_) => const LoginPage(),
    signup: (_) => const SignupPage(),
    profile: (_) => const ProfilePage(),  // ← NOVO
    '/avatar-test': (_) => const AvatarTestPage(),
  };
}

  // Método auxiliar para navegar
  static void go(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  // Método auxiliar para voltar
  static void back(BuildContext context) {
    Navigator.pop(context);
  }
}