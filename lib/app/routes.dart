import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // IMPORT ADICIONADO

import '../screens/welcome/welcome_page.dart';
import '../screens/profile_choice/profile_choice_page.dart';
import '../screens/auth/auth_choice_page.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/signup_page.dart';
import '../screens/patient/dashboard/patient_dashboard_page.dart';
import '../screens/patient/profile/profile_page.dart';
import '../screens/patient/profile/edit_profile_page.dart';
import '../screens/patient/meal/register_meal_page.dart';
import '../screens/patient/diary/diary_page.dart';
import '../screens/patient/evolution/evolution_page.dart';
import '../screens/patient/evolution/register_weight_page.dart';
import '../screens/patient/symptoms/report_symptoms_page.dart';
import '../screens/patient/anamnesis/fill_anamnesis_page.dart';
import '../screens/nutritionist/dashboard/nutritionist_dashboard_page.dart';
import '../screens/nutritionist/patients/patients_page.dart';
import '../screens/nutritionist/patients/patient_detail_page.dart';
import '../screens/nutritionist/messages/nutritionist_messages_page.dart';
import '../screens/nutritionist/profile/nutritionist_profile_page.dart';
import '../screens/nutritionist/profile/edit_nutritionist_profile_page.dart';
import '../screens/chat/chat_page.dart';
import '../screens/test/avatar_test_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String welcome = '/';
  static const String profileChoice = '/profile-choice';
  static const String authChoice = '/auth-choice';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String patientDashboard = '/patient-dashboard';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String registerMeal = '/register-meal';
  static const String diary = '/diary';
  static const String evolution = '/evolution';
  static const String registerWeight = '/register-weight';
  static const String reportSymptoms = '/report-symptoms';
  static const String fillAnamnesis = '/fill-anamnesis';
  static const String nutritionistDashboard = '/nutritionist-dashboard';
  static const String nutritionistPatients = '/nutritionist-patients';
  static const String nutritionistPatientDetail = '/nutritionist-patient-detail';
  static const String nutritionistMessages = '/nutritionist-messages';
  static const String nutritionistProfile = '/nutritionist-profile';
  static const String editNutritionistProfile = '/edit-nutritionist-profile';
  static const String patientChat = '/patient-chat';
  static const String nutritionistChat = '/nutritionist-chat';

  static Map<String, WidgetBuilder> get routes {
    return {
      welcome: (_) => const WelcomePage(),
      profileChoice: (_) => const ProfileChoicePage(),
      authChoice: (_) => const AuthChoicePage(),
      login: (_) => const LoginPage(),
      signup: (_) => const SignupPage(),
      patientDashboard: (_) => const PatientDashboardPage(),
      profile: (_) => const ProfilePage(),
      editProfile: (_) => const EditProfilePage(),
      registerMeal: (_) => const RegisterMealPage(),
      diary: (_) => const DiaryPage(),
      evolution: (_) => const EvolutionPage(),
      registerWeight: (_) => const RegisterWeightPage(),
      reportSymptoms: (_) => const ReportSymptomsPage(),
      fillAnamnesis: (_) => const FillAnamnesisPage(),
      nutritionistDashboard: (_) => const NutritionistDashboardPage(),
      nutritionistPatients: (_) => const PatientsPage(),
      nutritionistPatientDetail: (_) => const PatientDetailPage(),
      nutritionistMessages: (_) => const NutritionistMessagesPage(),
      nutritionistProfile: (_) => const NutritionistProfilePage(),
      editNutritionistProfile: (_) => const EditNutritionistProfilePage(),
      
      // CHAT DO PACIENTE: Busca o nome real da nutricionista no banco
      patientChat: (context) {
        final user = Supabase.instance.client.auth.currentUser;
        
        // Se não estiver logado, retorna um nome padrão
        if (user == null) {
          return const ChatPage(isNutritionist: false, otherPartyName: 'Minha Nutricionista');
        }

        return FutureBuilder<Map<String, dynamic>?>(
          future: Supabase.instance.client
              .from('patient_profiles')
              .select('nutritionist_profiles(name)')
              .eq('user_id', user.id)
              .maybeSingle(),
          builder: (context, snapshot) {
            String nutriName = 'Minha Nutricionista';
            
            if (snapshot.hasData && snapshot.data != null) {
              final data = snapshot.data!;
              if (data['nutritionist_profiles'] != null) {
                nutriName = data['nutritionist_profiles']['name'] as String? ?? nutriName;
              }
            }

            return ChatPage(
              isNutritionist: false, 
              otherPartyName: nutriName,
            );
          },
        );
      },
      
      // CHAT DO NUTRICIONISTA: Pega os argumentos enviados pela lista
      nutritionistChat: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return ChatPage(
          isNutritionist: true, 
          otherPartyName: args?['name'] ?? 'Paciente',
          patientId: args?['patientId'],
        );
      },
      
      '/avatar-test': (_) => const AvatarTestPage(),
    };
  }

  static void go(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  static void back(BuildContext context) {
    Navigator.pop(context);
  }
}