import 'package:get/get.dart';

class AsetModel {
  final String id;
  final String nama;
  final String deskripsi;
  final String kategori;
  final String jenis; // Add this line
  final int harga;
  final int? denda;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? kuantitas;
  final int? kuantitasTerpakai;
  final String? satuanUkur;

  // URL gambar utama (untuk backward compatibility)
  String? imageUrl;
  
  // List untuk menyimpan semua URL gambar aset
  final RxList<String> imageUrls = <String>[].obs;

  // Menggunakan RxList untuk membuatnya mutable dan reaktif
  final RxList<Map<String, dynamic>> satuanWaktuSewa = <Map<String, dynamic>>[].obs;

  AsetModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    this.jenis = 'Sewa', // Add this line with default value
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

  // Menambahkan URL gambar dari JSON
  void addImageUrl(String? url) {
    if (url != null && url.isNotEmpty && !imageUrls.contains(url)) {
      imageUrls.add(url);
      // Update imageUrl untuk backward compatibility
      if (imageUrl == null) {
        imageUrl = url;
      }
    }
  }

  // Menghapus URL gambar
  bool removeImageUrl(String url) {
    final removed = imageUrls.remove(url);
    if (removed && imageUrl == url) {
      imageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
    }
    return removed;
  }

  factory AsetModel.fromJson(Map<String, dynamic> json) {
    final model = AsetModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      kategori: json['kategori'] ?? '',
      jenis: json['jenis'] ?? 'Sewa',
      harga: json['harga'] ?? 0,
      denda: json['denda'],
      status: json['status'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      kuantitas: json['kuantitas'],
      kuantitasTerpakai: json['kuantitas_terpakai'],
      satuanUkur: json['satuan_ukur'],
      imageUrl: json['foto_aset'],
      initialSatuanWaktuSewa: json['satuan_waktu_sewa'] != null
          ? List<Map<String, dynamic>>.from(json['satuan_waktu_sewa'])
          : null,
    );
    
    // Add the main image URL to the list if it exists
    if (json['foto_aset'] != null) {
      model.addImageUrl(json['foto_aset']);
    }
    
    // Add any additional image URLs if they exist in the JSON
    if (json['foto_aset_tambahan'] != null) {
      final additionalImages = List<String>.from(json['foto_aset_tambahan']);
      for (final url in additionalImages) {
        model.addImageUrl(url);
      }
    }
    
    return model;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
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

    // Add image URLs if they exist
    if (imageUrls.isNotEmpty) {
      data['foto_aset'] = imageUrl;
      
      // Add additional images (excluding the main image)
      final additionalImages = imageUrls.where((url) => url != imageUrl).toList();
      if (additionalImages.isNotEmpty) {
        data['foto_aset_tambahan'] = additionalImages;
      }
    }

    // Add rental time units if they exist
    if (satuanWaktuSewa.isNotEmpty) {
      data['satuan_waktu_sewa'] = satuanWaktuSewa.toList();
    }

    return data;
  }
}
