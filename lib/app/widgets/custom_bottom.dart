import 'package:epesantren_mob/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBottomNav extends GetView<DashboardController> {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(Icons.house_rounded, "Dashboard", 0),
            _navItem(Icons.history_rounded, "Chat", 1),
            _navItem(Icons.report, "Notifikasi", 2),
            _navItem(Icons.settings, "Profil", 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = controller.selectedIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.green : Colors.grey,
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? Colors.green : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}
