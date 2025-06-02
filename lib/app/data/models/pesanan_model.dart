class PesananModel {
  final String id;
  final String asetId;
  final String satuanWaktuId;
  final String userId;
  final String status;
  final DateTime tanggalPemesanan;
  final String jamPemesanan;
  final int durasi;
  final int totalHarga;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Optional fields for joined data from other tables
  String? namaSatuanWaktu;
  String? namaAset;
  String? namaUser;

  PesananModel({
    required this.id,
    required this.asetId,
    required this.satuanWaktuId,
    required this.userId,
    required this.status,
    required this.tanggalPemesanan,
    required this.jamPemesanan,
    required this.durasi,
    required this.totalHarga,
    this.createdAt,
    this.updatedAt,
    this.namaSatuanWaktu,
    this.namaAset,
    this.namaUser,
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    return PesananModel(
      id: json['id'] ?? '',
      asetId: json['aset_id'] ?? '',
      satuanWaktuId: json['satuan_waktu_id'] ?? '',
      userId: json['user_id'] ?? '',
      status: json['status'] ?? 'pending',
      tanggalPemesanan:
          json['tanggal_pemesanan'] != null
              ? DateTime.parse(json['tanggal_pemesanan'])
              : DateTime.now(),
      jamPemesanan: json['jam_pemesanan'] ?? '00:00',
      durasi: json['durasi'] ?? 1,
      totalHarga: json['total_harga'] ?? 0,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      namaSatuanWaktu: json['nama_satuan_waktu'],
      namaAset: json['nama_aset'],
      namaUser: json['nama_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aset_id': asetId,
      'satuan_waktu_id': satuanWaktuId,
      'user_id': userId,
      'status': status,
      'tanggal_pemesanan': tanggalPemesanan.toIso8601String().split('T')[0],
      'jam_pemesanan': jamPemesanan,
      'durasi': durasi,
      'total_harga': totalHarga,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
