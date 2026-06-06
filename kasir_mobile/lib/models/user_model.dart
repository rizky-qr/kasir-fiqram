class UserModel {
  final int idUser;
  final String namaUser;
  final String username;
  final String level;
  final String email;
  final String noHp;

  UserModel({
    required this.idUser,
    required this.namaUser,
    required this.username,
    required this.level,
    this.email = '',
    this.noHp = '',
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
      email: json['email']?.toString() ?? '',
      noHp: json['no_hp']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_user': idUser,
        'nama_user': namaUser,
        'username': username,
        'level': level,
        'email': email,
        'no_hp': noHp,
      };
}
