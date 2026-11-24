
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Memeriksa email dan password melalui Firebase Authentication
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Data akun tidak ditemukan.');
      }

      // 2. Mengambil profil berdasarkan UID pengguna
      final profile = await _firestore
          .collection('pengguna')
          .doc(user.uid)
          .get();

      if (!profile.exists || profile.data() == null) {
        await _auth.signOut();
        throw Exception('Data profil tidak ditemukan.');
      }

      // 3. Memeriksa peran akun
      final data = profile.data()!;
      final role = data['peran']?.toString().toLowerCase();

      if (role != 'admin') {
        await _auth.signOut();
        throw Exception('Akun ini tidak memiliki akses Admin.');
      }

      // Login berhasil jika profil memiliki peran admin.
    } catch (e) {
      if (e is FirebaseAuthException) {
        rethrow;
      }

      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
