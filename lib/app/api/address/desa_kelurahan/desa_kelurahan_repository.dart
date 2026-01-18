import 'package:epesantren_mob/app/api/address/desa_kelurahan/desa_kelurahan_api.dart';
import 'package:epesantren_mob/app/api/address/provinsi/provinsi_model.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';

class DesaKelurahanRepository {
  DesaKelurahanRepository(this.api);

  final DesaKelurahanApi api;
  // final PrefService _authService = Get.find<PrefService>();
  Future<List<ProvinsModel>> desaKelurahanResponse(String kecamatanId) async {
    final result = await ApiHelper().getDataNoHeader(
      uri: api.desaKelurahanList(kecamatanId),
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
