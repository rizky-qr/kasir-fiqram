class KotaModel {
  final String cityId;
  final String cityName;
  final String type;
  final String province;

  const KotaModel({
    required this.cityId,
    required this.cityName,
    required this.type,
    required this.province,
  });

  factory KotaModel.fromJson(Map<String, dynamic> json) => KotaModel(
        cityId:   json['city_id']?.toString()   ?? '',
        cityName: json['city_name']?.toString() ?? '',
        type:     json['type']?.toString()      ?? '',
        province: json['province']?.toString()  ?? '',
      );

  String get displayName => '$type $cityName, $province';
}
