import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import 'routes.dart';

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
      
      // A rota inicial agora é o AuthWrapper
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
    // Escuta as mudanças de autenticação em tempo real
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Se estiver carregando, mostra uma tela vazia
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
          );
        }

        // Se tem usuário logado, vai pro dashboard do paciente
        if (Supabase.instance.client.auth.currentUser != null) {
          // NOTA: Aqui futuramente vamos verificar se é paciente ou nutricionista
          return const _DashboardRedirect();
        }

        // Se não tem, vai pra tela de Welcome
        return const _WelcomeRedirect();
      },
    );
  }
}

// Widgets auxiliares para não precisar recarregar a tela toda
class _WelcomeRedirect extends StatelessWidget {
  const _WelcomeRedirect();

  @override
  Widget build(BuildContext context) {
    // Navega para a Welcome logo após o primeiro frame
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
    // Navega para o Dashboard logo após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.patientDashboard);
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}