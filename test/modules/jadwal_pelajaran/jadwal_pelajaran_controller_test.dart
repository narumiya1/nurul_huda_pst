import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:epesantren_mob/app/modules/jadwal_pelajaran/controllers/jadwal_pelajaran_controller.dart';
import 'package:epesantren_mob/app/api/guru/guru_repository.dart';
import 'package:epesantren_mob/app/api/guru/guru_api.dart';
import 'package:epesantren_mob/app/api/santri/santri_repository.dart';
import 'package:epesantren_mob/app/api/santri/santri_api.dart';

// Mock APIs
class MockGuruApi extends GuruApi {}

class MockSantriApi extends SantriApi {}

// Mock Repositories
class MockGuruRepository extends GuruRepository {
  MockGuruRepository() : super(MockGuruApi());

  @override
  Future<List<dynamic>> getJadwalPelajaran(
      {Map<String, String>? params}) async {
    return [
      {
        'hari': 'Senin',
        'mapel': 'Matematika',
        'jam_mulai': '07:00',
        'jam_selesai': '08:30'
      },
      {
        'hari': 'Senin',
        'mapel': 'Fisika',
        'jam_mulai': '08:30',
        'jam_selesai': '10:00'
      },
      {
        'hari': 'Selasa',
        'mapel': 'Biologi',
        'jam_mulai': '07:00',
        'jam_selesai': '08:30'
      },
    ];
  }
}

class MockSantriRepository extends SantriRepository {
  MockSantriRepository();

  @override
  Future<List<dynamic>> getJadwalPelajaran() async {
    return [
      {
        'hari': 'Rabu',
        'mapel': 'Kimia',
        'jam_mulai': '07:00',
        'jam_selesai': '08:30'
      }
    ];
  }
}

void main() {
  late JadwalPelajaranController controller;
  late MockGuruRepository mockGuruRepository;
  late MockSantriRepository mockSantriRepository;

  setUp(() {
    Get.testMode = true;
    mockGuruRepository = MockGuruRepository();
    mockSantriRepository = MockSantriRepository();
    controller = JadwalPelajaranController(
        guruRepository: mockGuruRepository,
        santriRepository: mockSantriRepository);
  });

  tearDown(() {
    Get.reset();
  });

  group('JadwalPelajaranController Test', () {
    testWidgets('Initial data loading and grouping (Guru)',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      // Simulate Guru role (default logic uses GuruRepository if not santri/siswa role)
      // Role detection relies on LocalStorage.getUser() which defaults to null -> defaults to Guru behavior in logic?
      // Logic: if (role == 'santri' || role == 'siswa') { ... } else { ... }
      // Since LocalStorage is static and hard to mock without wrapper, we check default path.
      // Default path is GuruRepository.

      await controller.fetchJadwal();

      expect(controller.isLoading.value, false);
      expect(controller.jadwalList.length, 3);

      // Check grouping
      final grouped = controller.groupedJadwal;
      expect(grouped['Senin']?.length, 2);
      expect(grouped['Selasa']?.length, 1);
      expect(grouped['Rabu']?.length, 0); // Guru mock return no Rabu

      await tester.pump(const Duration(seconds: 1)); // Clear timers
    });

    // To test Santri path, we would need to mock LocalStorage return value.
    // Without mocking LocalStorage, we can only test the default path.
  });
}
