import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/aset_model.dart';
import '../models/foto_aset_model.dart';
import '../models/satuan_waktu_model.dart';
import '../models/satuan_waktu_sewa_model.dart';
import 'package:intl/intl.dart';
import '../models/paket_model.dart';
import '../providers/auth_provider.dart';

class AsetProvider extends GetxService {
  late final SupabaseClient client;

  AsetProvider() {
    client = Supabase.instance.client;
  }

  // Mendapatkan semua aset dengan kategori "sewa"
  Future<List<AsetModel>> getSewaAsets() async {
    try {
      debugPrint('Fetching aset with kategori: sewa');

      // Query untuk mendapatkan semua aset dengan kategori "sewa"
      final response = await client
          .from('aset')
          .select('*')
          .eq('kategori', 'sewa')
          .ilike('status', 'tersedia') // Hanya yang tersedia
          .order('nama', ascending: true) // Urutan berdasarkan nama
          .withConverter<List<Map<String, dynamic>>>(
            (data) =>
                data.map<Map<String, dynamic>>((item) {
                  // Ensure 'jenis' is set to 'Sewa' for sewa assets
                  item['jenis'] = 'Sewa';
                  return item;
                }).toList(),
          );

      debugPrint('Fetched ${response.length} aset');

      // Konversi response ke list AsetModel
      List<AsetModel> asets =
          response.map<AsetModel>((item) => AsetModel.fromJson(item)).toList();

      // Untuk setiap aset, ambil foto pertama dan satuan waktu sewa
      for (var aset in asets) {
        await _attachFirstPhoto(aset);
        await attachSatuanWaktuSewa(aset);
      }

      return asets;
    } catch (e) {
      debugPrint('Error fetching aset: $e');
      return [];
    }
  }

  // Mendapatkan semua aset dengan kategori "langganan"
  Future<List<AsetModel>> getLanggananAsets() async {
    try {
      debugPrint('Fetching aset with kategori: langganan');

      // Query untuk mendapatkan semua aset dengan kategori "langganan"
      final response = await client
          .from('aset')
          .select('*')
          .eq('kategori', 'langganan')
          .ilike('status', 'tersedia') // Hanya yang tersedia
          .order('nama', ascending: true) // Urutan berdasarkan nama
          .withConverter<List<Map<String, dynamic>>>(
            (data) =>
                data.map<Map<String, dynamic>>((item) {
                  // Ensure 'jenis' is set to 'Langganan' for langganan assets
                  item['jenis'] = 'Langganan';
                  return item;
                }).toList(),
          );

      debugPrint('Fetched ${response.length} langganan aset');

      // Konversi response ke list AsetModel
      List<AsetModel> asets =
          response.map<AsetModel>((item) => AsetModel.fromJson(item)).toList();

      // Untuk setiap aset, ambil foto pertama dan satuan waktu sewa
      for (var aset in asets) {
        await _attachFirstPhoto(aset);
        await attachSatuanWaktuSewa(aset);
      }

      return asets;
    } catch (e) {
      debugPrint('Error fetching langganan asets: $e');
      return [];
    }
  }

  // Mendapatkan aset berdasarkan ID
  Future<AsetModel?> getAsetById(String asetId) async {
    try {
      debugPrint('📂 Fetching aset with ID: $asetId');

      // Query untuk mendapatkan aset dengan ID tertentu
      final response =
          await client.from('aset').select('*').eq('id', asetId).maybeSingle();

      debugPrint('📂 Raw response type: ${response.runtimeType}');
      debugPrint('📂 Raw response: $response');

      if (response == null) {
        debugPrint('❌ Aset dengan ID $asetId tidak ditemukan');
        return null;
      }

      debugPrint(
        '✅ Successfully fetched aset with ID: $asetId, name: ${response['nama']}',
      );

      // Konversi response ke AsetModel
      AsetModel aset = AsetModel.fromJson(response);
      debugPrint('✅ AsetModel created: ${aset.id} - ${aset.nama}');

      // Ambil foto dan satuan waktu sewa untuk aset ini
      await _attachFirstPhoto(aset);
      await attachSatuanWaktuSewa(aset);
      await loadAssetPhotos(aset);

      return aset;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching aset by ID: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      return null;
    }
  }

  // Load all photos for an asset
  Future<void> loadAssetPhotos(AsetModel aset) async {
    try {
      final photos = await getAsetPhotos(aset.id);
      if (photos.isNotEmpty) {
        // Clear existing images
        aset.imageUrls.clear();

        // Add all photos to the imageUrls list
        for (final photo in photos) {
          if (photo.fotoAset != null && photo.fotoAset!.isNotEmpty) {
            aset.addImageUrl(photo.fotoAset);
          }
        }

        // Set the main image URL if it's not already set
        if ((aset.imageUrl == null || aset.imageUrl!.isEmpty) &&
            aset.imageUrls.isNotEmpty) {
          aset.imageUrl = aset.imageUrls.first;
        }

        debugPrint(
          '✅ Loaded ${aset.imageUrls.length} photos for asset ${aset.id}',
        );
      }
    } catch (e) {
      debugPrint('Error loading asset photos for ID ${aset.id}: $e');
    }
  }

  // Fungsi untuk mengambil foto pertama dari aset
  Future<void> _attachFirstPhoto(AsetModel aset) async {
    try {
      final responsePhoto =
          await client
              .from('foto_aset')
              .select('*')
              .eq('id_aset', aset.id)
              .limit(1)
              .maybeSingle();

      if (responsePhoto != null) {
        final fotoAset = FotoAsetModel.fromJson(responsePhoto);
        aset.imageUrl = fotoAset.fotoAset;
      }
    } catch (e) {
      debugPrint('Error fetching photo for aset ${aset.id}: $e');
    }
  }

  // Fungsi untuk mendapatkan semua foto aset berdasarkan ID aset
  Future<List<FotoAsetModel>> getAsetPhotos(String asetId) async {
    try {
      debugPrint('Fetching photos for aset ID: $asetId');

      final response = await client
          .from('foto_aset')
          .select('*')
          .eq('id_aset', asetId)
          .order('created_at');

      debugPrint('Fetched ${response.length} photos for aset ID: $asetId');

      // Konversi response ke list FotoAsetModel
      return (response as List)
          .map<FotoAsetModel>((item) => FotoAsetModel.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error fetching photos for aset ID $asetId: $e');
      return [];
    }
  }

  // Create a new asset
  Future<Map<String, dynamic>?> createAset(
    Map<String, dynamic> asetData,
  ) async {
    try {
      debugPrint('🔄 Creating new aset with data:');
      asetData.forEach((key, value) {
        debugPrint('   $key: $value');
      });

      final response =
          await client.from('aset').insert(asetData).select().single();

      debugPrint('✅ Aset created successfully with ID: ${response['id']}');
      return response;
    } catch (e) {
      debugPrint('❌ Error creating aset: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Update an existing asset
  Future<bool> updateAset(String asetId, Map<String, dynamic> asetData) async {
    try {
      debugPrint('🔄 Updating aset with ID: $asetId');
      asetData.forEach((key, value) {
        debugPrint('   $key: $value');
      });

      final response = await client
          .from('aset')
          .update(asetData)
          .eq('id', asetId);

      debugPrint('✅ Aset updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating aset: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Adds a photo URL to the foto_aset table for a specific asset
  Future<bool> addFotoAset({
    required String asetId,
    required String fotoUrl,
  }) async {
    try {
      debugPrint('💾 Attempting to save foto to database:');
      debugPrint('   - asetId: $asetId');
      debugPrint('   - fotoUrl: $fotoUrl');

      final data = {
        'id_aset': asetId,
        'foto_aset': fotoUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      debugPrint('📤 Inserting into foto_aset table...');
      final response = await client.from('foto_aset').insert(data).select();

      debugPrint('📝 Database insert response: $response');

      if (response == null) {
        debugPrint('❌ Failed to insert into foto_aset: Response is null');
        return false;
      }

      if (response is List && response.isNotEmpty) {
        debugPrint('✅ Successfully added foto for aset ID: $asetId');
        return true;
      } else {
        debugPrint('❌ Failed to add foto: Empty or invalid response');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error adding foto aset: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Add satuan waktu sewa for an asset
  Future<bool> addSatuanWaktuSewa({
    required String asetId,
    required String satuanWaktu,
    required int harga,
    required int maksimalWaktu,
  }) async {
    try {
      // First, get the satuan_waktu_id from the satuan_waktu table
      final response =
          await client
              .from('satuan_waktu')
              .select('id')
              .ilike('nama_satuan_waktu', satuanWaktu)
              .maybeSingle();

      if (response == null) {
        debugPrint('❌ Satuan waktu "$satuanWaktu" not found in the database');
        return false;
      }

      final satuanWaktuId = response['id'] as String;

      final data = {
        'aset_id': asetId,
        'satuan_waktu_id': satuanWaktuId,
        'harga': harga,
        'maksimal_waktu': maksimalWaktu,
      };

      debugPrint('🔄 Adding satuan waktu sewa:');
      data.forEach((key, value) {
        debugPrint('   $key: $value');
      });

      await client.from('satuan_waktu_sewa').insert(data);
      debugPrint('✅ Satuan waktu sewa added successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error adding satuan waktu sewa: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Delete all satuan waktu sewa for an asset
  Future<bool> deleteSatuanWaktuSewaByAsetId(String asetId) async {
    try {
      await client
          .from('satuan_waktu_sewa')
          .delete()
          .eq('aset_id', asetId); // Changed from 'id_aset' to 'aset_id'
      debugPrint('✅ Deleted satuan waktu sewa for aset ID: $asetId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting satuan waktu sewa: $e');
      return false;
    }
  }

  /// Uploads a file to Supabase Storage root
  /// Returns the public URL of the uploaded file, or null if upload fails
  Future<String?> uploadFileToStorage(File file) async {
    try {
      if (!await file.exists()) {
        debugPrint('❌ File does not exist: ${file.path}');
        return null;
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split(Platform.pathSeparator).last}';
      debugPrint('🔄 Preparing to upload file: $fileName');

      final uploadResponse = await client.storage
          .from('foto.aset')
          .upload(fileName, file, fileOptions: FileOptions(upsert: true));

      debugPrint('📤 Upload response: $uploadResponse');

      final publicUrl = client.storage.from('foto.aset').getPublicUrl(fileName);

      debugPrint('✅ File uploaded successfully. Public URL: $publicUrl');
      return publicUrl;
    } catch (e, stackTrace) {
      debugPrint('❌ Error uploading file to storage: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Helper method to delete a file from Supabase Storage
  Future<bool> deleteFileFromStorage(String fileUrl) async {
    try {
      debugPrint('🔄 Preparing to delete file from storage');

      // Extract the file path from the full URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;

      // Find the index of 'foto.aset' in the path
      final fotoAsetIndex = pathSegments.indexWhere(
        (segment) => segment == 'foto.aset',
      );

      if (fotoAsetIndex == -1 || fotoAsetIndex == pathSegments.length - 1) {
        debugPrint(
          '⚠️  Invalid file URL format, cannot extract file path: $fileUrl',
        );
        return false;
      }

      // Get the file path relative to the bucket
      final filePath = pathSegments.sublist(fotoAsetIndex + 1).join('/');

      debugPrint('🗑️  Deleting file from storage - Path: $filePath');

      // Delete the file from storage
      await client.storage.from('foto.aset').remove([filePath]);

      debugPrint('✅ Successfully deleted file from storage');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting file from storage: $e');
      return false;
    }
  }

  /// Updates the photos for an asset
  /// Handles both local file uploads and existing URLs
  /// Returns true if all operations were successful
  Future<bool> updateFotoAset({
    required String asetId,
    required List<String> fotoUrls,
  }) async {
    if (fotoUrls.isEmpty) {
      debugPrint('ℹ️ No photos to update for asset: $asetId');
      return true;
    }

    try {
      debugPrint('🔄 Starting photo update for asset: $asetId');

      // 1. Get existing photo URLs before deleting them
      debugPrint('📋 Fetching existing photos for asset: $asetId');
      final existingPhotos = await client
          .from('foto_aset')
          .select('foto_aset')
          .eq('id_aset', asetId);

      // 2. Delete files from storage first
      if (existingPhotos is List && existingPhotos.isNotEmpty) {
        debugPrint('🗑️  Deleting ${existingPhotos.length} files from storage');
        for (final photo in existingPhotos) {
          final url = photo['foto_aset'] as String?;
          if (url != null && url.isNotEmpty) {
            await deleteFileFromStorage(url);
          } else {
            debugPrint('⚠️  Skipping invalid photo URL: $photo');
          }
        }
      } else {
        debugPrint('ℹ️  No existing photos found in database');
      }

      // 3. Remove duplicates from new fotoUrls
      final uniqueFotoUrls = fotoUrls.toSet().toList();
      debugPrint(
        '📸 Processing ${uniqueFotoUrls.length} unique photos (was ${fotoUrls.length})',
      );

      // 4. Delete existing photo records from database
      debugPrint('🗑️ Removing existing photo records from database');
      try {
        final deleteResponse = await client
            .from('foto_aset')
            .delete()
            .eq('id_aset', asetId);

        debugPrint('🗑️ Database delete response: $deleteResponse');

        // Verify deletion
        final remainingPhotos = await client
            .from('foto_aset')
            .select()
            .eq('id_aset', asetId);

        if (remainingPhotos is List && remainingPhotos.isNotEmpty) {
          debugPrint(
            '⚠️ Warning: ${remainingPhotos.length} photos still exist in database after delete',
          );
        }
      } catch (e) {
        debugPrint('❌ Error deleting existing photo records: $e');
        // Continue with the update even if deletion fails
      }

      // 5. Process each unique new photo
      bool allSuccess = true;
      int processedCount = 0;

      for (final fotoUrl in uniqueFotoUrls) {
        if (fotoUrl.isEmpty) {
          debugPrint('⏭️ Skipping empty photo URL');
          continue;
        }

        try {
          debugPrint(
            '\n🔄 Processing photo ${processedCount + 1}/${uniqueFotoUrls.length}: ${fotoUrl.length > 50 ? '${fotoUrl.substring(0, 50)}...' : fotoUrl}',
          );

          // Check if it's a local file
          if (fotoUrl.startsWith('file://') ||
              fotoUrl.startsWith('/') ||
              !fotoUrl.startsWith('http')) {
            final file = File(fotoUrl.replaceFirst('file://', ''));
            if (!await file.exists()) {
              debugPrint('❌ File does not exist: ${file.path}');
              allSuccess = false;
              continue;
            }

            debugPrint('📤 Uploading local file...');
            final uploadedUrl = await uploadFileToStorage(file);

            if (uploadedUrl == null) {
              debugPrint('❌ Failed to upload file');
              allSuccess = false;
              continue;
            }

            debugPrint('💾 Saving to database...');
            final success = await addFotoAset(
              asetId: asetId,
              fotoUrl: uploadedUrl,
            );

            if (success) {
              processedCount++;
              debugPrint('✅ Successfully saved photo #$processedCount');
            } else {
              allSuccess = false;
              debugPrint('❌ Failed to save photo URL to database');
            }
          }
          // Skip placeholder values
          else if (fotoUrl == 'pending_upload') {
            debugPrint('⏭️ Skipping placeholder URL');
            continue;
          }
          // Handle existing URLs
          else if (fotoUrl.startsWith('http')) {
            debugPrint('🌐 Processing existing URL...');
            final success = await addFotoAset(asetId: asetId, fotoUrl: fotoUrl);

            if (success) {
              processedCount++;
              debugPrint('✅ Successfully saved URL #$processedCount');
            } else {
              allSuccess = false;
              debugPrint('❌ Failed to save URL to database');
            }
          } else {
            debugPrint('⚠️ Unrecognized URL format, skipping');
          }
        } catch (e, stackTrace) {
          allSuccess = false;
          debugPrint('❌ Error processing photo: $e');
          debugPrint('Stack trace: $stackTrace');
        }
      }

      debugPrint('\n📊 Photo update complete');
      debugPrint('✅ Success: $allSuccess');
      debugPrint(
        '📸 Processed: $processedCount/${uniqueFotoUrls.length} unique photos',
      );

      return allSuccess && processedCount > 0;
    } catch (e) {
      debugPrint('❌ Error updating foto aset: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Retrieve bookings for a specific asset on a specific date
  Future<List<Map<String, dynamic>>> getAsetBookings(
    String asetId,
    String date,
  ) async {
    try {
      // Convert the date to DateTime for comparison
      final targetDate = DateTime.parse(date);
      debugPrint('🔍 Fetching bookings for asset $asetId on date $date');

      // Query booked_detail table (previously was sewa_aset table) for bookings related to this asset
      final response = await client
          .from('booked_detail')
          .select('id, waktu_mulai, waktu_selesai, sewa_aset_id, kuantitas')
          .eq('aset_id', asetId)
          .order('waktu_mulai', ascending: true);

      // Filter bookings to only include those that overlap with our target date
      final bookingsForDate =
          response.where((booking) {
            if (booking['waktu_mulai'] == null ||
                booking['waktu_selesai'] == null) {
              debugPrint('⚠️ Booking has null timestamp: $booking');
              return false;
            }

            // Parse the timestamps
            final DateTime waktuMulai = DateTime.parse(booking['waktu_mulai']);
            final DateTime waktuSelesai = DateTime.parse(
              booking['waktu_selesai'],
            );

            // Check if booking overlaps with our target date
            final bookingStartDate = DateTime(
              waktuMulai.year,
              waktuMulai.month,
              waktuMulai.day,
            );
            final bookingEndDate = DateTime(
              waktuSelesai.year,
              waktuSelesai.month,
              waktuSelesai.day,
            );

            final targetDateOnly = DateTime(
              targetDate.year,
              targetDate.month,
              targetDate.day,
            );

            // The booking overlaps with our target date if:
            // 1. The booking starts on or before our target date AND
            // 2. The booking ends on or after our target date
            return !bookingStartDate.isAfter(targetDateOnly) &&
                !bookingEndDate.isBefore(targetDateOnly);
          }).toList();

      debugPrint(
        '📅 Found ${bookingsForDate.length} bookings for date $date from booked_detail table',
      );

      // Return the complete booking information with original timestamps
      return bookingsForDate.map((booking) {
        // Parse the timestamps for debugging
        final DateTime waktuMulai = DateTime.parse(booking['waktu_mulai']);
        final DateTime waktuSelesai = DateTime.parse(booking['waktu_selesai']);

        // Return the full booking data with formatted display times
        return {
          'id':
              booking['sewa_aset_id'] ??
              booking['id'], // Use sewa_aset_id as id if available
          'waktu_mulai': booking['waktu_mulai'], // Keep original ISO timestamp
          'waktu_selesai':
              booking['waktu_selesai'], // Keep original ISO timestamp
          'jam_mulai': DateFormat('HH:mm').format(waktuMulai), // For display
          'jam_selesai': DateFormat(
            'HH:mm',
          ).format(waktuSelesai), // For display
          'tanggal_mulai': DateFormat(
            'yyyy-MM-dd',
          ).format(waktuMulai), // For calculations
          'tanggal_selesai': DateFormat(
            'yyyy-MM-dd',
          ).format(waktuSelesai), // For calculations
          'kuantitas':
              booking['kuantitas'] ?? 1, // Default to 1 if not specified
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting asset bookings: $e');
      return [];
    }
  }

  // Fungsi untuk membuat pesanan sewa aset
  Future<bool> createSewaAsetOrder(Map<String, dynamic> orderData) async {
    try {
      debugPrint('🔄 Creating sewa_aset order with data:');
      orderData.forEach((key, value) {
        debugPrint('   $key: $value');
      });

      final response =
          await client.from('sewa_aset').insert(orderData).select().single();

      debugPrint('✅ Order created successfully: ${response['id']}');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating sewa_aset order: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');

      // Check for specific error types
      if (e.toString().contains('duplicate key')) {
        debugPrint('❌ This appears to be a duplicate key error');
      } else if (e.toString().contains('violates foreign key constraint')) {
        debugPrint('❌ This appears to be a foreign key constraint violation');
      } else if (e.toString().contains('violates not-null constraint')) {
        debugPrint('❌ This appears to be a null value in a required field');
      }

      return false;
    }
  }

  // Fungsi untuk membuat tagihan sewa
  Future<bool> createTagihanSewa(Map<String, dynamic> tagihanData) async {
    try {
      debugPrint('🔄 Creating tagihan_sewa with data:');
      tagihanData.forEach((key, value) {
        debugPrint('   $key: $value');
      });

      // Ensure we don't try to insert a nama_aset field that no longer exists
      if (tagihanData.containsKey('nama_aset')) {
        debugPrint(
          '⚠️ Removing nama_aset field from tagihan_sewa data as it does not exist in the table',
        );
        tagihanData.remove('nama_aset');
      }

      final response =
          await client
              .from('tagihan_sewa')
              .insert(tagihanData)
              .select()
              .single();

      debugPrint('✅ Tagihan created successfully: ${response['id']}');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating tagihan_sewa: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');

      // Check for specific error types
      if (e.toString().contains('duplicate key')) {
        debugPrint('❌ This appears to be a duplicate key error');
      } else if (e.toString().contains('violates foreign key constraint')) {
        debugPrint('❌ This appears to be a foreign key constraint violation');
      } else if (e.toString().contains('violates not-null constraint')) {
        debugPrint('❌ This appears to be a null value in a required field');
      } else if (e.toString().contains('Could not find the')) {
        debugPrint(
          '❌ This appears to be a column mismatch error - check field names',
        );
        // Print the field names from the data to help debug
        debugPrint('❌ Fields in provided data: ${tagihanData.keys.toList()}');
      }

      return false;
    }
  }

  // Fungsi untuk membuat booked detail
  Future<bool> createBookedDetail(Map<String, dynamic> bookedDetailData) async {
    try {
      debugPrint('🔄 Creating booked_detail with data:');
      bookedDetailData.forEach((key, value) {
        debugPrint('   $key: $value');
      });

      // Ensure we don't try to insert a status field that no longer exists
      if (bookedDetailData.containsKey('status')) {
        debugPrint(
          '⚠️ Removing status field from booked_detail data as it does not exist in the table',
        );
        bookedDetailData.remove('status');
      }

      final response =
          await client
              .from('booked_detail')
              .insert(bookedDetailData)
              .select()
              .single();

      debugPrint('✅ Booked detail created successfully: ${response['id']}');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating booked_detail: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');

      // Check for specific error types
      if (e.toString().contains('duplicate key')) {
        debugPrint('❌ This appears to be a duplicate key error');
      } else if (e.toString().contains('violates foreign key constraint')) {
        debugPrint('❌ This appears to be a foreign key constraint violation');
      } else if (e.toString().contains('violates not-null constraint')) {
        debugPrint('❌ This appears to be a null value in a required field');
      } else if (e.toString().contains('Could not find the')) {
        debugPrint(
          '❌ This appears to be a column mismatch error - check field names',
        );
        // Print the field names from the data to help debug
        debugPrint(
          '❌ Fields in provided data: ${bookedDetailData.keys.toList()}',
        );
      }

      return false;
    }
  }

  // Fungsi untuk membuat pesanan lengkap (sewa_aset, booked_detail, dan tagihan_sewa) dalam satu operasi
  Future<bool> createCompleteOrder({
    required Map<String, dynamic> sewaAsetData,
    required Map<String, dynamic> bookedDetailData,
    required Map<String, dynamic> tagihanSewaData,
  }) async {
    try {
      debugPrint('🔄 Creating complete order with transaction');
      debugPrint('📦 sewa_aset data:');
      sewaAsetData.forEach((key, value) => debugPrint('   $key: $value'));

      debugPrint('📦 booked_detail data:');
      bookedDetailData.forEach((key, value) => debugPrint('   $key: $value'));

      // Ensure we don't try to insert a status field that no longer exists
      if (bookedDetailData.containsKey('status')) {
        debugPrint(
          '⚠️ Removing status field from booked_detail data as it does not exist in the table',
        );
        bookedDetailData.remove('status');
      }

      debugPrint('📦 tagihan_sewa data:');
      tagihanSewaData.forEach((key, value) => debugPrint('   $key: $value'));

      // Ensure we don't try to insert a nama_aset field that no longer exists
      if (tagihanSewaData.containsKey('nama_aset')) {
        debugPrint(
          '⚠️ Removing nama_aset field from tagihan_sewa data as it does not exist in the table',
        );
        tagihanSewaData.remove('nama_aset');
      }

      // Insert all three records
      final sewaAsetResult =
          await client.from('sewa_aset').insert(sewaAsetData).select().single();
      debugPrint('✅ sewa_aset created: ${sewaAsetResult['id']}');

      final bookedDetailResult =
          await client
              .from('booked_detail')
              .insert(bookedDetailData)
              .select()
              .single();
      debugPrint('✅ booked_detail created: ${bookedDetailResult['id']}');

      final tagihanSewaResult =
          await client
              .from('tagihan_sewa')
              .insert(tagihanSewaData)
              .select()
              .single();
      debugPrint('✅ tagihan_sewa created: ${tagihanSewaResult['id']}');

      debugPrint('✅ Complete order created successfully!');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating complete order: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');

      // Check for specific error types
      if (e.toString().contains('duplicate key')) {
        debugPrint('❌ This appears to be a duplicate key error');
      } else if (e.toString().contains('violates foreign key constraint')) {
        debugPrint('❌ This appears to be a foreign key constraint violation');
      } else if (e.toString().contains('violates not-null constraint')) {
        debugPrint('❌ This appears to be a null value in a required field');
      } else if (e.toString().contains('Could not find the')) {
        debugPrint(
          '❌ This appears to be a column mismatch error - check field names',
        );
        // Print the field names from each data object to help debug
        debugPrint('❌ Fields in sewa_aset data: ${sewaAsetData.keys.toList()}');
        debugPrint(
          '❌ Fields in booked_detail data: ${bookedDetailData.keys.toList()}',
        );
        debugPrint(
          '❌ Fields in tagihan_sewa data: ${tagihanSewaData.keys.toList()}',
        );
      }

      return false;
    }
  }

  // Fungsi untuk mendapatkan data satuan waktu berdasarkan ID dari tabel `satuan_waktu`
  Future<SatuanWaktuModel?> getSatuanWaktuById(String id) async {
    try {
      // Asumsikan client adalah instance Supabase (atau library serupa)
      final response =
          await client
              .from('satuan_waktu')
              .select('*')
              .eq('id', id)
              .maybeSingle();

      if (response == null) {
        debugPrint('Tidak ditemukan data satuan waktu untuk id: $id');
        return null;
      }

      return SatuanWaktuModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching satuan waktu by id: $e');
      return null;
    }
  }

  // Fungsi untuk mendapatkan semua data satuan waktu dari tabel `satuan_waktu`
  // Biasanya digunakan untuk menampilkan pilihan pada form atau filter
  Future<List<SatuanWaktuModel>> getAllSatuanWaktu() async {
    try {
      final response = await client
          .from('satuan_waktu')
          .select('*')
          .order('nama_satuan_waktu', ascending: true);

      // Pastikan response berupa list
      return (response as List)
          .map<SatuanWaktuModel>((item) => SatuanWaktuModel.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all satuan waktu: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan data satuan waktu sewa untuk suatu aset tertentu
  // Data diambil dari tabel `satuan_waktu_sewa` dan langsung melakukan join ke tabel `satuan_waktu`
  Future<List<Map<String, dynamic>>> getSatuanWaktuSewa(String asetId) async {
    try {
      debugPrint('Fetching satuan waktu sewa for aset $asetId with join...');

      // Query untuk mendapatkan data dari satuan_waktu_sewa dengan join ke satuan_waktu
      final response = await client
          .from('satuan_waktu_sewa')
          .select('''
            id, 
            aset_id, 
            satuan_waktu_id, 
            harga, 
            denda,
            maksimal_waktu,
            satuan_waktu:satuan_waktu_id(id, nama_satuan_waktu)
          ''')
          .eq('aset_id', asetId);

      debugPrint('Join query raw response type: ${response.runtimeType}');
      debugPrint('Join query raw response: $response');

      List<Map<String, dynamic>> result = [];

      debugPrint('Response is List with ${response.length} items');
      for (var item in response) {
        try {
          debugPrint('Processing item: $item');

          // Pengecekan null dan tipe data yang lebih aman
          var satuanWaktu = item['satuan_waktu'];
          String namaSatuanWaktu = '';

          if (satuanWaktu != null) {
            if (satuanWaktu is Map) {
              // Jika satuan_waktu adalah Map
              namaSatuanWaktu =
                  satuanWaktu['nama_satuan_waktu']?.toString() ?? '';
            } else if (satuanWaktu is List && satuanWaktu.isNotEmpty) {
              // Jika satuan_waktu adalah List
              var firstItem = satuanWaktu.first;
              if (firstItem is Map) {
                namaSatuanWaktu =
                    firstItem['nama_satuan_waktu']?.toString() ?? '';
              }
            }
          }

          final resultItem = {
            'id': item['id']?.toString() ?? '',
            'aset_id': item['aset_id']?.toString() ?? '',
            'satuan_waktu_id': item['satuan_waktu_id']?.toString() ?? '',
            'harga': item['harga'] ?? 0,
            'denda': item['denda'] ?? 0,
            'maksimal_waktu': item['maksimal_waktu'] ?? 0,
            'nama_satuan_waktu': namaSatuanWaktu,
          };

          debugPrint('Successfully processed item: $resultItem');
          result.add(resultItem);
        } catch (e) {
          debugPrint('Error processing item: $e');
          debugPrint('Item data: $item');
        }
      }

      debugPrint(
        'Processed ${result.length} satuan waktu sewa records for aset $asetId',
      );
      return result;
    } catch (e) {
      debugPrint('Error fetching satuan waktu sewa for aset $asetId: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Fungsi untuk melampirkan data satuan waktu sewa ke model aset secara langsung
  // Fungsi ini akan dipanggil misalnya saat Anda memuat detail aset atau list aset
  Future<void> attachSatuanWaktuSewa(AsetModel aset) async {
    try {
      debugPrint(
        'Attaching satuan waktu sewa to aset ${aset.id} (${aset.nama})',
      );

      // Ambil semua data satuan waktu sewa untuk aset tersebut
      final satuanWaktuSewaList = await getSatuanWaktuSewa(aset.id);

      // Urutkan data satuan waktu sewa, Jam dulu, kemudian Hari, kemudian lainnya
      satuanWaktuSewaList.sort((a, b) {
        final namaA = (a['nama_satuan_waktu'] ?? '').toString().toLowerCase();
        final namaB = (b['nama_satuan_waktu'] ?? '').toString().toLowerCase();

        // Jika ada 'jam', tempatkan di urutan pertama
        if (namaA.contains('jam') && !namaB.contains('jam')) {
          return -1;
        }
        // Jika ada 'hari', tempatkan di urutan kedua
        else if (!namaA.contains('jam') &&
            namaA.contains('hari') &&
            !namaB.contains('jam') &&
            !namaB.contains('hari')) {
          return -1;
        }
        // Jika keduanya 'jam' atau keduanya 'hari' atau keduanya lainnya, pertahankan urutan asli
        else if ((namaA.contains('jam') && namaB.contains('jam')) ||
            (namaA.contains('hari') && namaB.contains('hari'))) {
          return 0;
        }
        // Jika b adalah 'jam', tempatkan b lebih dulu
        else if (!namaA.contains('jam') && namaB.contains('jam')) {
          return 1;
        }
        // Jika b adalah 'hari' dan a bukan 'jam', tempatkan b lebih dulu
        else if (!namaA.contains('jam') &&
            !namaA.contains('hari') &&
            !namaB.contains('jam') &&
            namaB.contains('hari')) {
          return 1;
        }
        // Default, pertahankan urutan
        return 0;
      });

      debugPrint('Sorted satuan waktu sewa list: $satuanWaktuSewaList');

      // Bersihkan data lama dan masukkan data baru
      aset.satuanWaktuSewa.clear();
      aset.satuanWaktuSewa.addAll(satuanWaktuSewaList);

      // Debug: tampilkan data satuan waktu sewa yang berhasil dilampirkan
      if (satuanWaktuSewaList.isNotEmpty) {
        debugPrint(
          'Attached ${satuanWaktuSewaList.length} satuan waktu sewa to aset ${aset.id}:',
        );
        for (var sws in satuanWaktuSewaList) {
          debugPrint(
            '  - ID: ${sws['id']}, Harga: ${sws['harga']}, Satuan Waktu: ${sws['nama_satuan_waktu']} (${sws['satuan_waktu_id']})',
          );
        }
      } else {
        debugPrint('No satuan waktu sewa found for aset ${aset.id}');
      }
    } catch (e) {
      debugPrint('Error attaching satuan waktu sewa: $e');
    }
  }

  // Fungsi untuk memformat harga ke format rupiah (contoh: Rp 3.000)
  String formatPrice(int price) {
    // RegExp untuk menambahkan titik sebagai pemisah ribuan
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';

    // Pastikan angka dikonversi ke string
    var numStr = number.toString();

    // Tangani kasus ketika number bukan angka
    try {
      return numStr.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]}.',
      );
    } catch (e) {
      return numStr;
    }
  }

  // Method untuk pemesanan aset
  Future<bool> orderAset({
    required String userId,
    required String asetId,
    required String satuanWaktuSewaId,
    required int durasi,
    required int totalHarga,
  }) async {
    try {
      debugPrint('Creating order for aset $asetId by user $userId');

      // Dapatkan tanggal hari ini
      final tanggalPemesanan = DateTime.now().toIso8601String();

      // Buat pesanan baru
      final response =
          await client
              .from('pesanan')
              .insert({
                'user_id': userId,
                'aset_id': asetId,
                'satuan_waktu_sewa_id': satuanWaktuSewaId,
                'tanggal_pemesanan': tanggalPemesanan,
                'durasi': durasi,
                'total_harga': totalHarga,
                'status': 'pending', // Status awal pesanan
              })
              .select('id')
              .single();

      // Periksa apakah pesanan berhasil dibuat
      if (response['id'] != null) {
        debugPrint('Order created successfully with ID: ${response['id']}');
        return true;
      } else {
        debugPrint('Failed to create order: Response is null or missing ID');
        return false;
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      return false;
    }
  }

  // Get daily bookings for an asset for a date range
  Future<List<Map<String, dynamic>>> getAsetDailyBookings(
    String asetId,
    String startDate,
    String endDate,
  ) async {
    try {
      debugPrint(
        '🔍 Fetching daily bookings for asset $asetId from $startDate to $endDate from booked_detail table',
      );

      // Parse dates for comparison
      final startDateTime = DateTime.parse(startDate);
      final endDateTime = DateTime.parse(endDate);

      // Query booked_detail table (previously was sewa_aset table) for daily bookings related to this asset
      final response = await client
          .from('booked_detail')
          .select('id, waktu_mulai, waktu_selesai, sewa_aset_id, kuantitas')
          .eq('aset_id', asetId)
          .order('waktu_mulai', ascending: true);

      // Filter bookings that overlap with the requested date range
      final List<Map<String, dynamic>> bookingsInRange =
          response.where((booking) {
            if (booking['waktu_mulai'] == null ||
                booking['waktu_selesai'] == null) {
              debugPrint('⚠️ Booking has null dates: $booking');
              return false;
            }

            // Parse the dates
            final DateTime bookingStartDate = DateTime.parse(
              booking['waktu_mulai'],
            );
            final DateTime bookingEndDate = DateTime.parse(
              booking['waktu_selesai'],
            );

            // A booking overlaps with our date range if:
            // 1. The booking ends after or on our start date AND
            // 2. The booking starts before or on our end date
            return !bookingEndDate.isBefore(startDateTime) &&
                !bookingStartDate.isAfter(endDateTime);
          }).toList();

      debugPrint(
        '📅 Found ${bookingsInRange.length} bookings in the specified range from booked_detail table',
      );

      // Debug the booking details
      if (bookingsInRange.isNotEmpty) {
        for (var booking in bookingsInRange) {
          debugPrint(
            '📋 Booking ID: ${booking['sewa_aset_id'] ?? booking['id']}',
          );
          debugPrint('   - Start: ${booking['waktu_mulai']}');
          debugPrint('   - End: ${booking['waktu_selesai']}');
          debugPrint('   - Quantity: ${booking['kuantitas']}');
        }
      }

      return bookingsInRange.map((booking) {
        final Map<String, dynamic> result = Map<String, dynamic>.from(booking);
        // Use sewa_aset_id as the id if available
        if (booking['sewa_aset_id'] != null) {
          result['id'] = booking['sewa_aset_id'];
        }
        return result;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting daily bookings: $e');
      return [];
    }
  }

  bool _isBeforeToday(DateTime date) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    // Return true if date is today or before today (meaning it should be disabled)
    return !checkDate.isAfter(todayDate);
  }

  // Get tagihan sewa by sewa_aset_id
  Future<Map<String, dynamic>?> getTagihanSewa(String sewaAsetId) async {
    try {
      debugPrint('🔍 Fetching tagihan sewa for sewa_aset_id: $sewaAsetId');

      final response =
          await client
              .from('tagihan_sewa')
              .select('*')
              .eq('sewa_aset_id', sewaAsetId)
              .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ No tagihan sewa found for sewa_aset_id: $sewaAsetId');
        return null;
      }

      debugPrint('✅ Tagihan sewa found: ${response['id']}');
      return response;
    } catch (e) {
      debugPrint('❌ Error fetching tagihan sewa: $e');
      return null;
    }
  }

  // Get sewa_aset details with aset data
  Future<Map<String, dynamic>?> getSewaAsetWithAsetData(
    String sewaAsetId,
  ) async {
    try {
      debugPrint('🔍 Fetching sewa_aset with aset data for id: $sewaAsetId');

      // First get the sewa_aset record
      debugPrint('📊 Executing query: FROM sewa_aset WHERE id = $sewaAsetId');
      final sewaResponse =
          await client
              .from('sewa_aset')
              .select('*')
              .eq('id', sewaAsetId)
              .maybeSingle();

      if (sewaResponse == null) {
        debugPrint('⚠️ No sewa_aset found with id: $sewaAsetId');
        return null;
      }

      debugPrint('📋 Raw sewa_aset response:');
      sewaResponse.forEach((key, value) {
        debugPrint('  $key: $value');
      });

      // Get the aset_id from the sewa_aset record
      final asetId = sewaResponse['aset_id'];
      if (asetId == null) {
        debugPrint('⚠️ sewa_aset record has no aset_id');
        return sewaResponse;
      }

      debugPrint('🔍 Found aset_id: $asetId, now fetching aset details');

      // Get the aset details
      final asetResponse =
          await client.from('aset').select('*').eq('id', asetId).maybeSingle();

      if (asetResponse == null) {
        debugPrint('⚠️ No aset found with id: $asetId');
        return sewaResponse;
      }

      // Combine the data
      final result = Map<String, dynamic>.from(sewaResponse);
      result['aset_detail'] = asetResponse;

      debugPrint('✅ Combined sewa_aset and aset data successfully');
      debugPrint('📋 Final combined data:');
      result.forEach((key, value) {
        if (key != 'aset_detail') {
          // Skip the nested object for clearer output
          debugPrint('  $key: $value');
        }
      });

      // Specifically check waktu_mulai and waktu_selesai
      debugPrint('⏰ CRITICAL TIME FIELDS CHECK:');
      debugPrint('  waktu_mulai exists: ${result.containsKey('waktu_mulai')}');
      debugPrint('  waktu_mulai value: ${result['waktu_mulai']}');
      debugPrint(
        '  waktu_selesai exists: ${result.containsKey('waktu_selesai')}',
      );
      debugPrint('  waktu_selesai value: ${result['waktu_selesai']}');

      return result;
    } catch (e) {
      debugPrint('❌ Error fetching sewa_aset with aset data: $e');
      debugPrint('  Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Fungsi untuk mengambil foto pertama dari paket
  Future<String?> _getFirstPaketPhoto(String paketId) async {
    try {
      debugPrint('Fetching first photo for paket ID: $paketId');
      final responsePhoto =
          await client
              .from('foto_aset')
              .select('*')
              .eq('id_paket', paketId)
              .limit(1)
              .maybeSingle();

      if (responsePhoto != null) {
        debugPrint(
          'Found photo for paket $paketId: ${responsePhoto['foto_aset']}',
        );
        return responsePhoto['foto_aset'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching photo for paket $paketId: $e');
      return null;
    }
  }

  // Get paket data with their associated satuan waktu sewa data
  Future<List<dynamic>> getPakets() async {
    try {
      final response = await client
          .from('paket')
          .select('*')
          .order('created_at');
      final List<dynamic> pakets = response;

      // Fetch satuan waktu sewa data for each paket
      for (var paket in pakets) {
        // Fetch the first photo for this paket
        final paketId = paket['id'];
        final photoUrl = await _getFirstPaketPhoto(paketId);
        if (photoUrl != null) {
          paket['gambar_url'] = photoUrl;
        }

        final swsResponse = await client
            .from('satuan_waktu_sewa')
            .select('*, satuan_waktu(id, nama_satuan_waktu)')
            .eq('paket_id', paket['id']);

        // Transform the response to include nama_satuan_waktu
        final List<Map<String, dynamic>> formattedSWS = [];
        for (var sws in swsResponse) {
          final Map<String, dynamic> formattedItem = {...sws};
          if (sws['satuan_waktu'] != null) {
            formattedItem['nama_satuan_waktu'] =
                sws['satuan_waktu']['nama_satuan_waktu'];
          }
          formattedSWS.add(formattedItem);
        }

        paket['satuanWaktuSewa'] = formattedSWS;
      }

      return pakets;
    } catch (e) {
      debugPrint('Error getting pakets: $e');
      rethrow;
    }
  }

  // Order a paket
  Future<bool> orderPaket({
    required String userId,
    required String paketId,
    required String satuanWaktuSewaId,
    required int durasi,
    required int totalHarga,
  }) async {
    try {
      // Get satuan waktu sewa details to determine waktu_mulai and waktu_selesai
      final swsResponse =
          await client
              .from('satuan_waktu_sewa')
              .select('*, satuan_waktu(id, nama)')
              .eq('id', satuanWaktuSewaId)
              .single();

      // Calculate waktu_mulai and waktu_selesai based on satuan waktu
      final DateTime now = DateTime.now();
      final DateTime waktuMulai = now.add(Duration(days: 1)); // Start tomorrow

      // Default to hourly if not specified
      String satuanWaktu = 'jam';
      if (swsResponse['satuan_waktu'] != null &&
          swsResponse['satuan_waktu']['nama'] != null) {
        satuanWaktu = swsResponse['satuan_waktu']['nama'];
      }

      // Calculate waktu_selesai based on satuan waktu and durasi
      DateTime waktuSelesai;
      if (satuanWaktu.toLowerCase() == 'hari') {
        waktuSelesai = waktuMulai.add(Duration(days: durasi));
      } else {
        waktuSelesai = waktuMulai.add(Duration(hours: durasi));
      }

      // Create the order
      final sewa = {
        'user_id': userId,
        'paket_id': paketId,
        'satuan_waktu_sewa_id': satuanWaktuSewaId,
        'kuantitas': 1, // Default to 1 for packages
        'durasi': durasi,
        'total_harga': totalHarga,
        'status': 'MENUNGGU_PEMBAYARAN',
        'waktu_mulai': waktuMulai.toIso8601String(),
        'waktu_selesai': waktuSelesai.toIso8601String(),
      };

      final response = await client.from('sewa_paket').insert(sewa).select();

      if (response.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error ordering paket: $e');
      return false;
    }
  }

  // Get photos for a package
  Future<List<String>> getFotoPaket(String paketId) async {
    try {
      final response = await client
          .from('foto_aset')
          .select('foto_aset')
          .eq('id_paket', paketId)
          .order('created_at');

      if (response != null && response.isNotEmpty) {
        return response
            .map<String>((item) => item['foto_aset'] as String)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting package photos: $e');
      return [];
    }
  }

  // Get items included in a package with additional asset details
  Future<List<Map<String, dynamic>>> getPaketItems(String paketId) async {
    debugPrint('🔄 [1/3] Starting to fetch items for paket ID: $paketId');

    try {
      // 1. First, get the basic package items (aset_id and kuantitas)
      debugPrint('🔍 [2/3] Querying paket_item table for paket_id: $paketId');

      final response = await client
          .from('paket_item')
          .select('''
            aset_id,
            kuantitas
          ''')
          .eq('paket_id', paketId);

      debugPrint('📊 Raw response from paket_item query:');
      debugPrint(response.toString());

      if (response == null) {
        debugPrint('❌ [ERROR] Null response from paket_item query');
        return [];
      }

      if (response.isEmpty) {
        debugPrint(
          'ℹ️ [INFO] No items found in paket_item for paket ID: $paketId',
        );
        return [];
      }

      debugPrint(
        '✅ [SUCCESS] Found [1m${response.length}[0m items in paket_item',
      );

      final List<Map<String, dynamic>> enrichedItems = [];

      // Process each item to fetch additional details
      debugPrint(
        '🔄 [3/3] Processing ${response.length} items to fetch asset details',
      );

      for (var item in response) {
        final String? asetId = item['aset_id']?.toString();
        final int kuantitas = item['kuantitas'] ?? 1;

        debugPrint('\n🔍 Processing item:');
        debugPrint('   - Raw item data: $item');
        debugPrint('   - aset_id: $asetId');
        debugPrint('   - kuantitas: $kuantitas');

        if (asetId == null || asetId.isEmpty) {
          debugPrint('⚠️ [WARNING] Skipping item with null/empty aset_id');
          continue;
        }

        try {
          // 1. Get asset name from aset table
          debugPrint('   - Querying aset table for id: $asetId');
          final asetResponse =
              await client
                  .from('aset')
                  .select('id, nama, deskripsi')
                  .eq('id', asetId)
                  .maybeSingle();

          debugPrint(
            '   - Aset response: ${asetResponse?.toString() ?? 'null'}',
          );

          if (asetResponse == null) {
            debugPrint('⚠️ [WARNING] No asset found with id: $asetId');
            enrichedItems.add({
              'aset_id': asetId,
              'kuantitas': kuantitas,
              'nama_aset': 'Item tidak diketahui',
              'foto_aset': '',
              'semua_foto': <String>[],
              'error': 'Asset not found',
            });
            continue;
          }

          // 2. Get only the first photo from foto_aset table
          debugPrint('   - Querying first photo for id_aset: $asetId');
          final fotoResponse = await client
              .from('foto_aset')
              .select('foto_aset')
              .eq('id_aset', asetId)
              .order('created_at', ascending: true)
              .limit(1);

          String? fotoUtama = '';
          List<String> semuaFoto = [];

          if (fotoResponse.isNotEmpty) {
            final firstFoto = fotoResponse.first['foto_aset']?.toString();
            if (firstFoto != null && firstFoto.isNotEmpty) {
              fotoUtama = firstFoto;
              semuaFoto = [firstFoto];
              debugPrint('   - Found photo: $firstFoto');
            } else {
              debugPrint('   - No valid photo URL found');
            }
          } else {
            debugPrint('   - No photos found for asset $asetId');
          }

          // 4. Combine all data
          final enrichedItem = {
            'aset_id': asetId,
            'kuantitas': kuantitas,
            'nama_aset':
                asetResponse['nama']?.toString() ?? 'Nama tidak tersedia',
            'foto_aset': fotoUtama,
            'semua_foto': semuaFoto,
            'debug': {
              'aset_query': asetResponse,
              'foto_count': semuaFoto.length,
            },
          };

          debugPrint('✅ [ENRICHED ITEM] $enrichedItem');

          enrichedItems.add(enrichedItem);

          // Debug log
          debugPrint('✅ Successfully processed item:');
          debugPrint('   - Aset ID: $asetId');
          debugPrint('   - Nama: ${enrichedItem['nama_aset']}');
          debugPrint('   - Kuantitas: $kuantitas');
          debugPrint('   - Jumlah Foto: ${semuaFoto.length}');
          if (semuaFoto.isNotEmpty) {
            debugPrint('   - Foto Utama: ${semuaFoto.first}');
          }
        } catch (e) {
          debugPrint('❌ Error processing asset $asetId: $e');
          // Still add the basic item even if we couldn't fetch additional details
          enrichedItems.add({
            'aset_id': asetId,
            'kuantitas': item['kuantitas'],
            'nama_aset': 'Nama Aset Tidak Ditemukan',
            'foto_aset': '',
            'semua_foto': <String>[],
          });
        }
      }

      debugPrint(
        '✅ Successfully fetched ${enrichedItems.length} items with details:',
      );
      for (var item in enrichedItems) {
        debugPrint('   - $item');
      }
      return enrichedItems;
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting package items for paket $paketId: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  // Get available bank accounts for payment
  Future<List<Map<String, dynamic>>> getBankAccounts() async {
    try {
      final response = await client
          .from('akun_bank')
          .select('*')
          .order('nama_bank');

      if (response != null && response.isNotEmpty) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting bank accounts: $e');
      return [];
    }
  }

  /// Fetch all packages with their related data (photos and rental time units)
  Future<List<PaketModel>> getAllPaket() async {
    final stopwatch = Stopwatch()..start();
    final String debugId = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(8);

    void log(String message, {bool isError = false, bool isSection = false}) {
      final prefix =
          isError
              ? '❌'
              : isSection
              ? '📌'
              : '   ';
      debugPrint('[$debugId] $prefix $message');
    }

    try {
      log('🚀 Memulai pengambilan data paket...', isSection: true);
      log('📡 Mengambil data paket dari database...');

      // 1) Get all packages
      final paketResponse = await client
          .from('paket')
          .select('*')
          .order('created_at', ascending: false);

      log('📥 Diterima ${paketResponse.length} paket dari database');

      if (paketResponse.isEmpty) {
        log('ℹ️ Tidak ada paket yang ditemukan');
        return [];
      }

      // Convert to list of PaketModel (without relations yet)
      log('\n🔍 Memproses data paket...');
      final List<PaketModel> paketList = [];
      int successCount = 0;

      for (var p in paketResponse) {
        try {
          final paket = PaketModel.fromMap(p as Map<String, dynamic>);
          paketList.add(paket);
          successCount++;
          log('   ✅ Berhasil memproses paket: ${paket.id} - ${paket.nama}');
        } catch (e) {
          log('⚠️ Gagal memproses paket: $e', isError: true);
          log('   Data paket: $p');
        }
      }

      log('\n📊 Ringkasan Pemrosesan:');
      log('   - Total data: ${paketResponse.length}');
      log('   - Berhasil: $successCount');
      log('   - Gagal: ${paketResponse.length - successCount}');

      if (paketList.isEmpty) {
        log('ℹ️ Tidak ada paket yang valid setelah diproses');
        return [];
      }

      // Kumpulkan semua ID paket
      final List<String> paketIds = paketList.map((p) => p.id).toList();
      log('\n📦 Mengambil data tambahan untuk ${paketList.length} paket...');
      log('   ID Paket: ${paketIds.join(', ')}');

      // 2) Ambil semua foto untuk paket-paket ini
      log('\n🖼️ Mengambil data foto...');

      final fotoResp = await client
          .from('foto_aset')
          .select('id_paket, foto_aset')
          .inFilter('id_paket', paketIds);

      log('   Ditemukan ${fotoResp.length} foto');

      // Map packageId -> List<String> photos
      final Map<String, List<String>> mapFoto = {};
      int fotoCount = 0;

      for (var row in fotoResp) {
        try {
          final pid = row['id_paket']?.toString() ?? '';
          final url = row['foto_aset']?.toString() ?? '';
          if (pid.isNotEmpty && url.isNotEmpty) {
            mapFoto.putIfAbsent(pid, () => []).add(url);
            fotoCount++;
          } else {
            log('   ⚠️ Data foto tidak valid: ${row.toString()}');
          }
        } catch (e) {
          log('⚠️ Gagal memproses data foto: $e', isError: true);
        }
      }

      log('   Berhasil memetakan $fotoCount foto ke ${mapFoto.length} paket');

      // 3) Get all satuan_waktu_sewa for these packages
      log('\n⏱️ Mengambil data satuan waktu sewa...');

      final swsResp = await client
          .from('satuan_waktu_sewa')
          .select('paket_id, satuan_waktu_id, harga, maksimal_waktu')
          .inFilter('paket_id', paketIds);

      log('   Ditemukan ${swsResp.length} entri satuan waktu sewa');

      // Process satuan waktu sewa
      final Map<String, List<Map<String, dynamic>>> paketSatuanWaktu = {};
      int swsCount = 0;

      for (var row in swsResp) {
        try {
          final pid = row['paket_id']?.toString() ?? '';
          if (pid.isNotEmpty) {
            final swsData = {
              'satuan_waktu_id': row['satuan_waktu_id'],
              'harga': row['harga'],
              'maksimal_waktu': row['maksimal_waktu'],
            };
            paketSatuanWaktu.putIfAbsent(pid, () => []).add(swsData);
            swsCount++;
          }
        } catch (e) {
          log('⚠️ Gagal memproses satuan waktu sewa: $e', isError: true);
          log('   Data: $row');
        }
      }

      log(
        '   Berhasil memetakan $swsCount satuan waktu ke ${paketSatuanWaktu.length} paket',
      );

      // 4) Gabungkan semua data
      log('\n🔗 Menggabungkan data...');
      final List<PaketModel> result = [];
      int combinedCount = 0;

      for (var paket in paketList) {
        final pid = paket.id;
        log('\n📦 Memproses paket: ${paket.nama} ($pid)');

        try {
          final updatedPaket = paket.copyWith();

          // Lampirkan foto
          if (mapFoto.containsKey(pid)) {
            final fotoList = mapFoto[pid]!;
            updatedPaket.images = List<String>.from(fotoList);

            // Set foto utama jika belum ada
            if (updatedPaket.images!.isNotEmpty &&
                updatedPaket.foto_paket == null) {
              updatedPaket.foto_paket = updatedPaket.images!.first;
              log('   📷 Menambahkan ${fotoList.length} foto');
              log('   🖼️ Foto utama: ${updatedPaket.foto_paket}');
            }
          } else {
            log('   ℹ️ Tidak ada foto untuk paket ini');
          }

          // Lampirkan satuan waktu sewa
          if (paketSatuanWaktu.containsKey(pid)) {
            final swsList = List<Map<String, dynamic>>.from(
              paketSatuanWaktu[pid] ?? [],
            );
            updatedPaket.satuanWaktuSewa = swsList;
            log('   ⏱️ Menambahkan ${swsList.length} satuan waktu sewa');

            // Log detail harga
            for (var sws in swsList.take(2)) {
              // Tampilkan maksimal 2 harga
              log(
                '     - ${sws['harga']} / satuan waktu (ID: ${sws['satuan_waktu_id']})',
              );
            }
            if (swsList.length > 2) {
              log('     - ...dan ${swsList.length - 2} lainnya');
            }
          } else {
            log('   ℹ️ Tidak ada satuan waktu sewa untuk paket ini');
          }

          result.add(updatedPaket);
          combinedCount++;
          log('   ✅ Berhasil memproses paket $pid');
        } catch (e) {
          log('⚠️ Gagal memproses paket $pid: $e', isError: true);
          // Tetap tambahkan paket asli jika gagal diproses
          result.add(paket);
        }
      }

      // Ringkasan eksekusi
      stopwatch.stop();
      log('\n🎉 Selesai!', isSection: true);
      log('📊 Ringkasan Eksekusi:');
      log('   - Total paket: ${paketList.length}');
      log('   - Berhasil diproses: $combinedCount/${paketList.length}');
      log('   - Total foto: $fotoCount');
      log('   - Total satuan waktu: $swsCount');
      log('   - Waktu eksekusi: ${stopwatch.elapsedMilliseconds}ms');
      log('   - ID Debug: $debugId');

      return result;
    } catch (e, stackTrace) {
      log('\n❌ ERROR KRITIS', isError: true);
      log('Pesan error: $e', isError: true);
      log('Stack trace: $stackTrace', isError: true);
      log('ID Debug: $debugId', isError: true);
      rethrow;
      debugPrint('❌ [getAllPaket] Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Update tagihan_dibayar and insert pembayaran
  Future<bool> processPembayaranTagihan({
    required String tagihanSewaId,
    required int nominal,
    required String metodePembayaran,
  }) async {
    try {
      // 1. Get current tagihan_dibayar
      final tagihan =
          await client
              .from('tagihan_sewa')
              .select('tagihan_dibayar')
              .eq('id', tagihanSewaId)
              .maybeSingle();
      int currentDibayar = 0;
      if (tagihan != null && tagihan['tagihan_dibayar'] != null) {
        currentDibayar =
            int.tryParse(tagihan['tagihan_dibayar'].toString()) ?? 0;
      }
      final newDibayar = currentDibayar + nominal;

      // 2. Update tagihan_dibayar
      await client
          .from('tagihan_sewa')
          .update({'tagihan_dibayar': newDibayar})
          .eq('id', tagihanSewaId);

      // 3. Insert pembayaran
      final authProvider = Get.find<AuthProvider>();
      final idPetugas = authProvider.getCurrentUserId();
      final pembayaranData = {
        'tagihan_sewa_id': tagihanSewaId,
        'metode_pembayaran': metodePembayaran,
        'total_pembayaran': nominal,
        'status': 'lunas',
        'created_at': DateTime.now().toIso8601String(),
        'id_petugas': idPetugas,
      };
      await client.from('pembayaran').insert(pembayaranData);
      return true;
    } catch (e) {
      debugPrint('❌ Error processing pembayaran tagihan: $e');
      return false;
    }
  }

  // Update status of sewa_aset by ID
  Future<bool> updateSewaAsetStatus({
    required String sewaAsetId,
    required String status,
  }) async {
    try {
      debugPrint('🔄 Updating status of sewa_aset ID: $sewaAsetId to $status');
      final response = await client
          .from('sewa_aset')
          .update({'status': status})
          .eq('id', sewaAsetId);
      debugPrint('✅ Status updated for sewa_aset ID: $sewaAsetId');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating sewa_aset status: $e');
      return false;
    }
  }

  // Get all payment proof image URLs for a sewa_aset (by tagihan_sewa)
  Future<List<String>> getFotoPembayaranUrlsByTagihanSewaId(
    String sewaAsetId,
  ) async {
    try {
      // 1. Get tagihan_sewa by sewaAsetId
      final tagihan = await getTagihanSewa(sewaAsetId);
      if (tagihan == null || tagihan['id'] == null) return [];
      final tagihanSewaId = tagihan['id'];
      // 2. Fetch all foto_pembayaran for this tagihan_sewa_id
      final List<dynamic> response = await client
          .from('foto_pembayaran')
          .select('foto_pembayaran')
          .eq('tagihan_sewa_id', tagihanSewaId)
          .order('created_at', ascending: false);
      // 3. Extract URLs
      return response
          .map<String>((row) => row['foto_pembayaran']?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching foto pembayaran: $e');
      return [];
    }
  }

  Future<int> countSewaAsetByStatus(List<String> statuses) async {
    // Supabase expects the IN filter as a comma-separated string in parentheses
    final statusString = '(${statuses.map((s) => '"$s"').join(',')})';
    final response = await client
        .from('sewa_aset')
        .select('id')
        .filter('status', 'in', statusString);
    if (response is List) {
      return response.length;
    }
    return 0;
  }
}
