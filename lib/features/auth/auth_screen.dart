import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class AuthScreen extends StatefulWidget {
  final Future<void> Function(
      String,
      String,
      String,
      String,
      ) onRegistrationSuccess;

  final Future<void> Function(
      String,
      String,
      ) onLoginSuccess;

  const AuthScreen({
    super.key,
    required this.onRegistrationSuccess,
    required this.onLoginSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isRegister = false;
  bool passwordVisible = false;
  bool confirmVisible = false;
  bool loading = false;

  final nama = TextEditingController();
  final nim = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  String message = '';
  bool success = false;

  @override
  void dispose() {
    nama.dispose();
    nim.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final inputEmail = email.text.trim();
    final inputPassword = password.text;
    String? error;

    // Validasi input
    if (inputEmail.isEmpty || inputPassword.isEmpty) {
      error = 'Email dan kata sandi wajib diisi.';
    } else if (!inputEmail.contains('@') || !inputEmail.contains('.')) {
      error = 'Masukkan alamat email yang valid.';
    } else if (inputPassword.length < 6) {
      error = 'Kata sandi minimal 6 karakter.';
    } else if (isRegister && nama.text.trim().isEmpty) {
      error = 'Nama lengkap wajib diisi.';
    } else if (isRegister && nim.text.trim().isEmpty) {
      error = 'NIM wajib diisi.';
    } else if (isRegister && inputPassword != confirm.text) {
      error = 'Konfirmasi kata sandi tidak sama.';
    }

    if (error != null) {
      setState(() {
        message = error!;
        success = false;
      });
      return;
    }

    final registering = isRegister;

    setState(() {
      loading = true;
      message = '';
      success = false;
    });

    try {
      if (registering) {
        // Registrasi menggunakan Firebase
        await widget.onRegistrationSuccess(
          nama.text.trim(),
          nim.text.trim(),
          inputEmail,
          inputPassword,
        );

        if (!mounted) return;

        setState(() {
          success = true;
          message = 'Registrasi berhasil. Silakan login.';
        });

        await Future.delayed(const Duration(milliseconds: 1500));

        if (!mounted) return;

        setState(() {
          message = '';
          isRegister = false;
          password.clear();
          confirm.clear();
          passwordVisible = false;
          confirmVisible = false;
        });
      } else {
        // Login menggunakan Firebase
        await widget.onLoginSuccess(
          inputEmail,
          inputPassword,
        );
      }
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Terjadi kesalahan. Silakan coba kembali.';

      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Email sudah terdaftar.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Format email tidak valid.';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Kata sandi terlalu lemah.';
      } else if (e.toString().contains('user-not-found') ||
          e.toString().contains('invalid-credential') ||
          e.toString().contains('wrong-password')) {
        errorMessage = 'Email atau kata sandi salah.';
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = 'Periksa koneksi internet kamu.';
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }

      setState(() {
        success = false;
        message = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }


  Widget _field(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    Widget? suffix,
    TextInputType? type,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffix,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_pustakaku.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isRegister
                        ? 'Daftar akun mahasiswa'
                        : 'Selamat datang kembali!',
                    style: const TextStyle(color: navy),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    isRegister ? 'Registrasi' : 'Login',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (message.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: success
                            ? const Color(0xFFE6F4EA)
                            : const Color(0xFFFDE7E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: success
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (isRegister) ...[
                    _field('Nama lengkap', nama),
                    const SizedBox(height: 12),
                    _field(
                      'NIM',
                      nim,
                      type: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _field(
                    'Email',
                    email,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    'Kata sandi',
                    password,
                    obscure: !passwordVisible,
                    suffix: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => passwordVisible = !passwordVisible);
                      },
                    ),
                  ),
                  if (isRegister) ...[
                    const SizedBox(height: 12),
                    _field(
                      'Konfirmasi kata sandi',
                      confirm,
                      obscure: !confirmVisible,
                      suffix: IconButton(
                        icon: Icon(
                          confirmVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => confirmVisible = !confirmVisible);
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: loading ? null : submit,
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isRegister ? 'Daftar Sekarang' : 'Login',
                            ),
                    ),
                  ),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            setState(() {
                              isRegister = !isRegister;
                              message = '';
                              success = false;
                              passwordVisible = false;
                              confirmVisible = false;
                            });
                          },
                    child: Text(
                      isRegister
                          ? 'Sudah punya akun? Login'
                          : 'Belum punya akun? Daftar',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
