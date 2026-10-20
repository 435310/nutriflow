import 'package:flutter/material.dart';

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
      nutritionistDashboard: (_) => const NutritionistDashboardPage(),
      nutritionistPatients: (_) => const PatientsPage(),
      nutritionistPatientDetail: (_) => const PatientDetailPage(),
      nutritionistMessages: (_) => const NutritionistMessagesPage(),
      nutritionistProfile: (_) => const NutritionistProfilePage(),
      editNutritionistProfile: (_) => const EditNutritionistProfilePage(),
      patientChat: (_) => const ChatPage(isNutritionist: false, otherPartyName: 'Dra. Ana'),
      nutritionistChat: (_) => const ChatPage(isNutritionist: true, otherPartyName: 'Maria Silva'),
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