class UserModel {
  final int id;
  final String nama;
  final String username;
  final String role;

  UserModel({
    required this.id,
    required this.nama,
    required this.username,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nama: (json['nama'] ?? json['name'] ?? json['username'] ?? 'Kasir').toString(),
      username: (json['username'] ?? json['email'] ?? '').toString(),
      role: (json['role'] ?? 'kasir').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'username': username,
      'role': role,
    };
  }
}