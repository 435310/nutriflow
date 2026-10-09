import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import 'routes.dart';

/// ============================================
/// APLICATIVO NUTRIFLOW
/// ============================================
/// Ponto central do app: define tema, rotas e tela inicial.
class NutriFlowApp extends StatelessWidget {
  const NutriFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Configurações
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // Tema
      theme: AppTheme.light,

      // Rota inicial
      initialRoute: AppRoutes.welcome,

      // Rotas
      routes: AppRoutes.routes,
    );
  }
}