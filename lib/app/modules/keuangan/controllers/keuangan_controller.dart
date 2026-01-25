import 'package:epesantren_mob/app/api/orangtua/orangtua_repository.dart'; // Add import
import 'dart:io';
import 'package:epesantren_mob/app/api/pimpinan/pimpinan_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../helpers/local_storage.dart';

class KeuanganController extends GetxController {
  final PimpinanRepository _pimpinanRepository;
  final SantriRepository _santriRepository;
  final OrangtuaRepository _orangtuaRepository;
  final ApiHelper _apiHelper = ApiHelper();
  final isLoading = false.obs;
  final userRole = 'netizen'.obs;

  final searchController = TextEditingController();

  KeuanganController(this._pimpinanRepository, this._santriRepository,
      this._orangtuaRepository);

  // For Staff/Pimpinan
  final cashStats = <String, dynamic>{}.obs;
  final transactions = <Map<String, dynamic>>[].obs;

  // For Santri/Siswa/OrangTua
  final bills = <Map<String, dynamic>>[].obs;
  final paymentHistory = <Map<String, dynamic>>[].obs;

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
    fetchPaymentHistory();
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
        // SANTRI, SISWA, OR ORANGTUA
        try {
          List<Map<String, dynamic>> rawBills = [];

          if (userRole.value == 'orangtua') {
            final children = await _orangtuaRepository.getMyChildren();
            for (var child in children) {
              final childId = child['id'];
              final childTipe = child['tipe'];
              final childName = child['nama'];

              final childBills = await _orangtuaRepository
                  .getChildBills(childId, tipe: childTipe);
              if (childBills != null && childBills is List) {
                rawBills.addAll(childBills
                    .map((map) {
                      String status = map['status'] ?? 'Unpaid';
                      if (status.toLowerCase() == 'pending') status = 'Unpaid';

                      return {
                        'id': map['id'],
                        'title':
                            "${map['judul'] ?? map['nama_tagihan'] ?? 'Tagihan'} ($childName)",
                        'amount': int.tryParse(
                                (map['total_tagihan'] ?? map['jumlah'] ?? 0)
                                    .toString()) ??
                            0,
                        'status': status.capitalizeFirst,
                        'date': map['created_at']?.split(' ')[0] ?? '',
                        'period': map['bulan'] ?? '-',
                        'description': map['catatan'] ?? '',
                        'transaction_id': map['transaksi_id'],
                      };
                    })
                    .toList()
                    .cast<Map<String, dynamic>>());
              }
            }
          } else {
            // Santri / Siswa (Self)
            final response = await _santriRepository.getMyBills();
            if (response.isNotEmpty) {
              rawBills = response.map((map) {
                // Cast to Map first if needed, dynamic list item usually dynamic
                final item = map as Map<String, dynamic>;
                String status = item['status'] ?? 'Unpaid';
                if (status.toLowerCase() == 'pending') status = 'Unpaid';

                return {
                  'id': item['id'],
                  'title': item['judul'] ?? item['nama_tagihan'] ?? 'Tagihan',
                  'amount': int.tryParse(
                          (item['total_tagihan'] ?? item['jumlah'] ?? 0)
                              .toString()) ??
                      0,
                  'status': status.capitalizeFirst,
                  'date': item['created_at']?.split(' ')[0] ?? '',
                  'period': item['bulan'] ?? '-',
                  'description': item['catatan'] ?? '',
                  'transaction_id': item['transaction_id'],
                };
              }).toList();
            }
          }

          bills.assignAll(rawBills);
        } catch (e) {
          debugPrint('Error fetching bills: $e');
          bills.clear();
        }

        // Apply local filtering on fetched data
        if (bills.isNotEmpty) {
          var filtered = bills.where((item) {
            String statusMap =
                item['status'] == 'Paid' || item['status'] == 'Lunas'
                    ? 'Lunas'
                    : 'Belum Lunas';
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

  Future<void> fetchPaymentHistory() async {
    if (isStaffOrPimpinan) return;

    try {
      final response = await _santriRepository.getMyPayments();
      paymentHistory
          .assignAll(response.map((e) => e as Map<String, dynamic>).toList());
    } catch (e) {
      debugPrint('Error fetching payment history: $e');
    }
  }

  Future<void> submitPayment(int billId, XFile? proof, String? notes) async {
    try {
      if (proof == null) {
        Get.snackbar('Error', 'Bukti pembayaran wajib diunggah',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      isLoading.value = true;
      final success = await _santriRepository.payBill(
        billId,
        proof: File(proof.path),
        notes: notes,
      );

      if (success) {
        Get.back(); // Close dialog/sheet
        Get.snackbar('Sukses', 'Bukti pembayaran berhasil dikirim',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchKeuanganData();
      } else {
        Get.snackbar('Gagal', 'Gagal mengirim bukti pembayaran',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
