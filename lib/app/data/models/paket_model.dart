import 'dart:convert';
import 'dart:developer' as developer;

class PaketModel {
  final String id;
  final String nama;
  final String deskripsi;
  final double harga;
  final int kuantitas;
  final String status;
  List<String> foto;
  List<Map<String, dynamic>> satuanWaktuSewa;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? foto_paket; // Main photo URL
  List<String>? images; // List of photo URLs

  PaketModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.kuantitas,
    this.status = 'aktif',
    required List<String> foto,
    required List<Map<String, dynamic>> satuanWaktuSewa,
    this.foto_paket,
    List<String>? images,
    required this.createdAt,
    required this.updatedAt,
  }) : foto = List.from(foto),
       satuanWaktuSewa = List.from(satuanWaktuSewa),
       images = images != null ? List.from(images) : [];
       
  // Add copyWith method for immutability patterns
  PaketModel copyWith({
    String? id,
    String? nama,
    String? deskripsi,
    double? harga,
    int? kuantitas,
    String? status,
    List<String>? foto,
    List<Map<String, dynamic>>? satuanWaktuSewa,
    String? foto_paket,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaketModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      harga: harga ?? this.harga,
      kuantitas: kuantitas ?? this.kuantitas,
      status: status ?? this.status,
      foto: foto ?? List.from(this.foto),
      satuanWaktuSewa: satuanWaktuSewa ?? List.from(this.satuanWaktuSewa),
      foto_paket: foto_paket ?? this.foto_paket,
      images: images ?? (this.images != null ? List.from(this.images!) : null),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Alias for fromJson to maintain compatibility
  factory PaketModel.fromMap(Map<String, dynamic> json) => PaketModel.fromJson(json);
  
  factory PaketModel.fromJson(Map<String, dynamic> json) {
    // Handle different possible JSON structures
    final fotoList = <String>[];
    
    // Check for different possible photo field names
    if (json['foto'] != null) {
      if (json['foto'] is String) {
        fotoList.add(json['foto']);
      } else if (json['foto'] is List) {
        fotoList.addAll((json['foto'] as List).whereType<String>());
      }
    }
    
    if (json['foto_paket'] != null) {
      if (json['foto_paket'] is String) {
        fotoList.add(json['foto_paket']);
      } else if (json['foto_paket'] is List) {
        fotoList.addAll((json['foto_paket'] as List).whereType<String>());
      }
    }
    
    // Handle satuan_waktu_sewa
    List<Map<String, dynamic>> satuanWaktuList = [];
    if (json['satuan_waktu_sewa'] != null) {
      if (json['satuan_waktu_sewa'] is List) {
        satuanWaktuList = List<Map<String, dynamic>>.from(
          json['satuan_waktu_sewa'].map((x) => x is Map ? Map<String, dynamic>.from(x) : {})
        );
      } else if (json['satuan_waktu_sewa'] is Map) {
        satuanWaktuList = [Map<String, dynamic>.from(json['satuan_waktu_sewa'])];
      }
    }
    
    developer.log('📦 [PaketModel.fromJson] Raw status: ${json['status']} (type: ${json['status']?.runtimeType})');
    final status = json['status']?.toString().toLowerCase() ?? 'aktif';
    developer.log('   🏷️ Processed status: $status');
    
    return PaketModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      status: status,
      harga: (json['harga'] is num) ? (json['harga'] as num).toDouble() : 0.0,
      kuantitas: (json['kuantitas'] is num) ? (json['kuantitas'] as num).toInt() : 1,
      foto: fotoList,
      satuanWaktuSewa: satuanWaktuList,
      foto_paket: json['foto_paket']?.toString(),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'deskripsi': deskripsi,
    'harga': harga,
    'kuantitas': kuantitas,
    'foto': foto,
    'foto_paket': foto_paket,
    'images': images,
    'satuan_waktu_sewa': satuanWaktuSewa,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };


  // Get the first photo URL or a placeholder
  String get firstPhotoUrl => foto.isNotEmpty ? foto.first : '';
  
  // Get the formatted price
  String get formattedPrice => 'Rp${harga.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  )}';
  
  // Check if the package is available
  bool get isAvailable => kuantitas > 0;
  
  // Get the first available time unit
  Map<String, dynamic>? get defaultTimeUnit => 
      satuanWaktuSewa.isNotEmpty ? satuanWaktuSewa.first : null;
  
  // Get the price for a specific time unit
  double getPriceForTimeUnit(String timeUnitId) {
    try {
      final unit = satuanWaktuSewa.firstWhere(
        (unit) => unit['id'] == timeUnitId || unit['id'].toString() == timeUnitId,
      );
      return (unit['harga'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
