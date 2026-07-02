class UserProfile {
  final String id;
  final String email;
  final String role; // 'client' | 'agency' | 'admin'
  final String fullName;
  final String phone;

  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName = '',
    this.phone = '',
  });

  bool get isAgency => role == 'agency';
  bool get isAdmin => role == 'admin';
}
