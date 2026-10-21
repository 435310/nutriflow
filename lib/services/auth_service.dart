import 'package:supabase_flutter/supabase_flutter.dart';

/// ============================================
/// SERVIÇO DE AUTENTICAÇÃO
/// ============================================
class AuthService {
  // Pega a instância do Supabase
  final SupabaseClient _supabase = Supabase.instance.client;

  // Pega o usuário logado no momento
  User? get currentUser => _supabase.auth.currentUser;

  // Retorna verdadeiro se o usuário estiver logado
  bool get isLoggedIn => currentUser != null;

  // ============================================
  // CADASTRO
  // ============================================
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required bool isNutritionist,
  }) async {
    try {
      // 1. Cria o usuário na autenticação do Supabase
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) return 'Erro ao criar usuário.';

      // 2. Salva os dados extras na tabela correta
      if (isNutritionist) {
        await _supabase.from('nutritionist_profiles').insert({
          'id': user.id,
          'user_id': user.id,
          'name': name.trim(),
          'email': email.trim(),
          'crn': 'A preencher',
          'specialty': 'A preencher',
        });
      } else {
        await _supabase.from('patient_profiles').insert({
          'id': user.id,
          'user_id': user.id,
          'name': name.trim(),
          'email': email.trim(),
        });
      }

      return null; // Sucesso!
    } on AuthException catch (e) {
      return e.message; // Erro de autenticação
    } catch (e) {
      return 'Erro inesperado: $e'; // Outros erros
    }
  }

  // ============================================
  // LOGIN
  // ============================================
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return null; // Sucesso
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }

  // ============================================
  // LOGOUT
  // ============================================
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

    // ============================================
  // BUSCAR PERFIL DO PACIENTE NO BANCO
  // ============================================
  Future<Map<String, dynamic>?> getPatientProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('patient_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Erro ao buscar perfil: $e');
      return null;
    }
  }
}