import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/pembayaran_model.dart';

class PembayaranService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ambil data pembayaran antara [start] (inklusif) dan [end] (eksklusif).
  Future<List<PembayaranModel>> _fetchBetween(
    DateTime start,
    DateTime end,
  ) async {
    final data = await _supabase
        .from('pembayaran')
        .select('id, metode_pembayaran, total_pembayaran, waktu_pembayaran')
        .gte('waktu_pembayaran', start.toIso8601String())
        .lt('waktu_pembayaran', end.toIso8601String())
        .order('waktu_pembayaran', ascending: true);

    return (data as List<dynamic>)
        .map((e) => PembayaranModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Hitung statistik yang diminta.
  Future<Map<String, dynamic>> fetchStats() async {
    final now = DateTime.now();

    // Rentang bulan ini: [awal bulan ini, awal bulan depan)
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    // Bulan lalu: [awal bulan lalu, awal bulan ini)
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final thisMonthEnd = thisMonthStart;

    // 6 bulan terakhir: [6 bulan lalu, sekarang]
    final sixMonthsAgo = DateTime(now.year, now.month - 6, 1);

    // 1) Data bulan ini & bulan lalu
    final thisMonthData = await _fetchBetween(thisMonthStart, nextMonthStart);
    final lastMonthData = await _fetchBetween(lastMonthStart, thisMonthEnd);

    // 2) Data 6 bulan terakhir
    final sixMonthsData = await _fetchBetween(sixMonthsAgo, nextMonthStart);

    // 3) Hitung total pendapatan
    double sum(List<PembayaranModel> list) =>
        list.fold(0.0, (acc, e) => acc + e.totalPembayaran);

    final totalThis = sum(thisMonthData);
    final totalLast = sum(lastMonthData);
    final totalSix = sum(sixMonthsData);

    // 4) Persentase selisih (bulanan)
    double percentDiff = 0.0;
    if (totalLast != 0) {
      percentDiff = ((totalThis - totalLast) / totalLast) * 100;
    }

    // 5) Total per metode (hanya dari bulan ini, misalnya)
    double totTunai = 0.0, totTransfer = 0.0;
    for (var p in thisMonthData) {
      if (p.metodePembayaran.toLowerCase() == 'tunai') {
        totTunai += p.totalPembayaran;
      } else if (p.metodePembayaran.toLowerCase() == 'transfer') {
        totTransfer += p.totalPembayaran;
      }
    }

    // 6) Trend per month (6 months, oldest to newest)
    List<double> trendPerMonth = [];
    for (int i = 5; i >= 0; i--) {
      final dt = DateTime(now.year, now.month - i, 1);
      final dtNext = DateTime(now.year, now.month - i + 1, 1);
      final monthData = await _fetchBetween(dt, dtNext);
      trendPerMonth.add(sum(monthData));
    }

    return {
      'totalThisMonth': totalThis,
      'percentComparedLast': percentDiff,
      'totalTunai': totTunai,
      'totalTransfer': totTransfer,
      'totalLastSixMonths': totalSix,
      'trendPerMonth': trendPerMonth,
    };
  }
}
