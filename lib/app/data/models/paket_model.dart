import 'dart:convert';

class PaketModel {
  final String? id;
  final String? nama;
  final String? deskripsi;
  final int? harga;
  final int? kuantitas;
  final String? foto_paket;
  final List<dynamic>? satuanWaktuSewa;
  
  PaketModel({
    this.id,
    this.nama,
    this.deskripsi,
    this.harga,
    this.kuantitas,
    this.foto_paket,
    this.satuanWaktuSewa,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'kuantitas': kuantitas,
      'foto_paket': foto_paket,
      'satuanWaktuSewa': satuanWaktuSewa,
    };
  }

  factory PaketModel.fromMap(Map<String, dynamic> map) {
    return PaketModel(
      id: map['id'],
      nama: map['nama'],
      deskripsi: map['deskripsi'],
      harga: map['harga']?.toInt(),
      kuantitas: map['kuantitas']?.toInt(),
      foto_paket: map['foto_paket'],
      satuanWaktuSewa: map['satuanWaktuSewa'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PaketModel.fromJson(String source) => PaketModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PaketModel(id: $id, nama: $nama, deskripsi: $deskripsi, harga: $harga, kuantitas: $kuantitas, foto_paket: $foto_paket, satuanWaktuSewa: $satuanWaktuSewa)';
  }
}
