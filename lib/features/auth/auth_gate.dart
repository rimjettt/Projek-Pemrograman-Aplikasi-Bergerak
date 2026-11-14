import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/student_profile.dart';
import '../library/library_home.dart';
import 'auth_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StudentProfile registered = const StudentProfile();
  StudentProfile active = const StudentProfile();
  bool loggedIn = false;
  bool registeredSession = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      registered = StudentProfile(
        name: prefs.getString('student_name') ?? '',
        nim: prefs.getString('student_nim') ?? '',
        email: prefs.getString('student_email') ?? '',
      );
    });
  }

  Future<void> _saveProfile(StudentProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_name', profile.name);
    await prefs.setString('student_nim', profile.nim);
    await prefs.setString('student_email', profile.email);

    if (!mounted) return;
    setState(() => registered = profile);
  }

  @override
  Widget build(BuildContext context) {
    if (loggedIn) {
      return LibraryHome(
        profile: active,
        onSaveProfile: (profile) {
          setState(() => active = profile);
          if (registeredSession) {
            _saveProfile(profile);
          }
        },
        onLogout: () => setState(() => loggedIn = false),
      );
    }

    return AuthScreen(
      onRegistrationSuccess: (name, nim, email) {
        _saveProfile(
          StudentProfile(
            name: name.trim(),
            nim: nim.trim(),
            email: email.trim(),
          ),
        );
      },
      onLoginSuccess: (email) {
        setState(() {
          registeredSession = registered.email.isNotEmpty &&
              email.trim().toLowerCase() == registered.email.toLowerCase();
          active = registeredSession
              ? registered
              : StudentProfile(email: email.trim());
          loggedIn = true;
        });
      },
    );
  }
}
