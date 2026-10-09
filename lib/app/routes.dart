import 'package:flutter/material.dart';

import '../screens/welcome/welcome_page.dart';
import '../screens/profile_choice/profile_choice_page.dart';
import '../screens/auth/auth_choice_page.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/signup_page.dart';
import '../screens/patient/profile/profile_page.dart';
import '../screens/patient/profile/edit_profile_page.dart';
import '../screens/test/avatar_test_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String welcome = '/';
  static const String profileChoice = '/profile-choice';
  static const String authChoice = '/auth-choice';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  static Map<String, WidgetBuilder> get routes {
    return {
      welcome: (_) => const WelcomePage(),
      profileChoice: (_) => const ProfileChoicePage(),
      authChoice: (_) => const AuthChoicePage(),
      login: (_) => const LoginPage(),
      signup: (_) => const SignupPage(),
      profile: (_) => const ProfilePage(),
      editProfile: (_) => const EditProfilePage(),
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