class SatuanWaktuSewaModel {
  final String id;
  final String asetId;
  final String satuanWaktuId;
  final int harga;
  final int? denda;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Untuk menyimpan nama satuan waktu (jam/hari) dari tabel satuan_waktu
  String? namaSatuanWaktu;

  SatuanWaktuSewaModel({
    required this.id,
    required this.asetId,
    required this.satuanWaktuId,
    required this.harga,
    this.denda,
    this.createdAt,
    this.updatedAt,
    this.namaSatuanWaktu,
  });

  factory SatuanWaktuSewaModel.fromJson(Map<String, dynamic> json) {
    return SatuanWaktuSewaModel(
      id: json['id'] ?? '',
      asetId: json['aset_id'] ?? '',
      satuanWaktuId: json['satuan_waktu_id'] ?? '',
      harga: json['harga'] ?? 0,
      denda: json['denda'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aset_id': asetId,
      'satuan_waktu_id': satuanWaktuId,
      'harga': harga,
      'denda': denda,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
