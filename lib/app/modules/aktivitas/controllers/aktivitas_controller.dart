import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/api/activity/activity_repository.dart';
import 'package:epesantren_mob/app/core/theme/app_theme.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class AktivitasController extends GetxController {
  final ActivityRepository _repository;

  AktivitasController({ActivityRepository? repository})
      : _repository = repository ?? ActivityRepository();

  final isLoading = false.obs;
  final aktivitasList = <dynamic>[].obs;
  final selectedFilter = 'harian'.obs; // harian, mingguan, bulanan, tahunan

  final selectedActivity = Rxn<dynamic>();
  final isDetailLoading = false.obs;

  final canManage = false.obs;
  final currentUserId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _checkPermission();
    fetchAktivitas();
  }

  void _checkPermission() {
    final user = LocalStorage.getUser();
    String role = '';
    if (user != null) {
      currentUserId.value = user['id'] ?? 0;
      if (user['role'] != null) {
        if (user['role'] is Map) {
          role = user['role']['role_name']?.toString().toLowerCase() ?? '';
        } else if (user['role'] is String) {
          role = user['role'].toString().toLowerCase();
        }
      }
    }

    // Roles authorized to manage activities (as per api routes)
    if ([
      'superadmin',
      'pimpinan',
      'staff_pesantren',
      'guru',
      'guru_pesantren',
      'guru_sekolah'
    ].contains(role)) {
      canManage.value = true;
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    fetchAktivitas();
  }

  Future<void> fetchAktivitas() async {
    try {
      isLoading.value = true;
      final res = await _repository.getActivities(selectedFilter.value);
      aktivitasList.assignAll(res);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchActivityDetail(dynamic id) async {
    try {
      isDetailLoading.value = true;
      final data = await _repository.getActivityDetail(id);
      selectedActivity.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> addActivity(Map<String, dynamic> data) async {
    try {
      Get.back(); // close form
      isLoading.value = true;
      await _repository.createActivity(data);
      Get.snackbar(
        'Sukses',
        'Aktivitas berhasil ditambahkan',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      fetchAktivitas();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menambah aktivitas: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteActivity(dynamic id) async {
    try {
      Get.back(); // close dialog if any
      isLoading.value = true;
      await _repository.deleteActivity(id);
      Get.snackbar(
        'Sukses',
        'Aktivitas berhasil dihapus',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      fetchAktivitas();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menghapus aktivitas: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
