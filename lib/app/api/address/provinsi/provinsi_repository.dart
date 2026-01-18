import 'package:epesantren_mob/app/api/address/provinsi/provinsi_api.dart';
import 'package:epesantren_mob/app/api/address/provinsi/provinsi_model.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';

class ProvinsiRepository {
  ProvinsiRepository(this.api);

  final ProvinsiApi api;
  // final PrefService _authService = Get.find<PrefService>();
  Future<List<ProvinsModel>> provinsiResponse() async {
    try {
      final result = await ApiHelper().getDataNoHeader(
        uri: api.provinsiList(),
        builder: (response) async {
          /// 🔥 ambil bagian "data" saja
          final map = response['data'];

          if (map is Map<String, dynamic>) {
            return map.entries.map((e) => ProvinsModel.fromMap(e)).toList();
          }

          return <ProvinsModel>[];
        },
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
