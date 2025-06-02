import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PetugasPaketController extends GetxController {
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'Semua'.obs;
  final sortBy = 'Terbaru'.obs;

  // Kategori untuk filter
  final categories = <String>[
    'Semua',
    'Pesta',
    'Rapat',
    'Olahraga',
    'Pernikahan',
    'Lainnya',
  ];

  // Opsi pengurutan
  final sortOptions = <String>[
    'Terbaru',
    'Terlama',
    'Harga Tertinggi',
    'Harga Terendah',
    'Nama A-Z',
    'Nama Z-A',
  ];

  // Data dummy paket
  final paketList = <Map<String, dynamic>>[].obs;
  final filteredPaketList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPaketData();
  }

  // Format harga ke Rupiah
  String formatPrice(int price) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  // Load data paket dummy
  Future<void> loadPaketData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800)); // Simulasi loading

    paketList.value = [
      {
        'id': '1',
        'nama': 'Paket Pesta Ulang Tahun',
        'kategori': 'Pesta',
        'harga': 500000,
        'deskripsi':
            'Paket lengkap untuk acara ulang tahun. Termasuk 5 meja, 20 kursi, backdrop, dan sound system.',
        'tersedia': true,
        'created_at': '2023-08-10',
        'items': [
          {'nama': 'Meja Panjang', 'jumlah': 5},
          {'nama': 'Kursi Plastik', 'jumlah': 20},
          {'nama': 'Sound System', 'jumlah': 1},
          {'nama': 'Backdrop', 'jumlah': 1},
        ],
        'gambar': 'https://example.com/images/paket_ultah.jpg',
      },
      {
        'id': '2',
        'nama': 'Paket Rapat Sedang',
        'kategori': 'Rapat',
        'harga': 300000,
        'deskripsi':
            'Paket untuk rapat sedang. Termasuk 1 meja rapat besar, 10 kursi, proyektor, dan screen.',
        'tersedia': true,
        'created_at': '2023-09-05',
        'items': [
          {'nama': 'Meja Rapat', 'jumlah': 1},
          {'nama': 'Kursi Kantor', 'jumlah': 10},
          {'nama': 'Proyektor', 'jumlah': 1},
          {'nama': 'Screen', 'jumlah': 1},
        ],
        'gambar': 'https://example.com/images/paket_rapat.jpg',
      },
      {
        'id': '3',
        'nama': 'Paket Pesta Pernikahan',
        'kategori': 'Pernikahan',
        'harga': 1500000,
        'deskripsi':
            'Paket lengkap untuk acara pernikahan. Termasuk 20 meja, 100 kursi, sound system, dekorasi, dan tenda.',
        'tersedia': true,
        'created_at': '2023-10-12',
        'items': [
          {'nama': 'Meja Bundar', 'jumlah': 20},
          {'nama': 'Kursi Tamu', 'jumlah': 100},
          {'nama': 'Sound System Besar', 'jumlah': 1},
          {'nama': 'Tenda 10x10', 'jumlah': 2},
          {'nama': 'Set Dekorasi Pengantin', 'jumlah': 1},
        ],
        'gambar': 'https://example.com/images/paket_nikah.jpg',
      },
      {
        'id': '4',
        'nama': 'Paket Olahraga Voli',
        'kategori': 'Olahraga',
        'harga': 200000,
        'deskripsi':
            'Paket perlengkapan untuk turnamen voli. Termasuk net, bola, dan tiang voli.',
        'tersedia': false,
        'created_at': '2023-07-22',
        'items': [
          {'nama': 'Net Voli', 'jumlah': 1},
          {'nama': 'Bola Voli', 'jumlah': 3},
          {'nama': 'Tiang Voli', 'jumlah': 2},
        ],
        'gambar': 'https://example.com/images/paket_voli.jpg',
      },
      {
        'id': '5',
        'nama': 'Paket Pesta Anak',
        'kategori': 'Pesta',
        'harga': 350000,
        'deskripsi':
            'Paket untuk pesta ulang tahun anak-anak. Termasuk 3 meja, 15 kursi, dekorasi tema, dan sound system kecil.',
        'tersedia': true,
        'created_at': '2023-11-01',
        'items': [
          {'nama': 'Meja Anak', 'jumlah': 3},
          {'nama': 'Kursi Anak', 'jumlah': 15},
          {'nama': 'Set Dekorasi Tema', 'jumlah': 1},
          {'nama': 'Sound System Kecil', 'jumlah': 1},
        ],
        'gambar': 'https://example.com/images/paket_anak.jpg',
      },
    ];

    filterPaket();
    isLoading.value = false;
  }

  // Filter paket berdasarkan search query dan kategori
  void filterPaket() {
    filteredPaketList.value =
        paketList.where((paket) {
          final matchesQuery =
              paket['nama'].toString().toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              paket['deskripsi'].toString().toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              );

          final matchesCategory =
              selectedCategory.value == 'Semua' ||
              paket['kategori'] == selectedCategory.value;

          return matchesQuery && matchesCategory;
        }).toList();

    // Sort the filtered list
    sortFilteredList();
  }

  // Sort the filtered list
  void sortFilteredList() {
    switch (sortBy.value) {
      case 'Terbaru':
        filteredPaketList.sort(
          (a, b) => b['created_at'].compareTo(a['created_at']),
        );
        break;
      case 'Terlama':
        filteredPaketList.sort(
          (a, b) => a['created_at'].compareTo(b['created_at']),
        );
        break;
      case 'Harga Tertinggi':
        filteredPaketList.sort((a, b) => b['harga'].compareTo(a['harga']));
        break;
      case 'Harga Terendah':
        filteredPaketList.sort((a, b) => a['harga'].compareTo(b['harga']));
        break;
      case 'Nama A-Z':
        filteredPaketList.sort((a, b) => a['nama'].compareTo(b['nama']));
        break;
      case 'Nama Z-A':
        filteredPaketList.sort((a, b) => b['nama'].compareTo(a['nama']));
        break;
    }
  }

  // Set search query dan filter paket
  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterPaket();
  }

  // Set kategori dan filter paket
  void setCategory(String category) {
    selectedCategory.value = category;
    filterPaket();
  }

  // Set opsi pengurutan dan filter paket
  void setSortBy(String option) {
    sortBy.value = option;
    sortFilteredList();
  }

  // Tambah paket baru
  void addPaket(Map<String, dynamic> paket) {
    paketList.add(paket);
    filterPaket();
    Get.back();
    Get.snackbar(
      'Sukses',
      'Paket baru berhasil ditambahkan',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Edit paket
  void editPaket(String id, Map<String, dynamic> updatedPaket) {
    final index = paketList.indexWhere((element) => element['id'] == id);
    if (index >= 0) {
      paketList[index] = updatedPaket;
      filterPaket();
      Get.back();
      Get.snackbar(
        'Sukses',
        'Paket berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Hapus paket
  void deletePaket(String id) {
    paketList.removeWhere((element) => element['id'] == id);
    filterPaket();
    Get.snackbar(
      'Sukses',
      'Paket berhasil dihapus',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
