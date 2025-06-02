import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthProvider extends GetxService {
  late final SupabaseClient client;
  bool _isInitialized = false;

  Future<AuthProvider> init() async {
    // Cek jika sudah diinisialisasi sebelumnya
    if (_isInitialized) {
      debugPrint('Supabase already initialized');
      return this;
    }

    try {
      // Cek jika dotenv sudah dimuat
      if (dotenv.env['SUPABASE_URL'] == null ||
          dotenv.env['SUPABASE_ANON_KEY'] == null) {
        await dotenv.load();
      }

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseKey == null) {
        throw Exception('Supabase credentials not found in .env file');
      }

      debugPrint(
        'Initializing Supabase with URL: ${supabaseUrl.substring(0, 15)}...',
      );

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
        debug: true, // Aktifkan debugging untuk membantu troubleshooting
      );

      client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('Supabase initialized successfully');
      return this;
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      rethrow;
    }
  }

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authChanges => client.auth.onAuthStateChange;

  String? getCurrentUserId() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      return session?.user.id;
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan role_id dari raw_user_meta_data
  Future<String?> getUserRoleId() async {
    final user = currentUser;
    if (user == null) {
      debugPrint('No current user found when getting role');
      return null;
    }

    try {
      debugPrint('Fetching role_id from user metadata for user ID: ${user.id}');

      // Cek user metadata untuk role_id
      final userMetadata = user.userMetadata;
      debugPrint('User metadata: $userMetadata');

      // Cek beberapa kemungkinan nama field untuk role_id
      if (userMetadata != null) {
        if (userMetadata.containsKey('role_id')) {
          final roleId = userMetadata['role_id'].toString();
          debugPrint('Found role_id in metadata: $roleId');
          return roleId;
        }

        if (userMetadata.containsKey('role')) {
          final role = userMetadata['role'].toString();
          debugPrint('Found role in metadata: $role');

          // Coba konversi nama role ke UUID (from hardcoded data)
          if (role.toUpperCase() == 'WARGA') {
            return 'bb5360d5-8fd0-404e-8f6f-71ec4d8ad0ae';
          }
          if (role.toUpperCase() == 'PETUGAS_BUMDES') {
            return '38a8a23c-1873-4033-b977-3293247903b';
          }
          if (role.toUpperCase() == 'PETUGAS_MITRA') {
            return '8b1af754-0866-4e12-a9d8-da8ed31bec15';
          }
        }
      }

      // Jika tidak ada di metadata, coba cari di tabel roles dengan user_id
      debugPrint('Checking roles table for user ID: ${user.id}');

      try {
        // Mencoba mengambil roles berdasarkan id user di auth
        final roleData =
            await client
                .from('roles')
                .select('id')
                .eq('user_id', user.id)
                .maybeSingle();

        debugPrint('Role data by user_id: $roleData');

        if (roleData != null && roleData.containsKey('id')) {
          final roleId = roleData['id'].toString();
          debugPrint('Found role ID in roles table: $roleId');
          return roleId;
        }
      } catch (e) {
        debugPrint('Error querying roles by user_id: $e');
      }

      // Jika tidak ditemukan dengan user_id, coba lihat seluruh tabel roles
      // untuk debugging
      debugPrint('Getting all roles to debug matching issues');
      final allRoles = await client.from('roles').select('*').limit(10);

      debugPrint('All roles in table: $allRoles');

      // Fallback - tampaknya user belum di-assign role
      // Berikan hardcoded role berdasarkan email pattern
      final email = user.email?.toLowerCase();
      if (email != null) {
        if (email.contains('bumdes')) {
          return '38a8a23c-1873-4033-b977-3293247903b'; // PETUGAS_BUMDES
        } else if (email.contains('mitra')) {
          return '8b1af754-0866-4e12-a9d8-da8ed31bec15'; // PETUGAS_MITRA
        }
      }

      // Default ke WARGA
      return 'bb5360d5-8fd0-404e-8f6f-71ec4d8ad0ae'; // WARGA
    } catch (e) {
      debugPrint('Error fetching user role_id: $e');
      // Default ke WARGA sebagai fallback
      return 'bb5360d5-8fd0-404e-8f6f-71ec4d8ad0ae';
    }
  }

  // Metode untuk mendapatkan nama role dari tabel roles berdasarkan role_id
  Future<String?> getRoleName(String roleId) async {
    try {
      debugPrint('Fetching role name for role_id: $roleId');

      // Ambil nama role dari tabel roles
      // ID di tabel roles adalah tipe UUID, pastikan format roleId sesuai
      final roleData =
          await client
              .from('roles')
              .select('nama_role, id')
              .eq('id', roleId)
              .maybeSingle();

      debugPrint('Query result for roles table: $roleData');

      if (roleData != null) {
        // Cek berbagai kemungkinan nama kolom
        String? roleName;
        if (roleData.containsKey('nama_role')) {
          roleName = roleData['nama_role'].toString();
        } else if (roleData.containsKey('nama_role')) {
          roleName = roleData['nama_role'].toString();
        } else if (roleData.containsKey('role_name')) {
          roleName = roleData['role_name'].toString();
        }

        if (roleName != null) {
          debugPrint('Found role name in roles table: $roleName');
          return roleName;
        }

        // Jika tidak ada nama kolom yang cocok, tampilkan kolom yang tersedia
        debugPrint(
          'Available columns in roles table: ${roleData.keys.join(', ')}',
        );
      }

      // Lihat data lengkap tabel untuk troubleshooting
      debugPrint('Getting all roles data for troubleshooting');
      final allRoles = await client.from('roles').select('*').limit(5);

      debugPrint('All roles table data (up to 5 rows): $allRoles');

      // Hardcoded fallback berdasarkan UUID roleId yang dilihat dari data
      debugPrint('Using hardcoded fallback for role_id: $roleId');
      if (roleId == 'bb5360d5-8fd0-404e-8f6f-71ec4d8ad0ae') return 'WARGA';
      if (roleId == '38a8a23c-1873-4033-b977-3293247903b') {
        return 'PETUGAS_BUMDES';
      }
      if (roleId == '8b1af754-0866-4e12-a9d8-da8ed31bec15') {
        return 'PETUGAS_MITRA';
      }

      // Default fallback jika role_id tidak dikenali
      debugPrint('Unrecognized role_id: $roleId, defaulting to WARGA');
      return 'WARGA';
    } catch (e) {
      debugPrint('Error fetching role name: $e');
      return 'WARGA'; // Default fallback
    }
  }

  // Metode untuk mendapatkan nama lengkap dari tabel warga_desa berdasarkan user_id
  Future<String?> getUserFullName() async {
    final user = currentUser;
    if (user == null) {
      debugPrint('No current user found when getting full name');
      return null;
    }

    try {
      debugPrint('Fetching nama_lengkap for user_id: ${user.id}');

      // Coba ambil nama lengkap dari tabel warga_desa
      final userData =
          await client
              .from('warga_desa')
              .select('nama_lengkap')
              .eq('user_id', user.id)
              .maybeSingle();

      debugPrint('User data from warga_desa table: $userData');

      // Jika berhasil mendapatkan data
      if (userData != null && userData.containsKey('nama_lengkap')) {
        final namaLengkap = userData['nama_lengkap']?.toString();
        if (namaLengkap != null && namaLengkap.isNotEmpty) {
          debugPrint('Found nama_lengkap: $namaLengkap');
          return namaLengkap;
        }
      }

      // Jika tidak ada data di warga_desa, coba cek struktur tabel untuk troubleshooting
      debugPrint('Checking warga_desa table structure');
      final tableData =
          await client.from('warga_desa').select('*').limit(1).maybeSingle();

      if (tableData != null) {
        debugPrint(
          'Available columns in warga_desa table: ${tableData.keys.join(', ')}',
        );
      } else {
        debugPrint('No data found in warga_desa table');
      }

      // Fallback ke data dari Supabase Auth
      final userMetadata = user.userMetadata;
      if (userMetadata != null) {
        if (userMetadata.containsKey('full_name')) {
          return userMetadata['full_name']?.toString();
        }
        if (userMetadata.containsKey('name')) {
          return userMetadata['name']?.toString();
        }
      }

      // Gunakan email jika nama tidak ditemukan
      return user.email?.split('@').first ?? 'Pengguna Warga';
    } catch (e) {
      debugPrint('Error fetching user full name: $e');
      return 'Pengguna Warga'; // Default fallback
    }
  }

  // Metode untuk mendapatkan avatar dari tabel warga_desa berdasarkan user_id
  Future<String?> getUserAvatar() async {
    final user = currentUser;
    if (user == null) {
      debugPrint('No current user found when getting avatar');
      return null;
    }

    try {
      debugPrint('Fetching avatar for user_id: ${user.id}');

      // Coba ambil avatar dari tabel warga_desa
      final userData =
          await client
              .from('warga_desa')
              .select('avatar')
              .eq('user_id', user.id)
              .maybeSingle();

      debugPrint('Avatar data from warga_desa table: $userData');

      // Jika berhasil mendapatkan data
      if (userData != null && userData.containsKey('avatar')) {
        final avatarUrl = userData['avatar']?.toString();
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          debugPrint('Found avatar URL: $avatarUrl');
          return avatarUrl;
        }
      }

      // Fallback ke data dari Supabase Auth
      final userMetadata = user.userMetadata;
      if (userMetadata != null && userMetadata.containsKey('avatar_url')) {
        return userMetadata['avatar_url']?.toString();
      }

      return null; // No avatar found
    } catch (e) {
      debugPrint('Error fetching user avatar: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan email pengguna
  Future<String?> getUserEmail() async {
    final user = currentUser;
    if (user == null) {
      debugPrint('No current user found when getting email');
      return null;
    }

    // Email ada di data user Supabase Auth
    return user.email;
  }

  // Metode untuk mendapatkan NIK dari tabel warga_desa berdasarkan user_id
  Future<String?> getUserNIK() async {
    final user = currentUser;
    if (user == null) {
      debugPrint('No current user found when getting NIK');
      return null;
    }

    try {
      debugPrint('Fetching NIK for user_id: ${user.id}');

      // Coba ambil NIK dari tabel warga_desa
      final userData =
          await client
              .from('warga_desa')
              .select('nik')
              .eq('user_id', user.id)
              .maybeSingle();

      // Jika berhasil mendapatkan data
      if (userData != null && userData.containsKey('nik')) {
        final nik = userData['nik']?.toString();
        if (nik != null && nik.isNotEmpty) {
          debugPrint('Found NIK: $nik');
          return nik;
        }
      }

      // Fallback ke data dari metadata
      final userMetadata = user.userMetadata;
      if (userMetadata != null && userMetadata.containsKey('nik')) {
        return userMetadata['nik']?.toString();
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching user NIK: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan nomor telepon dari tabel warga_desa berdasarkan user_id
  Future<String?> getUserPhone() async {
    final user = currentUser;
    if (user == null) {
      debugPrint('No current user found when getting phone');
      return null;
    }

    try {
      debugPrint('Fetching phone for user_id: ${user.id}');

      // Coba ambil nomor telepon dari tabel warga_desa
      final userData =
          await client
              .from('warga_desa')
              .select('nomor_telepon, no_telepon, phone')
              .eq('user_id', user.id)
              .maybeSingle();

      // Jika berhasil mendapatkan data, cek beberapa kemungkinan nama kolom
      if (userData != null) {
        if (userData.containsKey('nomor_telepon')) {
          final phone = userData['nomor_telepon']?.toString();
          if (phone != null && phone.isNotEmpty) return phone;
        }

        if (userData.containsKey('no_telepon')) {
          final phone = userData['no_telepon']?.toString();
          if (phone != null && phone.isNotEmpty) return phone;
        }

        if (userData.containsKey('phone')) {
          final phone = userData['phone']?.toString();
          if (phone != null && phone.isNotEmpty) return phone;
        }
      }

      // Fallback ke data dari Supabase Auth
      final userMetadata = user.userMetadata;
      if (userMetadata != null) {
        if (userMetadata.containsKey('phone')) {
          return userMetadata['phone']?.toString();
        }
        if (userMetadata.containsKey('phone_number')) {
          return userMetadata['phone_number']?.toString();
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching user phone: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan alamat dari tabel warga_desa berdasarkan user_id
  Future<String?> getUserAddress() async {
    final user = currentUser;
    if (user == null) {
      debugPrint('No current user found when getting address');
      return null;
    }

    try {
      debugPrint('Fetching address for user_id: ${user.id}');

      // Coba ambil alamat dari tabel warga_desa
      final userData =
          await client
              .from('warga_desa')
              .select('alamat')
              .eq('user_id', user.id)
              .maybeSingle();

      // Jika berhasil mendapatkan data
      if (userData != null && userData.containsKey('alamat')) {
        final address = userData['alamat']?.toString();
        if (address != null && address.isNotEmpty) {
          debugPrint('Found address: $address');
          return address;
        }
      }

      // Fallback ke data dari Supabase Auth
      final userMetadata = user.userMetadata;
      if (userMetadata != null && userMetadata.containsKey('address')) {
        return userMetadata['address']?.toString();
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching user address: $e');
      return null;
    }
  }

  // Mendapatkan data sewa_aset berdasarkan status (misal: MENUNGGU PEMBAYARAN, PEMBAYARANAN DENDA)
  Future<List<Map<String, dynamic>>> getSewaAsetByStatus(
    List<String> statuses,
  ) async {
    final user = currentUser;
    if (user == null) {
      debugPrint('No current user found when getting sewa_aset by status');
      return [];
    }
    try {
      debugPrint(
        'Fetching sewa_aset for user_id: \\${user.id} with statuses: \\${statuses.join(', ')}',
      );
      // Supabase expects the IN filter as a comma-separated string in parentheses
      final statusString = '(${statuses.map((s) => '"$s"').join(',')})';
      final response = await client
          .from('sewa_aset')
          .select('*')
          .eq('user_id', user.id)
          .filter('status', 'in', statusString);
      debugPrint('Fetched sewa_aset count: \\${response.length}');
      // Pastikan response adalah List
      if (response is List) {
        return response
            .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching sewa_aset by status: \\${e.toString()}');
      return [];
    }
  }
}
