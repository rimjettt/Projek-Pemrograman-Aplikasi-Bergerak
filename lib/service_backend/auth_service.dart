
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTRASI MAHASISWA
  Future<void> register({
    required String name,
    required String nim,
    required String email,
    required String password,
  }) async {
    UserCredential credential =
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Registrasi gagal.');
    }

    try {
      await _firestore.collection('pengguna').doc(user.uid).set({
        'nama': name.trim(),
        'nim': nim.trim(),
        'email': email.trim(),
        'peran': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _auth.signOut();
    } catch (e) {
      await user.delete();
      rethrow;
    }
  }

  // LOGIN ADMIN DAN MAHASISWA
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Akun Firebase tidak ditemukan.');
    }

    try {
      print('LOGIN UID: ${user.uid}');
      print('LOGIN EMAIL: ${user.email}');

      final document = await _firestore
          .collection('pengguna')
          .doc(user.uid)
          .get();

      if (!document.exists || document.data() == null) {
        throw Exception(
          'Dokumen pengguna tidak ditemukan untuk UID: ${user.uid}',
        );
      }

      final data = document.data()!;

      final role = data['peran']
          ?.toString()
          .trim()
          .toLowerCase();

      print('LOGIN ROLE: $role');

      if (role != 'admin' && role != 'user') {
        throw Exception('Peran akun tidak valid: $role');
      }

      return role!;
    } catch (e) {
      print('ERROR LOGIN: $e');

      await _auth.signOut();

      rethrow;
    }
  }

  // MENGAMBIL PROFIL MAHASISWA
  Future<StudentProfile> getStudentProfile(String uid) async {
    final document = await _firestore
        .collection('pengguna')
        .doc(uid)
        .get();

    if (!document.exists || document.data() == null) {
      throw Exception('Data profil mahasiswa tidak ditemukan.');
    }

    final data = document.data()!;

    return StudentProfile(
      name: data['nama'] ?? '',
      nim: data['nim'] ?? '',
      email: data['email'] ?? '',
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
