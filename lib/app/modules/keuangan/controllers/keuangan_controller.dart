import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../helpers/local_storage.dart';

class KeuanganController extends GetxController {
  final PimpinanRepository _pimpinanRepository;
  final ApiHelper _apiHelper = ApiHelper();
  final isLoading = false.obs;
  final userRole = 'netizen'.obs;

  final searchController = TextEditingController();

  KeuanganController(this._pimpinanRepository);

  // For Staff/Pimpinan
  final cashStats = <String, dynamic>{}.obs;
  final transactions = <Map<String, dynamic>>[].obs;

  // For Santri/Siswa/OrangTua
  final bills = <Map<String, dynamic>>[].obs;

  // Payment Methods (Bank Accounts)
  final paymentMethods = <Map<String, dynamic>>[].obs;

  // Filter States
  final selectedType = 'Semua'.obs; // Semua, Masuk, Keluar
  final selectedPeriod = 'bulanan'.obs; // daily, weekly, monthly, yearly
  final selectedStatus = 'Semua'.obs; // Semua, Lunas, Belum Lunas
  final searchQuery = ''.obs;

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage.getToken();
    return ApiHelper.tokenHeader(token ?? '');
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
    fetchKeuanganData();
    fetchPaymentMethods();
  }

  @override
  void onClose() {
    searchController.dispose();
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

  bool get isStaffOrPimpinan => [
        'staff_keuangan',
        'pimpinan',
        'staff_pesantren'
      ].contains(userRole.value);

  // Pimpinan can see but cannot create transactions
  bool get canManage =>
      ['staff_keuangan', 'staff_pesantren'].contains(userRole.value);

  void resetFilters() {
    selectedType.value = 'Semua';
    selectedPeriod.value = 'bulanan';
    selectedStatus.value = 'Semua';
    searchQuery.value = '';
    searchController.clear();
    fetchKeuanganData();
  }

  void applyFilters({String? type, String? period, String? status}) {
    if (type != null) selectedType.value = type;
    if (period != null) {
      // Map display name to API filter value
      switch (period) {
        case 'Hari Ini':
          selectedPeriod.value = 'daily';
          break;
        case 'Minggu Ini':
          selectedPeriod.value = 'weekly';
          break;
        case 'Bulan Ini':
          selectedPeriod.value = 'monthly';
          break;
        default:
          selectedPeriod.value = 'bulanan';
      }
    }
    if (status != null) selectedStatus.value = status;
    fetchKeuanganData();
  }

  Future<void> fetchKeuanganData() async {
    try {
      isLoading.value = true;

      if (isStaffOrPimpinan) {
        try {
          final response = await _pimpinanRepository.getFinancing(
            filter: selectedPeriod.value,
            search: searchQuery.value,
            type: selectedType.value,
          );

          if (response['data'] != null && response['data']['summary'] != null) {
            final summary = response['data']['summary'];
            cashStats.value = {
              'saldo': summary['total_saldo'] ?? 0,
              'masuk_bulan_ini': summary['total_masuk_month'] ?? 0,
              'keluar_bulan_ini': summary['total_keluar_month'] ?? 0,
              'tagihan_aktif': 0, // Not available directly in financing list
            };

            final List items = response['data']['items'] ?? [];
            transactions.assignAll(items.map((item) {
              return {
                'title': item['sumber'] ?? item['tujuan'] ?? 'Tanpa Judul',
                'amount': item['jumlah'] ?? 0,
                'type': item['type'] == 'masuk' ? 'Masuk' : 'Keluar',
                'date': item['tanggal'] ?? '',
                'category': item['staf_name'] ?? 'System',
              };
            }).toList());
            return;
          }
        } catch (e) {
          // Handle error silently
        }

        // Fallback to mock data if API fails or not pimpinan role
        cashStats.value = {
          'saldo': 150000000,
          'masuk_bulan_ini': 45000000,
          'keluar_bulan_ini': 12000000,
          'tagihan_aktif': 85000000,
        };
        // ... rest of mock data for transactions

        var rawTransactions = [
          {
            'title': 'Pembayaran SPP - Ahmad',
            'amount': 500000,
            'type': 'Masuk',
            'date': '2026-01-18',
            'category': 'SPP'
          },
          {
            'title': 'Listrik & Air Januari',
            'amount': 2500000,
            'type': 'Keluar',
            'date': '2026-01-17',
            'category': 'Operasional'
          },
          {
            'title': 'Pembayaran SPP - Siti',
            'amount': 450000,
            'type': 'Masuk',
            'date': '2026-01-17',
            'category': 'SPP'
          },
          {
            'title': 'Gaji Staff Kebersihan',
            'amount': 4000000,
            'type': 'Keluar',
            'date': '2026-01-15',
            'category': 'Gaji'
          },
          {
            'title': 'Uang Makan - Budi',
            'amount': 300000,
            'type': 'Masuk',
            'date': '2026-01-14',
            'category': 'Konsumsi'
          },
        ];

        // Apply local filtering for mock demo
        var filtered = rawTransactions.where((item) {
          bool matchType = selectedType.value == 'Semua' ||
              item['type'] == selectedType.value;
          bool matchSearch = searchQuery.value.isEmpty ||
              item['title']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase());
          return matchType && matchSearch;
        }).toList();

        transactions.assignAll(filtered);
      } else {
        var rawBills = [
          {
            'title': 'SPP Januari 2026',
            'amount': 500000,
            'status': 'Unpaid',
            'date': '2026-01-05',
            'period': 'Januari 2026'
          },
          {
            'title': 'Uang Makan Januari 2026',
            'amount': 300000,
            'status': 'Paid',
            'date': '2026-01-04',
            'period': 'Januari 2026'
          },
          {
            'title': 'Pendaftaran Lomba',
            'amount': 50000,
            'status': 'Paid',
            'date': '2026-01-10',
            'period': 'Januari 2026'
          },
          {
            'title': 'Iuran Ekstrakurikuler',
            'amount': 100000,
            'status': 'Unpaid',
            'date': '2026-01-12',
            'period': 'Januari 2026'
          },
        ];

        // Apply local filtering for mock demo
        var filtered = rawBills.where((item) {
          String statusMap = item['status'] == 'Paid' ? 'Lunas' : 'Belum Lunas';
          bool matchStatus = selectedStatus.value == 'Semua' ||
              statusMap == selectedStatus.value;
          bool matchSearch = searchQuery.value.isEmpty ||
              item['title']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase());
          return matchStatus && matchSearch;
        }).toList();

        bills.assignAll(filtered);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPaymentMethods() async {
    try {
      final uri = ApiHelper.buildUri(endpoint: 'payment-methods');
      final response = await _apiHelper.getData(
        uri: uri,
        builder: (data) => data,
        header: _getAuthHeader(),
      );

      if (response != null && response['data'] != null) {
        final List rawList = response['data'] is List
            ? response['data']
            : (response['data']['data'] ?? []);
        paymentMethods.assignAll(rawList
            .where((e) => e['is_active'] == true || e['is_active'] == 1)
            .map((e) => e as Map<String, dynamic>)
            .toList());
      }
    } catch (e) {
      // Fallback mock data
      paymentMethods.assignAll([
        {
          'id': 1,
          'bank_name': 'Bank BRI',
          'account_number': '0123456789012345',
          'account_holder': 'Yayasan Nurul Huda',
          'description': 'Rekening Utama Pesantren',
          'is_active': true,
        },
        {
          'id': 2,
          'bank_name': 'Bank Mandiri',
          'account_number': '1234567890123456',
          'account_holder': 'Yayasan Nurul Huda',
          'description': 'Rekening Alternatif',
          'is_active': true,
        },
      ]);
    }
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Tersalin!',
      'Nomor rekening berhasil disalin',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
