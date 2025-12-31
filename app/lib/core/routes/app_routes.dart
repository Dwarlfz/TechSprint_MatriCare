import 'package:flutter/material.dart';

import '../../ui/screens/home/home_page.dart';
import '../../ui/screens/vitals/vitals_page.dart';
import '../../ui/screens/pregnancy/pregnancy_page.dart';
import '../../ui/screens/doctor/doctor_page.dart';
import '../../ui/screens/settings/settings_page.dart';
import '../../ui/screens/auth/login_page.dart';
import '../../ui/screens/auth/signup_page.dart';

// New pages you mentioned
import '../../ui/screens/drawer_pages/profile_page.dart';
import '../../ui/screens/settings/change_password_page.dart';
import '../../ui/screens/settings/doctor_contact_page.dart';
import '../../ui/screens/settings/Language_page.dart';
import '../../ui/screens/settings/Theme_togglepage.dart';
import '../../ui/screens/settings/Notification_settings_page.dart';
import '../../ui/screens/settings/help_center_page.dart';
import '../../ui/screens/settings/feedback_page.dart';
import '../../ui/screens/auth/family_login_page.dart';
import '../../data/models/user_model.dart';
import '../../ui/screens/profile/profile_details.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';

  static const String home = '/home';
  static const String vitals = '/vitals';
  static const String pregnancy = '/pregnancy';
  static const String doctors = '/doctors';
  static const String settings = '/settings';

  // Newly added routes
  static const String updateProfile = '/update-profile';
  static const String changePassword = '/change-password';
  static const String doctorContact = '/doctor-contact';

  static const String language = '/language';
  static const String theme = '/theme';
  static const String notificationSettings = '/notification-settings';
  static const String helpCenter = '/help-center';
  static const String feedback = '/feedback';
  static const String familyLoginPage= '/family-login-page';
  static const String profileDetails='/profile-details';
  static const String initialRoute = login;
  
  UserModel? user;
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());

      case home:
        final uid = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => HomePage(uid: uid));

      case vitals:
        return MaterialPageRoute(builder: (_) => const VitalPage());

      case pregnancy:
        return MaterialPageRoute(builder: (_) => const PregnancyPage());

      case doctors:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => DoctorsPage(user: user));

      case '/settings':
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => SettingsPage(user: user));

      /// NEW ROUTES ↓↓↓
      case AppRoutes.profileDetails: // define constant earlier
        final uid = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ProfileDetailsPage(user: user!));

      case updateProfile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());

      case AppRoutes.doctorContact:
        final uid = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => DoctorContactPage(uid: uid),
        );

      case AppRoutes.language:
        return MaterialPageRoute(builder: (_) => const LanguagePage());

      case AppRoutes.theme:
        return MaterialPageRoute(builder: (_) => const ThemePage());

      case AppRoutes.notificationSettings:
        return MaterialPageRoute(builder: (_) => const NotificationSettingsPage());

      case AppRoutes.helpCenter:
        return MaterialPageRoute(builder: (_) => const HelpCenterPage());

      case AppRoutes.feedback:
        return MaterialPageRoute(builder: (_) => FeedbackPage());

      case AppRoutes.familyLoginPage:
        final token = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => FamilyLoginPage(token: token),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route not found")),
          ),
        );
    }
  }
}
