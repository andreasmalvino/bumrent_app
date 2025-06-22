class PembayaranModel {
  final String id;
  final int totalPembayaran;
  final String metodePembayaran;
  final DateTime waktuPembayaran;

  PembayaranModel({
    required this.id,
    required this.totalPembayaran,
    required this.metodePembayaran,
    required this.waktuPembayaran,
  });

  factory PembayaranModel.fromJson(Map<String, dynamic> json) {
    return PembayaranModel(
      id: json['id'] as String,
      totalPembayaran: json['total_pembayaran'] as int,
      metodePembayaran: json['metode_pembayaran'] as String,
      waktuPembayaran: DateTime.parse(json['waktu_pembayaran'] as String),
    );
  }
}
