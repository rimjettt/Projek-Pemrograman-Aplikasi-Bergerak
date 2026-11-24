
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../admin/layouts/admin_layout.dart';
import '../../models/student_profile.dart';
import '../../service_backend/auth_service.dart';
import '../library/library_home.dart';
import 'auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static final AuthService _authService = AuthService();

  Future<void> _saveProfile(
      String uid,
      StudentProfile profile,
      ) async {
    await FirebaseFirestore.instance
        .collection('pengguna')
        .doc(uid)
        .update({
      'nama': profile.name.trim(),
      'nim': profile.nim.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // Menunggu status autentikasi
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Jika terjadi error autentikasi
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Terjadi kesalahan autentikasi.'),
            ),
          );
        }

        final user = snapshot.data;

        // Jika belum login, gunakan satu halaman login
        if (user == null) {
          return AuthScreen(
            onRegistrationSuccess: (
                name,
                nim,
                email,
                password,
                ) {
              return _authService.register(
                name: name,
                nim: nim,
                email: email,
                password: password,
              );
            },
            onLoginSuccess: (email, password) {
              return _authService.login(
                email: email,
                password: password,
              );
            },
          );
        }

        // Jika sudah login, periksa peran akun di Firestore
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('pengguna')
              .doc(user.uid)
              .get(),

          builder: (context, roleSnapshot) {

            if (roleSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Jika profil tidak ditemukan
            if (roleSnapshot.hasError ||
                !roleSnapshot.hasData ||
                !roleSnapshot.data!.exists) {
              return _errorPage(
                'Data akun tidak ditemukan.',
              );
            }

            final data = roleSnapshot.data!.data();

            if (data == null) {
              return _errorPage(
                'Data akun tidak valid.',
              );
            }

            final role = data['peran']
                ?.toString()
                .trim()
                .toLowerCase();

            // Jika akun adalah ADMIN
            if (role == 'admin') {
              return const AdminLayout();
            }

            // Jika akun adalah USER
            if (role == 'user') {
              return FutureBuilder<StudentProfile>(
                future: _authService.getStudentProfile(
                  user.uid,
                ),
                builder: (context, profileSnapshot) {

                  if (profileSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (profileSnapshot.hasError ||
                      !profileSnapshot.hasData) {
                    return _errorPage(
                      'Data profil pengguna tidak ditemukan.',
                    );
                  }

                  final profile = profileSnapshot.data!;

                  return LibraryHome(
                    profile: profile,
                    onSaveProfile: (updatedProfile) {
                       _saveProfile(
                        user.uid,
                        updatedProfile,
                      );
                    },
                    onLogout: () {
                      _authService.logout();
                    },
                  );
                },
              );
            }

            // Jika peran tidak dikenal
            return _errorPage(
              'Peran akun tidak dikenali.',
            );
          },
        );
      },
    );
  }

  Widget _errorPage(String message) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _authService.logout();
                },
                child: const Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
