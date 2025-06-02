class SatuanWaktuModel {
  final String id;
  final String namaSatuanWaktu;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SatuanWaktuModel({
    required this.id,
    required this.namaSatuanWaktu,
    this.createdAt,
    this.updatedAt,
  });

  factory SatuanWaktuModel.fromJson(Map<String, dynamic> json) {
    return SatuanWaktuModel(
      id: json['id'] ?? '',
      namaSatuanWaktu: json['nama_satuan_waktu'] ?? '',
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
      'nama_satuan_waktu': namaSatuanWaktu,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
