import 'package:epesantren_mob/app/widgets/custom_bottom.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const ChatPage();
      case 2:
        return const NotifikasiPage();
      case 3:
        return const ProfilPage();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: _buildPage(controller.selectedIndex.value),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}

class HomePage extends GetView<DashboardController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _welcomeCard(),
            const SizedBox(height: 12),
            _beritaTab(),
            const SizedBox(height: 20),
            _menuList(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 16),
          Image.asset('assets/logos.png', height: 28),
          const SizedBox(width: 8),
          const Text(
            "Sentral Nurulhuda",
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {},
        )
      ],
    );
  }

  Widget _welcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff0F3D26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage('assets/avatar.png'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Selamat Datang Ridwan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Pengurus Pesantren",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _beritaTab() {
    return Obx(() {
      if (controller.isLoadingBerita.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.beritaList.isEmpty) {
        return const Center(child: Text("Belum ada berita terbaru"));
      }

      return Column(
        children: [
          SizedBox(
            height: 100,
            child: PageView.builder(
              itemCount: controller.beritaList.length,
              onPageChanged: (i) => controller.changeBerita(i),
              itemBuilder: (context, i) {
                final berita = controller.beritaList[i];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(12)),
                        child: berita.image != null
                            ? Image.network(berita.image!,
                                width: 100, height: 100, fit: BoxFit.cover)
                            : Container(
                                width: 100,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                berita.category ?? "News",
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                berita.title ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.beritaList.length,
              (i) => Container(
                width: controller.selectedBeritaIndex.value == i ? 16 : 8,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: controller.selectedBeritaIndex.value == i
                      ? Colors.black
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          )
        ],
      );
    });
  }

  Widget _menuList() {
    return Column(
      children: [
        _menuItem(
          title: "Manajemen SDM",
          color: Colors.blue,
          icon: Icons.groups,
        ),
        _menuItem(
          title: "Manajemen Dokumen",
          color: Colors.redAccent,
          icon: Icons.folder,
        ),
        _menuItem(
          title: "Manajemen Kurikulum",
          color: Colors.indigo,
          icon: Icons.menu_book,
        ),
        _menuItem(
          title: "Manajemen Aktivitas",
          color: Colors.lightGreen,
          icon: Icons.event,
        ),
        _menuItem(
          title: "Manajemen Keuangan",
          color: Colors.green.shade900,
          icon: Icons.account_balance_wallet,
        ),
      ],
    );
  }

  Widget _menuItem({
    required String title,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}

class ChatPage extends GetView<DashboardController> {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Chat Page")),
    );
  }
}

class NotifikasiPage extends GetView<DashboardController> {
  const NotifikasiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Notifikasi Page")),
    );
  }
}

class ProfilPage extends GetView<DashboardController> {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Profil Page")),
    );
  }
}
