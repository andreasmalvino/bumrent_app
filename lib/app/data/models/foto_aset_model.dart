class FotoAsetModel {
  final String id;
  final String fotoAset; // URL foto
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String idAset;

  FotoAsetModel({
    required this.id,
    required this.fotoAset,
    this.createdAt,
    this.updatedAt,
    required this.idAset,
  });

  factory FotoAsetModel.fromJson(Map<String, dynamic> json) {
    return FotoAsetModel(
      id: json['id'] ?? '',
      fotoAset: json['foto_aset'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      idAset: json['id_aset'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foto_aset': fotoAset,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'id_aset': idAset,
    };
  }
}
