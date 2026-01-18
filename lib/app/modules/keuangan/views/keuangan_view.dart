import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/keuangan_controller.dart';

class KeuanganView extends GetView<KeuanganController> {
  const KeuanganView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keuangan'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showFilterBottomSheet(context),
            icon: const Icon(Icons.filter_list, color: AppColors.primary),
          ),
          Obx(() => controller.canManage
              ? IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add_card_outlined,
                      color: AppColors.primary),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchKeuanganData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                if (controller.isStaffOrPimpinan)
                  _buildStaffHeader()
                else
                  _buildStudentHeader(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.isStaffOrPimpinan
                          ? 'Transaksi Terbaru'
                          : 'Daftar Tagihan',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (!controller.isStaffOrPimpinan)
                      TextButton(
                        onPressed: () {},
                        child: const Text('Riwayat',
                            style: TextStyle(color: AppColors.primary)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActiveFilters(),
                if (controller.isStaffOrPimpinan)
                  _buildTransactionList()
                else
                  _buildBillList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: controller.searchController,
      onChanged: (value) => controller.searchQuery.value = value,
      onSubmitted: (_) => controller.fetchKeuanganData(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari transaksi atau tagihan...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.searchQuery.value.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textLight, size: 20),
                    onPressed: () {
                      controller.searchController.clear();
                      controller.searchQuery.value = '';
                      controller.fetchKeuanganData();
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded,
                      color: AppColors.primary, size: 20),
                  onPressed: () => controller.fetchKeuanganData(),
                ),
              ],
            )),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Obx(() {
      final filters = <Widget>[];
      if (controller.selectedType.value != 'Semua') {
        filters.add(_buildFilterChip(controller.selectedType.value,
            () => controller.applyFilters(type: 'Semua')));
      }
      if (controller.selectedStatus.value != 'Semua') {
        filters.add(_buildFilterChip(controller.selectedStatus.value,
            () => controller.applyFilters(status: 'Semua')));
      }

      if (filters.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Wrap(spacing: 8, children: filters),
      );
    });
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label,
          style: const TextStyle(fontSize: 10, color: AppColors.primary)),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      deleteIcon: const Icon(Icons.close, size: 12, color: AppColors.primary),
      onDeleted: onDeleted,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter Keuangan',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                    onPressed: () => controller.resetFilters(),
                    child: const Text('Reset')),
              ],
            ),
            const SizedBox(height: 20),
            if (controller.isStaffOrPimpinan) ...[
              const Text('Tipe Transaksi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Obx(() => Wrap(
                    spacing: 8,
                    children: ['Semua', 'Masuk', 'Keluar'].map((type) {
                      final isSelected = controller.selectedType.value == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (val) =>
                            controller.applyFilters(type: type),
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 20),
            ],
            if (!controller.isStaffOrPimpinan) ...[
              const Text('Status Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Obx(() => Wrap(
                    spacing: 8,
                    children: ['Semua', 'Lunas', 'Belum Lunas'].map((status) {
                      final isSelected =
                          controller.selectedStatus.value == status;
                      return ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (val) =>
                            controller.applyFilters(status: status),
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Terapkan',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffHeader() {
    final stats = controller.cashStats;
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Saldo Kas',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(stats['saldo'] ?? 0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildSummaryItem(
                    label: 'Masuk',
                    amount:
                        currencyFormat.format(stats['masuk_bulan_ini'] ?? 0),
                    icon: Icons.arrow_downward,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 24),
                  _buildSummaryItem(
                    label: 'Keluar',
                    amount:
                        currencyFormat.format(stats['keluar_bulan_ini'] ?? 0),
                    icon: Icons.arrow_upward,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accentOrange.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.accentOrange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Outstanding Tagihan',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      currencyFormat.format(stats['tagihan_aktif'] ?? 0),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentHeader() {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final totalUnpaid = controller.bills
        .where((b) => b['status'] == 'Unpaid')
        .fold<int>(0, (sum, item) => sum + (item['amount'] as int));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Tagihan Belum Dibayar',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(totalUnpaid),
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Metode Pembayaran Aktif',
                  style: TextStyle(fontSize: 12)),
              Row(
                children: [
                  const Text('Virtual Account ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const Icon(Icons.arrow_forward_ios, size: 10),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      {required String label,
      required String amount,
      required IconData icon,
      required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: color.withOpacity(0.7), fontSize: 11)),
            Text(amount,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (controller.transactions.isEmpty) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(40), child: Text('Tidak ada transaksi')));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.transactions.length,
      itemBuilder: (context, index) {
        final item = controller.transactions[index];
        final isIncome = item['type'] == 'Masuk';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isIncome ? AppColors.success : AppColors.error)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIncome
                      ? Icons.keyboard_double_arrow_down
                      : Icons.keyboard_double_arrow_up,
                  color: isIncome ? AppColors.success : AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '${item['category']} • ${item['date']}',
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                (isIncome ? '+ ' : '- ') +
                    currencyFormat.format(item['amount']),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? AppColors.success : AppColors.error,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBillList() {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (controller.bills.isEmpty) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(40), child: Text('Tidak ada tagihan')));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.bills.length,
      itemBuilder: (context, index) {
        final bill = controller.bills[index];
        final isPaid = bill['status'] == 'Paid';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isPaid ? AppColors.success : AppColors.warning)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
                  color: isPaid ? AppColors.success : AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill['title'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'Jatuh Tempo: ${bill['date']}',
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(bill['amount']),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isPaid ? AppColors.success : AppColors.warning)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPaid ? 'LUNAS' : 'BELUM BAYAR',
                      style: TextStyle(
                        color: isPaid ? AppColors.success : AppColors.warning,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
