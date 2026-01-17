import 'package:epesantren_mob/app/helpers/api_helpers.dart';

class KecamatanApi {
  Uri kecamatanList(String kabId) {
    // endpoint path matches the manual URI used elsewhere: /auth/sign-in
    return ApiHelper.buildUri(
      endpoint: "citizen/subdistrict",
      params: {
        "district_id": kabId,
      },
    );
  }
}
