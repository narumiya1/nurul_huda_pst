import 'package:epesantren_mob/app/api/address/kecamatan/kecamatan_api.dart';
import 'package:epesantren_mob/app/api/address/kota_kab/kota_kab_api.dart';
import 'package:epesantren_mob/app/api/address/provinsi/provinsi_api.dart';
import 'package:epesantren_mob/app/api/address/provinsi/provinsi_model.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';

class KecamatanRepository {
  KecamatanRepository(this.api);

  final KecamatanApi api;
  // final PrefService _authService = Get.find<PrefService>();
  Future<List<ProvinsModel>> kecamatanResponse(String kabId) async {
    final result = await ApiHelper().getDataNoHeader(
      uri: api.kecamatanList(kabId),
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
