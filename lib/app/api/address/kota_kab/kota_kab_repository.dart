import 'package:epesantren_mob/app/api/address/kota_kab/kota_kab_api.dart';
import 'package:epesantren_mob/app/api/address/provinsi/provinsi_api.dart';
import 'package:epesantren_mob/app/api/address/provinsi/provinsi_model.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';

class KotaKabRepository {
  KotaKabRepository(this.api);

  final KotaKabApi api;
  // final PrefService _authService = Get.find<PrefService>();
  Future<List<ProvinsModel>> districtResponse(String provinceId) async {
    final result = await ApiHelper().getDataNoHeader(
      uri: api.districtList(provinceId),
      builder: (response) {
        final map = response['data'];

        if (map is Map<String, dynamic>) {
          return map.entries.map((e) => ProvinsModel.fromMap(e)).toList();
        }

        return <ProvinsModel>[];
      },
    );

    return result;
  }
}
