import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import 'custom_widgets.dart';

class FeaturePlaceholderView extends StatelessWidget {
  const FeaturePlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil argumen secara aman
    dynamic args = Get.arguments;
    final String title = (args is String) ? args : "Fitur";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, double value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 2,
                        color: AppColors.primary.withOpacity(0.2),
                      );
                    },
                  ),
                  Icon(
                    _getIconForFeature(title),
                    size: 80,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "Halaman $title",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Mohon maaf, fitur ini sedang dalam tahap pengembangan untuk memberikan pengalaman terbaik bagi Anda.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            PrimaryButton(
              text: "Kembali ke Beranda",
              onPressed: () => Get.back(),
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForFeature(String title) {
    switch (title) {
      case 'Manajemen SDM':
        return Icons.people_alt_outlined;
      case 'Dokumen':
        return Icons.folder_outlined;
      case 'Kurikulum':
        return Icons.menu_book_outlined;
      case 'Aktivitas':
        return Icons.event_outlined;
      case 'Keuangan':
        return Icons.account_balance_wallet_outlined;
      case 'Absensi':
        return Icons.fact_check_outlined;
      case 'Tahfidz':
        return Icons.auto_stories_outlined;
      case 'Asrama':
        return Icons.home_outlined;
      default:
        return Icons.construction_rounded;
    }
  }
}
