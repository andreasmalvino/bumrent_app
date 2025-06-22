import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/rental_booking_model.dart';
import 'package:flutter/foundation.dart';

class SewaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<SewaModel>> fetchAllSewa() async {
    // 1) Ambil semua sewa_aset
    final sewaData =
        await _supabase.from('sewa_aset').select('''
          id,
          user_id,
          status,
          waktu_mulai,
          waktu_selesai,
          tanggal_pemesanan,
          tipe_pesanan,
          kuantitas,
          aset_id,
          paket_id
        ''')
            as List<dynamic>;

    if (sewaData.isEmpty) return [];

    // Konversi dasar ke map
    final List<Map<String, dynamic>> rawSewa =
        sewaData.map((e) => e as Map<String, dynamic>).toList();

    // Kumpulkan semua ID
    final sewaIds = rawSewa.map((e) => e['id'] as String).toList();
    final userIds = rawSewa.map((e) => e['user_id'] as String).toSet().toList();

    // Pisahkan aset dan paket IDs
    final asetIds =
        rawSewa
            .where((e) => e['tipe_pesanan'] == 'tunggal')
            .map((e) => e['aset_id'] as String?)
            .whereType<String>()
            .toSet()
            .toList();
    final paketIds =
        rawSewa
            .where((e) => e['tipe_pesanan'] == 'paket')
            .map((e) => e['paket_id'] as String?)
            .whereType<String>()
            .toSet()
            .toList();

    // 2) Ambil tagihan_sewa
    final tagihanData =
        await _supabase
                .from('tagihan_sewa')
                .select('sewa_aset_id, total_tagihan, denda, tagihan_dibayar')
                .filter('sewa_aset_id', 'in', '(${sewaIds.join(",")})')
            as List<dynamic>;
    final Map<String, Map<String, dynamic>> mapTagihan = {
      for (var t in tagihanData)
        t['sewa_aset_id'] as String: t as Map<String, dynamic>,
    };

    // 3) Ambil data warga_desa
    final wargaData =
        await _supabase
                .from('warga_desa')
                .select('user_id, nama_lengkap, no_hp, avatar')
                .filter('user_id', 'in', '(${userIds.join(",")})')
            as List<dynamic>;
    debugPrint('DEBUG wargaData (raw): ' + wargaData.toString());
    final Map<String, Map<String, String>> mapWarga = {
      for (var w in wargaData)
        (w['user_id'] as String): {
          'nama': w['nama_lengkap'] as String? ?? '-',
          'noHp': w['no_hp'] as String? ?? '-',
          'avatar': w['avatar'] as String? ?? '-',
        },
    };
    debugPrint('DEBUG mapWarga (mapped): ' + mapWarga.toString());

    // 4) Ambil data aset (untuk tunggal)
    Map<String, Map<String, String>> mapAset = {};
    if (asetIds.isNotEmpty) {
      final asetData =
          await _supabase
                  .from('aset')
                  .select('id, nama')
                  .filter('id', 'in', '(${asetIds.join(",")})')
              as List<dynamic>;
      final fotoData =
          await _supabase
                  .from('foto_aset')
                  .select('id_aset, foto_aset')
                  .filter('id_aset', 'in', '(${asetIds.join(",")})')
              as List<dynamic>;

      // Map aset id → nama
      mapAset = {
        for (var a in asetData)
          (a['id'] as String): {'nama': a['nama'] as String},
      };
      // Ambil foto pertama per aset
      for (var f in fotoData) {
        final aid = f['id_aset'] as String;
        if (mapAset.containsKey(aid) && mapAset[aid]!['foto'] == null) {
          mapAset[aid]!['foto'] = f['foto_aset'] as String;
        }
      }
    }

    // 5) Ambil data paket (untuk paket)
    Map<String, Map<String, String>> mapPaket = {};
    if (paketIds.isNotEmpty) {
      final paketData =
          await _supabase
                  .from('paket')
                  .select('id, nama')
                  .filter('id', 'in', '(${paketIds.join(",")})')
              as List<dynamic>;
      final fotoData =
          await _supabase
                  .from('foto_aset')
                  .select('id_paket, foto_aset')
                  .filter('id_paket', 'in', '(${paketIds.join(",")})')
              as List<dynamic>;

      mapPaket = {
        for (var p in paketData)
          (p['id'] as String): {'nama': p['nama'] as String},
      };
      for (var f in fotoData) {
        final pid = f['id_paket'] as String;
        if (mapPaket.containsKey(pid) && mapPaket[pid]!['foto'] == null) {
          mapPaket[pid]!['foto'] = f['foto_aset'] as String;
        }
      }
    }

    // Debug print hasil query utama
    debugPrint('sewaData: ' + sewaData.toString());
    debugPrint('sewaData count: ' + sewaData.length.toString());
    debugPrint('tagihanData: ' + tagihanData.toString());
    debugPrint('wargaData: ' + wargaData.toString());
    debugPrint('mapAset: ' + mapAset.toString());
    debugPrint('mapPaket: ' + mapPaket.toString());

    // 6) Gabungkan dan bangun SewaModel
    final List<SewaModel> result = [];
    for (var row in rawSewa) {
      final id = row['id'] as String;
      final tipe = row['tipe_pesanan'] as String;
      final warga = mapWarga[row['user_id']];
      final tagihan = mapTagihan[id];
      if (warga == null || tagihan == null) {
        // Skip data jika relasi tidak ditemukan
        continue;
      }
      result.add(
        SewaModel(
          id: id,
          userId: row['user_id'],
          status: row['status'] as String,
          waktuMulai: DateTime.parse(row['waktu_mulai'] as String),
          waktuSelesai: DateTime.parse(row['waktu_selesai'] as String),
          tanggalPemesanan: DateTime.parse(row['tanggal_pemesanan'] as String),
          tipePesanan: tipe,
          kuantitas: row['kuantitas'] as int,
          asetId: tipe == 'tunggal' ? row['aset_id'] as String : null,
          asetNama:
              (row['aset_id'] != null &&
                      tipe == 'tunggal' &&
                      mapAset[row['aset_id']] != null)
                  ? mapAset[row['aset_id']]!['nama']
                  : null,
          asetFoto:
              (row['aset_id'] != null &&
                      tipe == 'tunggal' &&
                      mapAset[row['aset_id']] != null)
                  ? mapAset[row['aset_id']]!['foto']
                  : null,
          paketId: tipe == 'paket' ? row['paket_id'] as String : null,
          paketNama:
              (row['paket_id'] != null &&
                      tipe == 'paket' &&
                      mapPaket[row['paket_id']] != null)
                  ? mapPaket[row['paket_id']]!['nama']
                  : null,
          paketFoto:
              (row['paket_id'] != null &&
                      tipe == 'paket' &&
                      mapPaket[row['paket_id']] != null)
                  ? mapPaket[row['paket_id']]!['foto']
                  : null,
          totalTagihan:
              tagihan['total_tagihan'] != null
                  ? (tagihan['total_tagihan'] as num?)?.toDouble() ?? 0.0
                  : 0.0,
          denda:
              tagihan['denda'] != null
                  ? (tagihan['denda'] as num?)?.toDouble()
                  : null,
          dibayar:
              tagihan['tagihan_dibayar'] != null
                  ? (tagihan['tagihan_dibayar'] as num?)?.toDouble()
                  : null,
          paidAmount:
              tagihan['total_tagihan'] != null
                  ? (tagihan['total_tagihan'] as num?)?.toDouble()
                  : null,
          wargaNama: warga['nama'] ?? '-',
          wargaNoHp: warga['noHp'] ?? '-',
          wargaAvatar: warga['avatar'] ?? '-',
        ),
      );
    }

    // Debug print hasil query result
    debugPrint('SewaModel result: ' + result.toString());
    debugPrint('SewaModel result count: ' + result.length.toString());
    return result;
  }
}
