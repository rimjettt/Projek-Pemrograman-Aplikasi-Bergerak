import 'package:flutter/material.dart';

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
    if (oldWidget.profile != widget.profile) {
      nameController.text = widget.profile.name;
      nimController.text = widget.profile.nim;
      emailController.text = widget.profile.email;
    }
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
    } else if (nim.isEmpty || int.tryParse(nim) == null) {
      error = 'NIM harus berupa angka dan tidak boleh kosong.';
    } else if (!email.contains('@') || !email.contains('.')) {
      error = 'Masukkan alamat email yang valid.';
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    widget.onSave(
      StudentProfile(name: name, nim: nim, email: email),
    );
    setState(() => editing = false);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari PustakaKu?',
        ),
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

    if (confirmed == true) {
      widget.onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Profil Mahasiswa',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
        const SizedBox(height: 14),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: pale,
                  child: Icon(Icons.person, color: navy, size: 42),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.profile.name.isEmpty
                      ? 'Nama Mahasiswa'
                      : widget.profile.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: navy,
                  ),
                ),
                const Text(
                  'Akun mahasiswa',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _profileField(
          'Nama lengkap',
          nameController,
          readOnly: !editing,
        ),
        const SizedBox(height: 10),
        _profileField(
          'NIM',
          nimController,
          readOnly: !editing,
          type: TextInputType.number,
        ),
        const SizedBox(height: 10),
        _profileField(
          'Email',
          emailController,
          readOnly: !editing,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        if (!editing)
          FilledButton.icon(
            onPressed: () => setState(() => editing = true),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profil'),
          )
        else ...[
          FilledButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save),
            label: const Text('Simpan Perubahan'),
          ),
          OutlinedButton(
            onPressed: () {
              nameController.text = widget.profile.name;
              nimController.text = widget.profile.nim;
              emailController.text = widget.profile.email;
              setState(() => editing = false);
            },
            child: const Text('Batal'),
          ),
        ],
        const SizedBox(height: 12),
        const Text(
          'Pastikan data profil yang tersimpan sudah sesuai dengan identitas Anda.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _confirmLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }

  Widget _profileField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    TextInputType? type,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: type,
      decoration: InputDecoration(labelText: label),
    );
  }
}
