import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class SantriRepository {
  final ApiHelper _apiHelper = ApiHelper();

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage.getToken();
    return ApiHelper.tokenHeader(token ?? '');
  }

  Future<List<dynamic>> getPerizinan() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'santri/my-perizinan');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) =>
            data is Map && data['data'] is List ? data['data'] : [],
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitPerizinan(Map<String, dynamic> data) async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'santri/my-perizinan');
      final response = await _apiHelper.postData(
        uri: uri,
        jsonBody: data,
        builder: (data) => data,
        header: _getAuthHeader(),
      );
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getPelanggaran() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'kedisiplinan/pelanggaran');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) {
          if (data is Map && data['data'] != null) {
            final raw = data['data'];
            if (raw is List) return raw;
            if (raw is Map && raw['data'] is List) return raw['data'];
          }
          return [];
        },
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitPelanggaran(Map<String, dynamic> data) async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'kedisiplinan/pelanggaran');
      final response = await _apiHelper.postData(
        uri: uri,
        jsonBody: data,
        builder: (data) => data,
        header: _getAuthHeader(),
      );
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getSantriList(
      {String? search, int? kelasId, int? kamarId}) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (kelasId != null) queryParams['kelas_id'] = kelasId.toString();
      if (kamarId != null) queryParams['kamar_id'] = kamarId.toString();

      final uri = ApiHelper.buildUri(endpoint: 'santri', params: queryParams);
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) {
          if (data is Map && data['data'] != null) {
            final raw = data['data'];
            if (raw is List) return raw;
            if (raw is Map && raw['data'] is List) return raw['data'];
          }
          return [];
        },
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getTugasSekolah() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'sekolah/tugas');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) {
          // Response structure: { meta: {...}, data: { current_page: 1, data: [...] } }
          if (data is Map && data['data'] != null) {
            final innerData = data['data'];
            if (innerData is Map && innerData['data'] is List) {
              return innerData['data'];
            }
            if (innerData is List) return innerData;
          }
          return [];
        },
        header: _getAuthHeader(),
      );
      debugPrint('Tugas Sekolah fetched: ${response.length} items');
      return response;
    } catch (e) {
      debugPrint('Error fetching tugas sekolah: $e');
      return [];
    }
  }

  Future<List<dynamic>> getTugasPondok() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'tugas-santri');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) {
          if (data is Map && data['data'] != null) {
            return data['data'] is List ? data['data'] : [];
          }
          return [];
        },
        header: _getAuthHeader(),
      );
      debugPrint('Tugas Pondok fetched: ${response.length} items');
      return response;
    } catch (e) {
      debugPrint('Error fetching tugas pondok: $e');
      return [];
    }
  }

  Future<bool> submitTugasPondok(Map<String, dynamic> payload) async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'submit-tugas-santri');
      final response = await _apiHelper.postData(
        uri: uri,
        jsonBody: payload,
        builder: (data) => data,
        header: _getAuthHeader(),
      );
      return response['success'] == true;
    } catch (e) {
      debugPrint('Error submitting tugas pondok: $e');
      return false;
    }
  }

  Future<List<dynamic>> getMateriList() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'kurikulum-mapel');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) {
          if (data is Map && data['data'] != null) {
            // Ensure we get the list correctly
            if (data['data'] is List) return data['data'];
            if (data['data']['data'] is List) return data['data']['data'];
          }
          return [];
        },
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      debugPrint('Error fetching materi: $e');
      return [];
    }
  }

  Future<bool> submitTugas(Map<String, String> fields,
      {List<File>? files}) async {
    try {
      final submitUri = ApiHelper.buildUri(endpoint: 'sekolah/tugas/submit');
      final chunkUri =
          ApiHelper.buildUri(endpoint: 'sekolah/tugas/upload-chunk');

      List<String> existingFiles = [];
      Map<String, File> smallFiles = {};

      if (files != null && files.isNotEmpty) {
        for (int i = 0; i < files.length; i++) {
          final file = files[i];
          final length = await file.length();

          if (length > 2 * 1024 * 1024) {
            // > 2MB, use chunk
            final path = await _uploadFileChunked(file, chunkUri);
            if (path != null) {
              existingFiles.add(path);
            } else {
              return false; // Fail if chunk upload fails
            }
          } else {
            smallFiles['files[$i]'] = file;
          }
        }
      }

      // Add existing_files to fields need to send as array.
      // Since standard postImageData might strictly treat fields as string map,
      // we might need to handle array fields.
      // If ApiHelper checks headers:
      // A trick for standard multipart: send keys 'existing_files[0]', 'existing_files[1]'
      if (smallFiles.isNotEmpty) {
        // Multipart request: keys with [index] work for Laravel array fields
        Map<String, String> finalFields = Map.from(fields);
        for (int i = 0; i < existingFiles.length; i++) {
          finalFields['existing_files[$i]'] = existingFiles[i];
        }

        final response = await _apiHelper.postImageData(
          uri: submitUri,
          fields: finalFields,
          files: smallFiles,
          builder: (data) => data,
          header: _getAuthHeader(),
        );
        return response['success'] == true;
      } else {
        // JSON request: just send as List
        final Map<String, dynamic> jsonBody = Map<String, dynamic>.from(fields);
        if (existingFiles.isNotEmpty) {
          jsonBody['existing_files'] = existingFiles;
        }

        final response = await _apiHelper.postData(
          uri: submitUri,
          jsonBody: jsonBody,
          builder: (data) => data,
          header: _getAuthHeader(),
        );
        return response['success'] == true;
      }
    } catch (e) {
      debugPrint('Error submitting tugas: $e');
      return false;
    }
  }

  Future<String?> _uploadFileChunked(File file, Uri uri) async {
    try {
      const int chunkSize = 1 * 1024 * 1024; // 1 MB chunks
      final int totalSize = await file.length();
      final int totalChunks = (totalSize / chunkSize).ceil();
      final String uploadId = DateTime.now().millisecondsSinceEpoch.toString();
      final String filename = file.path.split('/').last;

      for (int i = 0; i < totalChunks; i++) {
        final int start = i * chunkSize;
        final int end =
            (start + chunkSize < totalSize) ? start + chunkSize : totalSize;
        final Stream<List<int>> stream = file.openRead(start, end);

        // We need to read stream to bytes to send as file part
        final List<int> chunkBytes = await stream.expand((x) => x).toList();

        // Create a temp file for the chunk to use generic postImageData if needed
        // Or better constructing multipart request manually?
        // Relying on _apiHelper.postImageData allows 'files' param to be Bytes?
        // Usually postImageData expects File.
        // We can create temp file.
        final tempChunk = File('${file.parent.path}/temp_chunk_$uploadId');
        await tempChunk.writeAsBytes(chunkBytes);

        final response = await _apiHelper.postImageData(
          uri: uri,
          fields: {
            'upload_id': uploadId,
            'chunk_index': i.toString(),
            'total_chunks': totalChunks.toString(),
            'client_filename': filename,
          },
          files: {'file': tempChunk},
          builder: (data) => data,
          header: _getAuthHeader(),
        );

        await tempChunk.delete();

        if (response['data'] != null && response['data']['is_done'] == true) {
          return response['data']['file_path'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Chunk upload failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'user/my-profile');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) {
          if (data is Map && data['data'] is Map) {
            if (data['data']['user'] != null) return data['data']['user'];
            return data['data'];
          }
          return null;
        },
        header: _getAuthHeader(),
      );
      return response as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getMyBills() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'santri/my-bills');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) {
          if (data is Map && data['data'] != null) {
            final raw = data['data'];
            if (raw is List) return raw;
            if (raw is Map && raw['data'] is List) return raw['data'];
          }
          return data is List ? data : [];
        },
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      debugPrint('Error fetching my-bills: $e');
      return [];
    }
  }

  Future<List<dynamic>> getMyPayments() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'santri/my-payments');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) {
          if (data is Map && data['data'] is List) return data['data'];
          return data is List ? data : [];
        },
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      debugPrint('Error fetching my-payments: $e');
      return [];
    }
  }

  Future<List<dynamic>> getMyAbsensi() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'santri/my-absensi');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) => data['data'] is List ? data['data'] : [],
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      debugPrint('Error fetching my-absensi: $e');
      return [];
    }
  }

  Future<bool> payBill(int billId,
      {File? proof, String? notes, String method = 'Transfer'}) async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'santri/my-bills/$billId/pay');

      final fields = {
        'metode_pembayaran': method,
      };
      if (notes != null) fields['catatan'] = notes;

      final Map<String, File?> files = {
        if (proof != null) 'bukti_pembayaran': proof,
      };

      final response = await _apiHelper.postImageData(
        uri: uri,
        fields: fields,
        files: files,
        builder: (data) => data,
        header: _getAuthHeader(),
      );

      return response['meta']?['code'] == 200 || response['success'] == true;
    } catch (e) {
      debugPrint('Error paying bill: $e');
      return false;
    }
  }

  Future<List<dynamic>> getKelasList() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'kelas');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) =>
            data is Map && data['data'] is List ? data['data'] : [],
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getMyKelasList() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'guru/my-kelas');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) =>
            data is Map && data['data'] is List ? data['data'] : [],
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getKamarList() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'pondok/kamar');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) =>
            data is Map && data['data'] is List ? data['data'] : [],
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getNilaiSekolah({
    String? semester,
    String? tahun,
    int? siswaId,
    String? tahunAjaran,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (semester != null) queryParams['semester'] = semester.toLowerCase();
      if (tahun != null) queryParams['tahun_ajaran'] = tahun;
      if (siswaId != null) queryParams['siswa_id'] = siswaId.toString();
      if (tahunAjaran != null) queryParams['tahun_ajaran'] = tahunAjaran;

      final uri =
          ApiHelper.buildUri(endpoint: 'sekolah/nilai', params: queryParams);
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) {
          if (data is Map && data['data'] is List) {
            return data['data'];
          }
          return data is List ? data : [];
        },
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getMyTahfidz() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'santri/my-tahfidz');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) =>
            data is Map && data['data'] is Map ? data['data'] : {},
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      debugPrint('Error fetching my-tahfidz: $e');
      return {};
    }
  }

  Future<List<dynamic>> getJadwalPelajaran() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'santri/my-schedule');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) => data['data'] is List ? data['data'] : [],
        header: _getAuthHeader(),
      );
      debugPrint('Jadwal fetched: ${response.length} items');
      return response;
    } catch (e) {
      debugPrint('Error fetching my-schedule: $e');
      return [];
    }
  }

  Future<List<dynamic>> getTugasSubmissions(String tugasId) async {
    try {
      final uri = ApiHelper.buildUri(
          endpoint: 'sekolah/tugas/submissions',
          params: {'tugas_sekolah_id': tugasId});
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) => data['data'] is List ? data['data'] : [],
        header: _getAuthHeader(),
      );
      return response;
    } catch (e) {
      debugPrint('Error fetching submissions: $e');
      return [];
    }
  }

  Future<bool> gradeTugasSubmission(
      String submissionId, double grade, String? notes) async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'sekolah/tugas/grade');
      final response = await _apiHelper.postData(
        uri: uri,
        jsonBody: {
          'submission_id': submissionId,
          'nilai': grade,
          'catatan_guru': notes,
        },
        builder: (data) => data,
        header: _getAuthHeader(),
      );
      return response['success'] == true;
    } catch (e) {
      debugPrint('Error grading submission: $e');
      return false;
    }
  }
}
