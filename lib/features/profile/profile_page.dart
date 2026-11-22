import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_colors.dart';
import '../../models/student_profile.dart';

class ProfilePage extends StatefulWidget {
  final StudentProfile profile;
  final ValueChanged<StudentProfile> onSave;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.profile,
    required this.onSave,
    required this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool editing = false;
  late final TextEditingController nameController;
  late final TextEditingController nimController;
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profile.name);
    nimController = TextEditingController(text: widget.profile.nim);
    emailController = TextEditingController(text: widget.profile.email);
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile && !editing) {
      _restoreFields();
    }
  }

  void _restoreFields() {
    nameController.text = widget.profile.name;
    nimController.text = widget.profile.nim;
    emailController.text = widget.profile.email;
  }

  @override
  void dispose() {
    nameController.dispose();
    nimController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name = nameController.text.trim();
    final nim = nimController.text.trim();
    final email = emailController.text.trim();
    String? error;
    if (name.isEmpty) {
      error = 'Nama lengkap wajib diisi.';
    } else if (nim.isEmpty || !RegExp(r'^\d+$').hasMatch(nim)) {
      error = 'NIM harus berisi angka dan tidak boleh kosong.';
    } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      error = 'Masukkan alamat email yang valid.';
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    widget.onSave(StudentProfile(name: name, nim: nim, email: email));
    setState(() => editing = false);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah kamu yakin ingin keluar dari PustakaKu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed == true) widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        final horizontalPadding = constraints.maxWidth < 360 ? 14.0 : 24.0;
        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: wide ? 32 : 24,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Profil Mahasiswa',
                      style: TextStyle(
                        fontSize: wide ? 30 : 26,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: wide ? 30 : 24,
                        ),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 48,
                              backgroundColor: pale,
                              child: Icon(Icons.person, color: navy, size: 52),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.profile.name.isEmpty
                                  ? 'Nama Mahasiswa'
                                  : widget.profile.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: navy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Akun mahasiswa',
                              style: TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Mode normal tetap menampilkan kotak outline statis.
                    // Mode edit menggunakan TextField yang benar-benar bisa diubah.
                    if (editing) ...[
                      _profileField('Nama lengkap', nameController),
                      const SizedBox(height: 14),
                      _profileField(
                        'NIM',
                        nimController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 14),
                      _profileField(
                        'Email',
                        emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ] else ...[
                      _profileInfo('Nama lengkap', widget.profile.name),
                      const SizedBox(height: 14),
                      _profileInfo('NIM', widget.profile.nim),
                      const SizedBox(height: 14),
                      _profileInfo('Email', widget.profile.email),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: editing
                            ? _saveProfile
                            : () => setState(() {
                          _restoreFields();
                          editing = true;
                        }),
                        icon: Icon(editing ? Icons.save_outlined : Icons.edit_outlined),
                        label: Text(editing ? 'Simpan Perubahan' : 'Edit Profil'),
                        style: FilledButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                    if (editing) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => setState(() {
                            _restoreFields();
                            editing = false;
                          }),
                          child: const Text('Batal'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    const Text(
                      'Pastikan data profil yang tersimpan sudah sesuai dengan identitas Anda.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _confirmLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: navy,
                          side: const BorderSide(color: navy),
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _profileInfo(String label, String value) {
    // Mode normal: tampilannya tetap berupa kotak outline seperti TextField,
    // tetapi hanya dekorasi untuk membaca data (bukan input yang bisa ditekan).
    return InputDecorator(
      isEmpty: false,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: const Color(0xFFFFFCF6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF55564F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF55564F)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            color: Color(0xFF292A26),
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _profileField(
      String label,
      TextEditingController controller, {
        TextInputType? keyboardType,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return IgnorePointer(
      // Dalam mode normal, kotak tetap terlihat seperti TextField,
      // tetapi tidak merespons ketukan atau memunculkan keyboard.
      ignoring: !editing,
      child: TextField(
        controller: controller,
        readOnly: !editing,
        showCursor: editing,
        enableInteractiveSelection: editing,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        autocorrect: keyboardType != TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFFFFCF6),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF55564F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF55564F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: navy, width: 2),
          ),
        ),
      ),
    );
  }
}
