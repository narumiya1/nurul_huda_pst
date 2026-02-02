import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../api/psb/psb_api.dart';
import '../../../api/psb/psb_repository.dart';
import '../../../helpers/local_storage.dart';

class PsbController extends GetxController {
  late final PsbRepository _repository;

  final isLoading = false.obs;
  final registrants = <Map<String, dynamic>>[].obs;
  final filteredRegistrants = <Map<String, dynamic>>[].obs;
  final stats = <String, dynamic>{
    'total': 0,
    'pending': 0,
    'verified': 0,
    'accepted': 0,
    'rejected': 0,
  }.obs;
  final userRole = 'netizen'.obs;
  final searchQuery = ''.obs;
  final selectedStatus = Rxn<String>();

  // Form state
  final currentStep = 0.obs;
  final formData = <String, dynamic>{}.obs;
  final isSubmitting = false.obs;

  // Cek status state
  final statusResult = Rxn<Map<String, dynamic>>();
  final isCheckingStatus = false.obs;

  // Form controllers
  final namaLengkapController = TextEditingController();
  final nisnController = TextEditingController();
  final tempatLahirController = TextEditingController();
  final tanggalLahirController = TextEditingController();
  final alamatController = TextEditingController();
  final anakKeController = TextEditingController();
  final noHpSantriController = TextEditingController();
  final emailSantriController = TextEditingController();

  final namaAyahController = TextEditingController();
  final pekerjaanAyahController = TextEditingController();
  final namaIbuController = TextEditingController();
  final pekerjaanIbuController = TextEditingController();
  final noHpOrtuController = TextEditingController();
  final emailOrtuController = TextEditingController();

  final asalSekolahController = TextEditingController();
  final tahunLulusController = TextEditingController();

  // Cek status controllers
  final noPendaftaranController = TextEditingController();
  final tglLahirCekController = TextEditingController();

  final jenisKelamin = Rxn<String>();
  final selectedTanggalLahir = Rxn<DateTime>();

  // File upload state
  final fileKK = Rxn<File>();
  final fileAkta = Rxn<File>();
  final fileIjazah = Rxn<File>();
  final fileFoto = Rxn<File>();

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _repository = PsbRepository(PsbApi());
    _loadUserRole();
    fetchPsbData();
    debounce(searchQuery, (_) => _filterRegistrants(),
        time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    // Dispose all controllers
    namaLengkapController.dispose();
    nisnController.dispose();
    tempatLahirController.dispose();
    tanggalLahirController.dispose();
    alamatController.dispose();
    anakKeController.dispose();
    noHpSantriController.dispose();
    emailSantriController.dispose();
    namaAyahController.dispose();
    pekerjaanAyahController.dispose();
    namaIbuController.dispose();
    pekerjaanIbuController.dispose();
    noHpOrtuController.dispose();
    emailOrtuController.dispose();
    asalSekolahController.dispose();
    tahunLulusController.dispose();
    noPendaftaranController.dispose();
    tglLahirCekController.dispose();
    super.onClose();
  }

  void _loadUserRole() {
    final user = LocalStorage.getUser();
    if (user != null) {
      final role = user['role'];
      if (role is String) {
        userRole.value = role.toLowerCase();
      } else if (role is Map) {
        userRole.value =
            (role['role_name'] ?? 'netizen').toString().toLowerCase();
      }
    }
  }

  bool get canManage =>
      userRole.value == 'staff_pesantren' || userRole.value == 'pimpinan';

  bool get isLoggedIn => LocalStorage.getToken() != null;

  Future<void> fetchPsbData() async {
    try {
      isLoading.value = true;

      if (canManage) {
        // Fetch real data for admin
        final statsResult = await _repository.getStatistics();
        if (statsResult['success'] == true) {
          stats.value = statsResult['stats'] ?? {};
        }

        final regResult = await _repository.getRegistrations(
          status: selectedStatus.value,
          search: searchQuery.value,
        );
        if (regResult['success'] == true) {
          final data = regResult['data'] as List? ?? [];
          registrants.assignAll(data.map((e) => Map<String, dynamic>.from(e)));
          filteredRegistrants.assignAll(registrants);
        }
      } else {
        // Show placeholder stats for public users
        stats.value = {
          'total': 0,
          'pending': 0,
          'verified': 0,
          'accepted': 0,
          'rejected': 0,
        };
        registrants.clear();
        filteredRegistrants.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _filterRegistrants() {
    final query = searchQuery.value.toLowerCase();
    final status = selectedStatus.value;

    var result = registrants.toList();

    if (query.isNotEmpty) {
      result = result.where((r) {
        final name = (r['nama_lengkap'] ?? '').toString().toLowerCase();
        final nisn = (r['nisn'] ?? '').toString().toLowerCase();
        final noPendaftaran =
            (r['no_pendaftaran'] ?? '').toString().toLowerCase();
        return name.contains(query) ||
            nisn.contains(query) ||
            noPendaftaran.contains(query);
      }).toList();
    }

    if (status != null && status.isNotEmpty) {
      result = result.where((r) => r['status'] == status).toList();
    }

    filteredRegistrants.assignAll(result);
  }

  void filterByStatus(String? status) {
    selectedStatus.value = status;
    _filterRegistrants();
  }

  // Form navigation
  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // Select date
  Future<void> selectTanggalLahir(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedTanggalLahir.value ?? DateTime(2010, 1, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedTanggalLahir.value = picked;
      tanggalLahirController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> selectTanggalLahirCek(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010, 1, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      tglLahirCekController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // Validate step
  bool validateStep(int step) {
    switch (step) {
      case 0:
        // Data Santri
        if (namaLengkapController.text.isEmpty) {
          Get.snackbar('Error', 'Nama lengkap harus diisi',
              backgroundColor: Colors.red, colorText: Colors.white);
          return false;
        }
        if (tempatLahirController.text.isEmpty) {
          Get.snackbar('Error', 'Tempat lahir harus diisi',
              backgroundColor: Colors.red, colorText: Colors.white);
          return false;
        }
        if (selectedTanggalLahir.value == null) {
          Get.snackbar('Error', 'Tanggal lahir harus diisi',
              backgroundColor: Colors.red, colorText: Colors.white);
          return false;
        }
        if (jenisKelamin.value == null) {
          Get.snackbar('Error', 'Jenis kelamin harus dipilih',
              backgroundColor: Colors.red, colorText: Colors.white);
          return false;
        }
        if (alamatController.text.isEmpty) {
          Get.snackbar('Error', 'Alamat harus diisi',
              backgroundColor: Colors.red, colorText: Colors.white);
          return false;
        }
        return true;

      case 1:
        // Data Orang Tua
        if (namaAyahController.text.isEmpty) {
          Get.snackbar('Error', 'Nama ayah harus diisi',
              backgroundColor: Colors.red, colorText: Colors.white);
          return false;
        }
        if (namaIbuController.text.isEmpty) {
          Get.snackbar('Error', 'Nama ibu harus diisi',
              backgroundColor: Colors.red, colorText: Colors.white);
          return false;
        }
        if (noHpOrtuController.text.isEmpty) {
          Get.snackbar('Error', 'No HP orang tua harus diisi',
              backgroundColor: Colors.red, colorText: Colors.white);
          return false;
        }
        return true;

      case 2:
        // Data Asal Sekolah
        if (asalSekolahController.text.isEmpty) {
          Get.snackbar('Error', 'Asal sekolah harus diisi',
              backgroundColor: Colors.red, colorText: Colors.white);
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  // Submit registration
  Future<void> submitRegistration() async {
    if (!validateStep(2)) return;

    try {
      isSubmitting.value = true;

      final data = {
        'nama_lengkap': namaLengkapController.text,
        'nisn': nisnController.text,
        'tempat_lahir': tempatLahirController.text,
        'tanggal_lahir':
            DateFormat('yyyy-MM-dd').format(selectedTanggalLahir.value!),
        'jenis_kelamin': jenisKelamin.value,
        'anak_ke': anakKeController.text.isNotEmpty
            ? int.tryParse(anakKeController.text)
            : null,
        'alamat': alamatController.text,
        'no_hp_santri': noHpSantriController.text,
        'email_santri': emailSantriController.text,
        'nama_ayah': namaAyahController.text,
        'pekerjaan_ayah': pekerjaanAyahController.text,
        'nama_ibu': namaIbuController.text,
        'pekerjaan_ibu': pekerjaanIbuController.text,
        'no_hp_ortu': noHpOrtuController.text,
        'email_ortu': emailOrtuController.text,
        'asal_sekolah': asalSekolahController.text,
        'tahun_lulus': tahunLulusController.text,
      };

      // Prepare files
      final files = <String, File?>{
        'file_kk': fileKK.value,
        'file_akta': fileAkta.value,
        'file_ijazah': fileIjazah.value,
        'file_foto': fileFoto.value,
      };

      final result = await _repository.submitRegistration(
        formData: data,
        files: files,
      );

      if (result['success'] == true) {
        final noPendaftaran = result['data']?['no_pendaftaran'] ?? '';
        Get.dialog(
          AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('Berhasil!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pendaftaran Anda telah berhasil dikirim.'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nomor Pendaftaran:',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              noPendaftaran,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => copyToClipboard(noPendaftaran),
                        icon: const Icon(Icons.copy, color: Colors.green),
                        tooltip: 'Salin',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Simpan nomor pendaftaran ini untuk mengecek status pendaftaran Anda.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => copyToClipboard(noPendaftaran),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Salin'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                  _clearForm();
                },
                child: const Text('OK'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        Get.snackbar(
          'Gagal',
          result['message'] ?? 'Terjadi kesalahan saat mendaftar',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _clearForm() {
    currentStep.value = 0;
    namaLengkapController.clear();
    nisnController.clear();
    tempatLahirController.clear();
    tanggalLahirController.clear();
    alamatController.clear();
    anakKeController.clear();
    noHpSantriController.clear();
    emailSantriController.clear();
    namaAyahController.clear();
    pekerjaanAyahController.clear();
    namaIbuController.clear();
    pekerjaanIbuController.clear();
    noHpOrtuController.clear();
    emailOrtuController.clear();
    asalSekolahController.clear();
    tahunLulusController.clear();
    jenisKelamin.value = null;
    selectedTanggalLahir.value = null;
    fileKK.value = null;
    fileAkta.value = null;
    fileIjazah.value = null;
    fileFoto.value = null;
  }

  // Copy text to clipboard
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Berhasil',
      'Nomor pendaftaran berhasil disalin',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Pick file for document upload
  Future<void> pickDocument(String docType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        // Check file size (max 2MB)
        if (fileSize > 2 * 1024 * 1024) {
          Get.snackbar(
            'Error',
            'Ukuran file maksimal 2MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        switch (docType) {
          case 'kk':
            fileKK.value = file;
            break;
          case 'akta':
            fileAkta.value = file;
            break;
          case 'ijazah':
            fileIjazah.value = file;
            break;
          case 'foto':
            fileFoto.value = file;
            break;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih file: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Pick photo from camera or gallery
  Future<void> pickPhoto({bool fromCamera = false}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();

        if (fileSize > 2 * 1024 * 1024) {
          Get.snackbar(
            'Error',
            'Ukuran foto maksimal 2MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        fileFoto.value = file;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil foto: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Remove file
  void removeFile(String docType) {
    switch (docType) {
      case 'kk':
        fileKK.value = null;
        break;
      case 'akta':
        fileAkta.value = null;
        break;
      case 'ijazah':
        fileIjazah.value = null;
        break;
      case 'foto':
        fileFoto.value = null;
        break;
    }
  }

  // Get file name helper
  String getFileName(File? file) {
    if (file == null) return '';
    return file.path.split('/').last.split('\\').last;
  }

  // Cek Status
  Future<void> cekStatusPendaftaran() async {
    if (noPendaftaranController.text.isEmpty) {
      Get.snackbar('Error', 'Masukkan nomor pendaftaran',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (tglLahirCekController.text.isEmpty) {
      Get.snackbar('Error', 'Masukkan tanggal lahir',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isCheckingStatus.value = true;
      statusResult.value = null;

      final result = await _repository.cekStatus(
        noPendaftaran: noPendaftaranController.text,
        tanggalLahir: tglLahirCekController.text,
      );

      if (result['success'] == true) {
        statusResult.value = result['data'];
      } else {
        Get.snackbar(
            'Tidak Ditemukan', result['message'] ?? 'Data tidak ditemukan',
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengecek status: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isCheckingStatus.value = false;
    }
  }

  // Admin actions
  Future<void> updateRegistrationStatus(int id, String status,
      {String? catatan}) async {
    try {
      final result = await _repository.updateStatus(
        id: id,
        status: status,
        catatan: catatan,
      );

      if (result['success'] == true) {
        Get.snackbar('Berhasil', result['message'],
            backgroundColor: Colors.green, colorText: Colors.white);
        await fetchPsbData();
      } else {
        Get.snackbar('Gagal', result['message'] ?? 'Gagal update status',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal update status: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
