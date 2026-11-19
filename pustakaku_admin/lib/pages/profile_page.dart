import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/admin_page_frame.dart';
import '../widgets/admin_section_card.dart';
import '../widgets/labeled_form_fields.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _idController;
  late final TextEditingController _emailController;
  late final TextEditingController _roleController;

  bool _editing = false;
  String _name = 'Nadia Prameswari';
  String _adminId = 'ADM-001';
  String _email = 'nadia@pustakaku.id';
  String _role = 'Administrator Perpustakaan';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _name);
    _idController = TextEditingController(text: _adminId);
    _emailController = TextEditingController(text: _email);
    _roleController = TextEditingController(text: _role);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _startEditing() {
    _nameController.text = _name;
    _idController.text = _adminId;
    _emailController.text = _email;
    _roleController.text = _role;
    setState(() => _editing = true);
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final adminId = _idController.text.trim();
    final email = _emailController.text.trim();
    final role = _roleController.text.trim();

    String? error;
    if (name.isEmpty || adminId.isEmpty || role.isEmpty) {
      error = 'Semua informasi profil wajib diisi.';
    } else if (!email.contains('@') || !email.contains('.')) {
      error = 'Masukkan alamat email yang valid.';
    }

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() {
      _name = name;
      _adminId = adminId;
      _email = email;
      _role = role;
      _editing = false;
    });
  }

  void _cancelEditing() {
    _nameController.text = _name;
    _idController.text = _adminId;
    _emailController.text = _email;
    _roleController.text = _role;
    setState(() => _editing = false);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari PustakaKu?'),
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

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitur logout belum tersedia pada demo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminPageFrame(
        maxWidth: 920,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Profil Admin',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 14),
            _buildProfileCard(),
            const SizedBox(height: 14),
            AdminSectionCard(
              title: 'Informasi Akun',
              child: Column(
                children: [
                  _AccountInfoRow(label: 'Status akun', value: 'Aktif'),
                  const Divider(height: 20),
                  _AccountInfoRow(
                    label: 'Hak akses',
                    value: 'Admin perpustakaan',
                  ),
                  const Divider(height: 20),
                  const _AccountInfoRow(
                    label: 'Metode masuk',
                    value: 'Email dan kata sandi',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wideLayout = constraints.maxWidth >= 620;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(wideLayout),
                const SizedBox(height: 24),
                if (constraints.maxWidth >= 620)
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildProfileField(
                              'Nama Lengkap',
                              _nameController,
                              hintText: 'Masukkan nama lengkap',
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildProfileField(
                              'ID Admin',
                              _idController,
                              hintText: 'Masukkan ID admin',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildProfileField(
                              'Email',
                              _emailController,
                              type: TextInputType.emailAddress,
                              hintText: 'Masukkan alamat email',
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildProfileField(
                              'Jabatan',
                              _roleController,
                              hintText: 'Masukkan jabatan',
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildProfileField(
                        'Nama Lengkap',
                        _nameController,
                        hintText: 'Masukkan nama lengkap',
                      ),
                      const SizedBox(height: 18),
                      _buildProfileField(
                        'ID Admin',
                        _idController,
                        hintText: 'Masukkan ID admin',
                      ),
                      const SizedBox(height: 18),
                      _buildProfileField(
                        'Email',
                        _emailController,
                        type: TextInputType.emailAddress,
                        hintText: 'Masukkan alamat email',
                      ),
                      const SizedBox(height: 18),
                      _buildProfileField(
                        'Jabatan',
                        _roleController,
                        hintText: 'Masukkan jabatan',
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                _buildProfileActions(wideLayout),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool wideLayout) {
    final avatar = const CircleAvatar(
      radius: 38,
      backgroundColor: AppColors.pale,
      child: Icon(Icons.person, color: AppColors.navy, size: 42),
    );
    final identity = Column(
      crossAxisAlignment: wideLayout
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          _name,
          textAlign: wideLayout ? TextAlign.start : TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _role,
          textAlign: wideLayout ? TextAlign.start : TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );

    if (wideLayout) {
      return Row(
        children: [
          avatar,
          const SizedBox(width: 16),
          Expanded(child: identity),
        ],
      );
    }

    return Column(children: [avatar, const SizedBox(height: 10), identity]);
  }

  Widget _buildProfileActions(bool wideLayout) {
    if (wideLayout) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _editing
            ? [
                OutlinedButton(
                  onPressed: _cancelEditing,
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Perubahan'),
                ),
              ]
            : [
                FilledButton.icon(
                  onPressed: _startEditing,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profil'),
                ),
              ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _editing
          ? [
              FilledButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Perubahan'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _cancelEditing,
                child: const Text('Batal'),
              ),
            ]
          : [
              FilledButton.icon(
                onPressed: _startEditing,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profil'),
              ),
            ],
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller, {
    TextInputType? type,
    String? hintText,
  }) {
    return LabeledTextFormField(
      label: label,
      controller: controller,
      hintText: hintText,
      keyboardType: type,
      readOnly: !_editing,
    );
  }
}

class _AccountInfoRow extends StatelessWidget {
  const _AccountInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
