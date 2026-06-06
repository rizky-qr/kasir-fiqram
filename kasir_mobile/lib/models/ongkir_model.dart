class OngkirResult {
  final String kurir;
  final String service;
  final String deskripsi;
  final int biaya;
  final String estimasi;

  const OngkirResult({
    required this.kurir,
    required this.service,
    required this.deskripsi,
    required this.biaya,
    required this.estimasi,
  });

  factory OngkirResult.fromJson(Map<String, dynamic> json) => OngkirResult(
        kurir:     json['kurir']?.toString()     ?? '',
        service:   json['service']?.toString()   ?? '',
        deskripsi: json['deskripsi']?.toString() ?? '',
        biaya:     int.tryParse(json['biaya']?.toString() ?? '0') ?? 0,
        estimasi:  json['estimasi']?.toString()  ?? '-',
      );

  String get label => '$kurir $service — Estimasi $estimasi hari';
}
