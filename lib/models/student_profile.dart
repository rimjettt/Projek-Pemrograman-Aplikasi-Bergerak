class StudentProfile {
  final String name;
  final String nim;
  final String email;

  const StudentProfile({
    this.name = '',
    this.nim = '',
    this.email = '',
  });

  StudentProfile copyWith({String? name, String? nim, String? email}) {
    return StudentProfile(
      name: name ?? this.name,
      nim: nim ?? this.nim,
      email: email ?? this.email,
    );
  }
}
