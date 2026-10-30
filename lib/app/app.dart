import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import 'routes.dart';

// ============================================
// CLASSE PRINCIPAL DO APP
// ============================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1FA774),
        ),
        useMaterial3: true,
      ),
      // O app começa na tela de boas-vindas (welcome), que é a rota '/'
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}

// ============================================
// REDIRECIONAMENTO PÓS-LOGIN (M1)
// ============================================
class DashboardRedirect extends StatefulWidget {
  const DashboardRedirect({super.key});

  @override
  State<DashboardRedirect> createState() => _DashboardRedirectState();
}

class _DashboardRedirectState extends State<DashboardRedirect> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        return;
      }

      final authService = AuthService();
      final profile = await authService.getPatientProfile();

      if (!mounted) return;

      // Verifica se é nutricionista (se tem perfil em nutritionist_profiles)
      final isNutri = await authService.isNutritionist();

      if (isNutri) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.nutritionistDashboard);
      } else if (profile != null) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.patientDashboard);
      } else {
        // Se logou mas não tem perfil (cadastro incompleto)
        Navigator.of(context).pushReplacementNamed(AppRoutes.profileChoice);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}