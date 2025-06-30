class SewaModel {
  final String id;
  final String userId;
  final String status;
  final DateTime waktuMulai;
  final DateTime waktuSelesai;
  final DateTime tanggalPemesanan;
  final String tipePesanan;
  final int kuantitas;
  // Untuk tunggal
  final String? asetId;
  final String? asetNama;
  final String? asetFoto;
  // Untuk paket
  final String? paketId;
  final String? paketNama;
  final String? paketFoto;
  // Tagihan
  final double totalTagihan;
  // Data warga
  final String wargaNama;
  final String wargaNoHp;
  final String wargaAvatar;
  final double? denda;
  final double? dibayar;
  final double? paidAmount;
  // Add nama_satuan_waktu field
  final String? namaSatuanWaktu;

  SewaModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.tanggalPemesanan,
    required this.tipePesanan,
    required this.kuantitas,
    this.asetId,
    this.asetNama,
    this.asetFoto,
    this.paketId,
    this.paketNama,
    this.paketFoto,
    required this.totalTagihan,
    required this.wargaNama,
    required this.wargaNoHp,
    required this.wargaAvatar,
    this.denda,
    this.dibayar,
    this.paidAmount,
    this.namaSatuanWaktu,
  });

  factory SewaModel.fromJson(Map<String, dynamic> json) {
    return SewaModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      status: json['status'] ?? '',
      waktuMulai: DateTime.parse(
        json['waktu_mulai'] ?? DateTime.now().toIso8601String(),
      ),
      waktuSelesai: DateTime.parse(
        json['waktu_selesai'] ?? DateTime.now().toIso8601String(),
      ),
      tanggalPemesanan: DateTime.parse(
        json['tanggal_pemesanan'] ?? DateTime.now().toIso8601String(),
      ),
      tipePesanan: json['tipe_pesanan'] ?? '',
      kuantitas: json['kuantitas'] ?? 1,
      asetId: json['aset_id'],
      asetNama: json['aset_nama'],
      asetFoto: json['aset_foto'],
      paketId: json['paket_id'],
      paketNama: json['paket_nama'],
      paketFoto: json['paket_foto'],
      totalTagihan:
          (json['total_tagihan'] is num)
              ? json['total_tagihan'].toDouble()
              : double.tryParse(json['total_tagihan']?.toString() ?? '0') ?? 0,
      wargaNama: json['warga_nama'] ?? '',
      wargaNoHp: json['warga_no_hp'] ?? '',
      wargaAvatar: json['warga_avatar'] ?? '',
      denda:
          (json['denda'] is num)
              ? json['denda'].toDouble()
              : double.tryParse(json['denda']?.toString() ?? '0'),
      dibayar:
          (json['dibayar'] is num)
              ? json['dibayar'].toDouble()
              : double.tryParse(json['dibayar']?.toString() ?? '0'),
      paidAmount:
          (json['paid_amount'] is num)
              ? json['paid_amount'].toDouble()
              : double.tryParse(json['paid_amount']?.toString() ?? '0'),
      namaSatuanWaktu: json['nama_satuan_waktu'],
    );
  }
}
