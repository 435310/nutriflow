import 'package:flutter/material.dart';

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
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
      
      // ⚠️ NOVO: Transição suave entre TODAS as telas
      onGenerateRoute: (settings) {
        final builder = AppRoutes.routes[settings.name];
        if (builder == null) return null;

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Animação de Fade (opacidade) + Slide (deslizar de baixo para cima)
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return FadeTransition(
              opacity: curve,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.05), // Começa 5% mais para baixo
                  end: Offset.zero,
                ).animate(curve),
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}