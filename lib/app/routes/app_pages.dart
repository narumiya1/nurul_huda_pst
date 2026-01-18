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
import '../modules/pondok/bindings/pondok_binding.dart';
import '../modules/pondok/views/pondok_view.dart';
import '../modules/administrasi/bindings/administrasi_binding.dart';
import '../modules/administrasi/views/administrasi_view.dart';
import '../modules/monitoring/bindings/monitoring_binding.dart';
import '../modules/monitoring/views/monitoring_view.dart';
import '../modules/akademik_pondok/bindings/akademik_pondok_binding.dart';
import '../modules/akademik_pondok/views/akademik_pondok_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.WELCOME;

  static final routes = [
    GetPage(
      name: _Paths.WELCOME,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.FEATURE_PLACEHOLDER,
      page: () => const FeaturePlaceholderView(),
    ),
    GetPage(
      name: _Paths.KEUANGAN,
      page: () => const KeuanganView(),
      binding: KeuanganBinding(),
    ),
    GetPage(
      name: _Paths.ABSENSI,
      page: () => const AbsensiView(),
      binding: AbsensiBinding(),
    ),
    GetPage(
      name: _Paths.TAHFIDZ,
      page: () => const TahfidzView(),
      binding: TahfidzBinding(),
    ),
    GetPage(
      name: _Paths.AKTIVITAS,
      page: () => const AktivitasView(),
      binding: AktivitasBinding(),
    ),
    GetPage(
      name: _Paths.PROFIL,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
    ),
    GetPage(
      name: _Paths.MANAJEMEN_SDM,
      page: () => const ManajemenSdmView(),
      binding: ManajemenSdmBinding(),
    ),
    GetPage(
      name: _Paths.MANAJEMEN_SDM_DETAIL,
      page: () => const ManajemenSdmDetailView(),
    ),
    GetPage(
      name: _Paths.PSB,
      page: () => const PsbView(),
      binding: PsbBinding(),
    ),
    GetPage(
      name: _Paths.PONDOK,
      page: () => const PondokView(),
      binding: PondokBinding(),
    ),
    GetPage(
      name: _Paths.ADMINISTRASI,
      page: () => const AdministrasiView(),
      binding: AdministrasiBinding(),
    ),
    GetPage(
      name: _Paths.MONITORING,
      page: () => const MonitoringView(),
      binding: MonitoringBinding(),
    ),
    GetPage(
      name: _Paths.AKADEMIK_PONDOK,
      page: () => const AkademikPondokView(),
      binding: AkademikPondokBinding(),
    ),
  ];
}
