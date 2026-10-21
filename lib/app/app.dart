import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import 'routes.dart';
import '../main.dart'; // ⚠️ Importa o routeObserver

/// ============================================
/// APLICATIVO NUTRIFLOW
/// ============================================
class NutriFlowApp extends StatelessWidget {
  const NutriFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      
      // ⚠️ Adiciona o observador para monitorar as rotas
      navigatorObservers: [routeObserver],

      initialRoute: '/auth-wrapper',
      
      routes: {
        '/auth-wrapper': (_) => const AuthWrapper(),
        ...AppRoutes.routes,
      },

      onGenerateRoute: (settings) {
        final builder = AppRoutes.routes[settings.name];
        if (builder == null) return null;

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curve,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(curve),
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}

/// ============================================
/// WIDGET: VERIFICADOR DE SESSÃO
/// ============================================
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF1FA774))),
          );
        }

        if (Supabase.instance.client.auth.currentUser != null) {
          return const _DashboardRedirect();
        }

        return const _WelcomeRedirect();
      },
    );
  }
}

class _WelcomeRedirect extends StatelessWidget {
  const _WelcomeRedirect();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _DashboardRedirect extends StatelessWidget {
  const _DashboardRedirect();

  @override
  Widget build(BuildContext context) {
    // NOTA: Aqui deveríamos verificar se é paciente ou nutri para redirecionar corretamente.
    // Como simplificação, se já está logado, vai pro dashboard de paciente (ou nutri).
    // Na prática, o AuthWrapper deveria checar a tabela do banco.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.patientDashboard);
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}