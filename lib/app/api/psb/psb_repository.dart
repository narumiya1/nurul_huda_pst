import 'dart:io';
import 'package:epesantren_mob/app/api/psb/psb_api.dart';

class PsbRepository {
  final PsbApi _psbApi;

  PsbRepository(this._psbApi);

  /// Submit pendaftaran santri baru
  Future<Map<String, dynamic>> submitRegistration({
    required Map<String, dynamic> formData,
    Map<String, File?>? files,
  }) async {
    try {
      dynamic response;

      if (files != null && files.values.any((f) => f != null)) {
        // Convert form data to string fields for multipart
        final fields = <String, String>{};
        formData.forEach((key, value) {
          if (value != null) {
            fields[key] = value.toString();
          }
        });

        response = await _psbApi.registerWithFiles(
          fields: fields,
          files: files,
        );
      } else {
        response = await _psbApi.register(formData);
      }

      return {
        'success': true,
        'message': response['message'] ?? 'Pendaftaran berhasil',
        'data': response['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Cek status pendaftaran
  Future<Map<String, dynamic>> cekStatus({
    required String noPendaftaran,
    required String tanggalLahir,
  }) async {
    try {
      final response = await _psbApi.cekStatus(
        noPendaftaran: noPendaftaran,
        tanggalLahir: tanggalLahir,
      );

      return {
        'success': true,
        'data': response['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Get statistics (Admin)
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _psbApi.getStatistics();

      return {
        'success': true,
        'stats': response['stats'],
        'monthly': response['monthly'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Get registrations list (Admin)
  Future<Map<String, dynamic>> getRegistrations({
    int page = 1,
    String? status,
    String? search,
  }) async {
    try {
      final response = await _psbApi.getRegistrations(
        page: page,
        status: status,
        search: search,
      );

      return {
        'success': true,
        'data': response['data'] ?? [],
        'meta': response['meta'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
        'data': [],
      };
    }
  }

  /// Get registration detail (Admin)
  Future<Map<String, dynamic>> getRegistrationDetail(int id) async {
    try {
      final response = await _psbApi.getRegistrationDetail(id);

      return {
        'success': true,
        'data': response['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Update registration status (Admin)
  Future<Map<String, dynamic>> updateStatus({
    required int id,
    required String status,
    String? catatan,
  }) async {
    try {
      final response = await _psbApi.updateStatus(
        id: id,
        status: status,
        catatanAdmin: catatan,
      );

      return {
        'success': true,
        'message': response['message'] ?? 'Status berhasil diupdate',
        'data': response['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
}
