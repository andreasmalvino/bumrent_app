import 'package:get/get.dart';

class AsetModel {
  final String id;
  final String nama;
  final String deskripsi;
  final String kategori;
  final int harga;
  final int? denda;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? kuantitas;
  final int? kuantitasTerpakai;
  final String? satuanUkur;

  // Untuk menampung URL gambar pertama dari tabel foto_aset
  String? imageUrl;

  // Menggunakan RxList untuk membuatnya mutable dan reaktif
  RxList<Map<String, dynamic>> satuanWaktuSewa = <Map<String, dynamic>>[].obs;

  AsetModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    required this.harga,
    this.denda,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.kuantitas,
    this.kuantitasTerpakai,
    this.satuanUkur,
    this.imageUrl,
    List<Map<String, dynamic>>? initialSatuanWaktuSewa,
  }) {
    // Inisialisasi satuanWaktuSewa jika ada data awal
    if (initialSatuanWaktuSewa != null) {
      satuanWaktuSewa.addAll(initialSatuanWaktuSewa);
    }
  }

  factory AsetModel.fromJson(Map<String, dynamic> json) {
    return AsetModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      kategori: json['kategori'] ?? '',
      harga: json['harga'] ?? 0,
      denda: json['denda'],
      status: json['status'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      kuantitas: json['kuantitas'],
      kuantitasTerpakai: json['kuantitas_terpakai'],
      satuanUkur: json['satuan_ukur'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'harga': harga,
      'denda': denda,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'kuantitas': kuantitas,
      'kuantitas_terpakai': kuantitasTerpakai,
      'satuan_ukur': satuanUkur,
    };
  }
}
