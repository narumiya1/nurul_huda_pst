import 'dart:io';
import 'package:epesantren_mob/app/api/address/desa_kelurahan/desa_kelurahan_api.dart';
import 'package:epesantren_mob/app/api/address/desa_kelurahan/desa_kelurahan_repository.dart';
import 'package:epesantren_mob/app/api/address/kecamatan/kecamatan_api.dart';
import 'package:epesantren_mob/app/api/address/kecamatan/kecamatan_repository.dart';
import 'package:epesantren_mob/app/api/address/kota_kab/kota_kab_api.dart';
import 'package:epesantren_mob/app/api/address/kota_kab/kota_kab_repository.dart';
import 'package:epesantren_mob/app/api/address/provinsi/provinsi_api.dart';
import 'package:epesantren_mob/app/api/address/provinsi/provinsi_model.dart';
import 'package:epesantren_mob/app/api/address/provinsi/provinsi_repository.dart';
import 'package:epesantren_mob/app/api/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class RegisterController extends GetxController {
  final AuthRepository _authRepository;

  RegisterController(this._authRepository);

  RxList<ProvinsModel> provinsiDataList = <ProvinsModel>[].obs;

  // Repositories
  late ProvinsiRepository provinsiRepository;
  late final KotaKabRepository kotaKabRepository;
  late final KecamatanRepository kecamatanRepository;
  late final DesaKelurahanRepository desaKelurahanRepository;

  RxList<ProvinsModel> allprovinsiDataList = <ProvinsModel>[].obs;
  final districtList = <ProvinsModel>[].obs;
  RxList<ProvinsModel> allKecamatanDataList = <ProvinsModel>[].obs;
  RxList<ProvinsModel> allDesaKelurahanDataList = <ProvinsModel>[].obs;

  /// Selected Items
  final selectedProvinsi = Rxn<ProvinsModel>();
  final selectedDistrict = Rxn<ProvinsModel>();
  final selectedKecamatan = Rxn<ProvinsModel>();
  final selectedDesaKelurahan = Rxn<ProvinsModel>();

  @override
  void onInit() {
    super.onInit();
    provinsiRepository = ProvinsiRepository(ProvinsiApi());
    kotaKabRepository = KotaKabRepository(KotaKabApi());
    kecamatanRepository = KecamatanRepository(KecamatanApi());
    desaKelurahanRepository = DesaKelurahanRepository(DesaKelurahanApi());

    fetchProvinsi();
  }

  RxBool isLoadingDistrict = false.obs;
  RxBool isLoadingKecamatan = false.obs;
  RxBool isLoadingDesaKelurahan = false.obs;

  Future<void> fetchProvinsi() async {
    try {
      final data = await provinsiRepository.provinsiResponse();

      provinsiDataList.assignAll(data);
      allprovinsiDataList.assignAll(data);

      print('✅ ${provinsiDataList.length} provinsi loaded');
    } catch (e) {
      print("❌ fetchProvinsi error: $e");
      Get.snackbar("Error", "Gagal memuat data provinsi");
    }
  }

  Future<void> fetchDistrict(String provinceId) async {
    districtList.clear();
    selectedDistrict.value = null;

    final data = await kotaKabRepository.districtResponse(provinceId);
    districtList.assignAll(data);
  }

  Future<void> fetchKecamatan(String districtId) async {
    allKecamatanDataList.clear();
    selectedKecamatan.value = null;

    final data = await kecamatanRepository.kecamatanResponse(districtId);
    allKecamatanDataList.assignAll(data);
  }

  Future<void> fetchDesaKelurahan(String kecamatanId) async {
    allDesaKelurahanDataList.clear();
    selectedDesaKelurahan.value = null;

    final data =
        await desaKelurahanRepository.desaKelurahanResponse(kecamatanId);
    allDesaKelurahanDataList.assignAll(data);
  }

  // STEP INDEX
  final stepIndex = 0.obs;

  // DATA DIRI
  final pengguna = ''.obs;
  final namaLengkap = ''.obs;
  final namaPanggilan = ''.obs;
  final nik = ''.obs;
  final phone = ''.obs;
  final tempatLahir = ''.obs;
  final tanggalLahir = ''.obs;
  final jenisKelamin = ''.obs;
  final pekerjaan = ''.obs;

  // DATA ALAMAT
  final provinsi = ''.obs;
  final kabupaten = ''.obs;
  final kecamatan = ''.obs;
  final desa = ''.obs;
  final alamatLengkap = ''.obs;
  final rt = ''.obs;
  final rw = ''.obs;
  final noRumah = ''.obs;

  // DATA PELENGKAP
  final uploadKTP = ''.obs;
  final uploadKK = ''.obs;
  final materialMd5 = ''.obs;

  // UPLOAD BERKAS
  final fotoProfil = Rxn<File>();
  final fotoBerkas1 = Rxn<File>();
  final fotoBerkas2 = Rxn<File>();

  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();

  final isLoading = false.obs;

  // NAVIGASI STEP
  void nextStep() {
    if (stepIndex.value < 7) {
      stepIndex.value++;
    }
  }

  void prevStep() {
    if (stepIndex.value > 0) {
      stepIndex.value--;
    }
  }

  // PICK IMAGE
  Future<void> pickFotoProfil() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      fotoProfil.value = File(image.path);
    }
  }

  Future<void> pickBerkas1() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      fotoBerkas1.value = File(image.path);
    }
  }

  Future<void> pickBerkas2() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      fotoBerkas2.value = File(image.path);
    }
  }

  // LIST NON FORMAL DINAMIS
  final pendidikanNonFormal = <String>[].obs;

  // RIWAYAT PENDIDIKAN
  final sd = ''.obs;
  final smp = ''.obs;
  final sma = ''.obs;
  final s1 = ''.obs;
  final s2 = ''.obs;
  final s3 = ''.obs;

  void tambahPendidikanNonFormal() {
    pendidikanNonFormal.add('');
  }

  // RIWAYAT ORGANISASI DINAMIS
  final organisasiList = <String>[].obs;

  void tambahOrganisasi() {
    organisasiList.add('');
  }

  // SUBMIT AKHIR
  Future<void> submitAkhir() async {
    // Form validation could be added here

    final payload = {
      "full_name": namaLengkap.value,
      "nick_name": namaPanggilan.value,
      "nik": nik.value,
      "phone": phone.value,
      "birth_place": tempatLahir.value,
      "birth_date": tanggalLahir.value,
      "gender": jenisKelamin.value,
      "job": pekerjaan.value,
      "province_id": selectedProvinsi.value?.id,
      "district_id": selectedDistrict.value?.id,
      "subdistrict_id": selectedKecamatan.value?.id,
      "village_id": selectedDesaKelurahan.value?.id,
      "address": alamatLengkap.value,
      "rt": rt.value,
      "rw": rw.value,
      "pendidikan": {
        "sd": sd.value,
        "smp": smp.value,
        "sma": sma.value,
        "s1": s1.value,
        "non_formal": pendidikanNonFormal,
      },
      "organisasi": organisasiList,
    };

    try {
      isLoading.value = true;
      final success = await _authRepository.register(payload);

      if (success) {
        Get.snackbar("Sukses", "Pendaftaran berhasil terkirim.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        Get.offAllNamed('/login');
      } else {
        Get.snackbar("Gagal", "Terjadi kesalahan saat mendaftar.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
