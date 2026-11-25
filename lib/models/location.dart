/// Model lokasi (kota) hasil pencarian Geocoding API Open-Meteo.
/// Juga dipakai untuk menyimpan lokasi favorit di Local Storage.
class Location {
  final String name;
  final String? admin1; // provinsi / wilayah
  final String country;
  final double latitude;
  final double longitude;

  const Location({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  /// Dari JSON Geocoding API (`results[]`).
  factory Location.fromGeocodingJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] as String,
      admin1: json['admin1'] as String?,
      country: (json['country'] as String?) ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  /// Dari JSON hasil simpanan Local Storage.
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] as String,
      admin1: json['admin1'] as String?,
      country: (json['country'] as String?) ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'admin1': admin1,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
      };

  /// Contoh: "Jawa Tengah, Indonesia".
  String get subtitle {
    final parts = [
      if (admin1 != null && admin1!.isNotEmpty) admin1!,
      if (country.isNotEmpty) country,
    ];
    return parts.join(', ');
  }

  /// Kunci unik berdasarkan koordinat, dipakai untuk membandingkan lokasi.
  String get key =>
      '${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';

  @override
  bool operator ==(Object other) => other is Location && other.key == key;

  @override
  int get hashCode => key.hashCode;
}
