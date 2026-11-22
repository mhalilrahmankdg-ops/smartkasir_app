// Model data Pelanggan / Member SmartKasir
class Pelanggan {
  final int? id; // auto increment SQLite
  final String kodePelanggan; // contoh: CUST-001
  final String namaPelanggan;
  final String nomorWa;
  final String alamat;
  final double? latitude; // null jika GPS belum direkam
  final double? longitude;
  final String createdAt;

  Pelanggan({
    this.id,
    required this.kodePelanggan,
    required this.namaPelanggan,
    required this.nomorWa,
    required this.alamat,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  // Dart object -> Map (untuk disimpan ke SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kode_pelanggan': kodePelanggan,
      'nama_pelanggan': namaPelanggan,
      'nomor_wa': nomorWa,
      'alamat': alamat,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt,
    };
  }

  // Map dari SQLite -> Dart object
  factory Pelanggan.fromMap(Map<String, dynamic> map) {
    return Pelanggan(
      id: map['id'] as int?,
      kodePelanggan: map['kode_pelanggan'] as String? ?? '',
      namaPelanggan: map['nama_pelanggan'] as String? ?? '',
      nomorWa: map['nomor_wa'] as String? ?? '',
      alamat: map['alamat'] as String? ?? '',
      latitude:
          map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude:
          map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  // Apakah pelanggan sudah punya titik koordinat GPS?
  bool get hasLocation => latitude != null && longitude != null;

  // Koordinat dalam teks ringkas
  String get coordinateText {
    if (hasLocation) {
      return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
    }
    return 'Belum terekam';
  }
}