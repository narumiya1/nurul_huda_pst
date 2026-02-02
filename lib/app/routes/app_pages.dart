import 'package:get/get.dart';

import '../core/widgets/feature_placeholder_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/keuangan/bindings/keuangan_binding.dart';
import '../modules/keuangan/views/keuangan_view.dart';
import '../modules/absensi/bindings/absensi_binding.dart';
import '../modules/absensi/views/absensi_view.dart';
import '../modules/tahfidz/bindings/tahfidz_binding.dart';
import '../modules/tahfidz/views/tahfidz_view.dart';
import '../modules/aktivitas/bindings/aktivitas_binding.dart';
import '../modules/aktivitas/views/aktivitas_view.dart';
import '../modules/profil/bindings/profil_binding.dart';
import '../modules/profil/views/profil_view.dart';
import '../modules/manajemen_sdm/bindings/manajemen_sdm_binding.dart';
import '../modules/manajemen_sdm/views/manajemen_sdm_view.dart';
import '../modules/manajemen_sdm/views/manajemen_sdm_detail_view.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';
import '../modules/psb/bindings/psb_binding.dart';
import '../modules/psb/views/psb_view.dart';
import '../modules/psb/views/psb_form_view.dart';
import '../modules/psb/views/psb_cek_status_view.dart';
import '../modules/pondok/bindings/pondok_binding.dart';
import '../modules/pondok/views/pondok_view.dart';
import '../modules/administrasi/bindings/administrasi_binding.dart';
import '../modules/administrasi/views/administrasi_view.dart';
import '../modules/monitoring/bindings/monitoring_binding.dart';
import '../modules/monitoring/views/monitoring_view.dart';
import '../modules/akademik_pondok/bindings/akademik_pondok_binding.dart';
import '../modules/akademik_pondok/views/akademik_pondok_view.dart';

import '../modules/pelanggaran/bindings/pelanggaran_binding.dart';
import '../modules/pelanggaran/views/pelanggaran_view.dart';

import '../modules/teacher_area/bindings/teacher_area_binding.dart';
import '../modules/teacher_area/views/teacher_area_view.dart';
import '../modules/dashboard/views/berita_detail_view.dart';
import '../modules/jadwal_pelajaran/bindings/jadwal_pelajaran_binding.dart';
import '../modules/jadwal_pelajaran/views/jadwal_pelajaran_view.dart';
import '../modules/claim_child/claim_child_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.welcome;

  static final routes = [
    GetPage(
      name: _Paths.welcome,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: _Paths.pelanggaran,
      page: () => const PelanggaranView(),
      binding: PelanggaranBinding(),
    ),
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.featurePlaceholder,
      page: () => const FeaturePlaceholderView(),
    ),
    GetPage(
      name: _Paths.keuangan,
      page: () => const KeuanganView(),
      binding: KeuanganBinding(),
    ),
    GetPage(
      name: _Paths.absensi,
      page: () => const AbsensiView(),
      binding: AbsensiBinding(),
    ),
    GetPage(
      name: _Paths.tahfidz,
      page: () => const TahfidzView(),
      binding: TahfidzBinding(),
    ),
    GetPage(
      name: _Paths.aktivitas,
      page: () => const AktivitasView(),
      binding: AktivitasBinding(),
    ),
    GetPage(
      name: _Paths.profil,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
    ),
    GetPage(
      name: _Paths.manajemenSdm,
      page: () => const ManajemenSdmView(),
      binding: ManajemenSdmBinding(),
    ),
    GetPage(
      name: _Paths.manajemenSdmDetail,
      page: () => const ManajemenSdmDetailView(),
    ),
    GetPage(
      name: _Paths.psb,
      page: () => const PsbView(),
      binding: PsbBinding(),
    ),
    GetPage(
      name: _Paths.psbForm,
      page: () => const PsbFormView(),
      binding: PsbBinding(),
    ),
    GetPage(
      name: _Paths.psbCekStatus,
      page: () => const PsbCekStatusView(),
      binding: PsbBinding(),
    ),
    GetPage(
      name: _Paths.pondok,
      page: () => const PondokView(),
      binding: PondokBinding(),
    ),
    GetPage(
      name: _Paths.administrasi,
      page: () => const AdministrasiView(),
      binding: AdministrasiBinding(),
    ),
    GetPage(
      name: _Paths.monitoring,
      page: () => const MonitoringView(),
      binding: MonitoringBinding(),
    ),
    GetPage(
      name: _Paths.akademikPondok,
      page: () => const AkademikPondokView(),
      binding: AkademikPondokBinding(),
    ),
    GetPage(
      name: _Paths.teacherArea,
      page: () => const TeacherAreaView(),
      binding: TeacherAreaBinding(),
    ),
    GetPage(
      name: _Paths.beritaDetail,
      page: () => const BeritaDetailView(),
    ),
    GetPage(
      name: _Paths.jadwalPelajaran,
      page: () => const JadwalPelajaranView(),
      binding: JadwalPelajaranBinding(),
    ),
    GetPage(
      name: _Paths.claimChild,
      page: () => const ClaimChildView(),
      binding: ClaimChildBinding(),
    ),
  ];
}
