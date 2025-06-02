import 'package:bumrent_app/app/data/models/aset_model.dart';
import 'package:bumrent_app/app/data/models/pesanan_model.dart';
import 'package:bumrent_app/app/data/models/satuan_waktu_model.dart';
import 'package:bumrent_app/app/data/providers/auth_provider.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PesananProvider {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _tableName = 'pesanan';

  Future<List<PesananModel>> getPesananByUserId(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*, aset(nama)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<PesananModel> pesananList = [];
      for (final item in response) {
        final pesanan = PesananModel.fromJson(item);

        // Attach the asset name
        if (item['aset'] != null) {
          pesanan.namaAset = item['aset']['nama'];
        }

        // Get and attach satuan waktu name
        final satuanWaktu = await getSatuanWaktuById(pesanan.satuanWaktuId);
        if (satuanWaktu != null) {
          pesanan.namaSatuanWaktu = satuanWaktu.namaSatuanWaktu;
        }

        pesananList.add(pesanan);
      }

      return pesananList;
    } catch (e) {
      print('Error getting pesanan by user ID: $e');
      return [];
    }
  }

  Future<List<PesananModel>> getAllPesanan() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*, aset(nama), auth_users(full_name)')
          .order('created_at', ascending: false);

      final List<PesananModel> pesananList = [];
      for (final item in response) {
        final pesanan = PesananModel.fromJson(item);

        // Attach the asset name
        if (item['aset'] != null) {
          pesanan.namaAset = item['aset']['nama'];
        }

        // Attach the user name
        if (item['auth_users'] != null) {
          pesanan.namaUser = item['auth_users']['full_name'];
        }

        // Get and attach satuan waktu name
        final satuanWaktu = await getSatuanWaktuById(pesanan.satuanWaktuId);
        if (satuanWaktu != null) {
          pesanan.namaSatuanWaktu = satuanWaktu.namaSatuanWaktu;
        }

        pesananList.add(pesanan);
      }

      return pesananList;
    } catch (e) {
      print('Error getting all pesanan: $e');
      return [];
    }
  }

  Future<PesananModel?> getPesananById(String id) async {
    try {
      final response =
          await _supabase
              .from(_tableName)
              .select('*, aset(nama), auth_users(full_name)')
              .eq('id', id)
              .single();

      final pesanan = PesananModel.fromJson(response);

      // Attach the asset name
      if (response['aset'] != null) {
        pesanan.namaAset = response['aset']['nama'];
      }

      // Attach the user name
      if (response['auth_users'] != null) {
        pesanan.namaUser = response['auth_users']['full_name'];
      }

      // Get and attach satuan waktu name
      final satuanWaktu = await getSatuanWaktuById(pesanan.satuanWaktuId);
      if (satuanWaktu != null) {
        pesanan.namaSatuanWaktu = satuanWaktu.namaSatuanWaktu;
      }

      return pesanan;
    } catch (e) {
      print('Error getting pesanan by ID: $e');
      return null;
    }
  }

  Future<String?> createPesanan({
    required String asetId,
    required String satuanWaktuId,
    required String userId,
    required DateTime tanggalPemesanan,
    required String jamPemesanan,
    required int durasi,
    required int totalHarga,
  }) async {
    try {
      final response =
          await _supabase
              .from(_tableName)
              .insert({
                'aset_id': asetId,
                'satuan_waktu_id': satuanWaktuId,
                'user_id': userId,
                'status': 'pending',
                'tanggal_pemesanan':
                    tanggalPemesanan.toIso8601String().split('T')[0],
                'jam_pemesanan': jamPemesanan,
                'durasi': durasi,
                'total_harga': totalHarga,
              })
              .select('id')
              .single();

      return response['id'];
    } catch (e) {
      print('Error creating pesanan: $e');
      return null;
    }
  }

  Future<bool> updatePesananStatus(String id, String status) async {
    try {
      await _supabase
          .from(_tableName)
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      return true;
    } catch (e) {
      print('Error updating pesanan status: $e');
      return false;
    }
  }

  Future<bool> deletePesanan(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting pesanan: $e');
      return false;
    }
  }

  Future<SatuanWaktuModel?> getSatuanWaktuById(String id) async {
    try {
      final response =
          await _supabase.from('satuan_waktu').select().eq('id', id).single();
      return SatuanWaktuModel.fromJson(response);
    } catch (e) {
      print('Error getting satuan waktu by ID: $e');
      return null;
    }
  }
}
