class ChatModel {
  final int idChat;
  final int idPenjualan;
  final String pengirim; // 'admin' atau 'pelanggan'
  final String pesan;
  final String tanggal;

  ChatModel({
    required this.idChat,
    required this.idPenjualan,
    required this.pengirim,
    required this.pesan,
    required this.tanggal,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      idChat: int.tryParse(json['id_chat'].toString()) ?? 0,
      idPenjualan: int.tryParse(json['id_penjualan'].toString()) ?? 0,
      pengirim: json['pengirim'] ?? 'pelanggan',
      pesan: json['pesan'] ?? '',
      tanggal: json['tanggal'] ?? '',
    );
  }
}