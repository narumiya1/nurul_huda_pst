import 'package:epesantren_mob/app/helpers/api_helpers.dart';

class DesaKelurahanApi {
  Uri desaKelurahanList(String kecamatanId) {
    // endpoint path matches the manual URI used elsewhere: /auth/sign-in
    return ApiHelper.buildUri(
      endpoint: "citizen/village",
      params: {
        "subdistrict_id": kecamatanId,
      },
    );
  }
}
