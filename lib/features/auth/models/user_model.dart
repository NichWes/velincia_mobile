class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final String? companyName;
  final String? address;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    this.companyName,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? '',
      companyName: json['company_name'],
      address: json['address'],
    );
  }
}
