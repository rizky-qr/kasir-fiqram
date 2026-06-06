class UserModel {
  final int idUser;
  final String namaUser;
  final String username;
  final String level;

  UserModel({
    required this.idUser,
    required this.namaUser,
    required this.username,
    required this.level,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int pInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return UserModel(
      idUser: pInt(json['id_user']),
      namaUser: json['nama_user']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
    );
  }
}
