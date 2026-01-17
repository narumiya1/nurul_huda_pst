import 'package:epesantren_mob/app/helpers/api_helpers.dart';

class KotaKabApi {
  Uri districtList(String provinceId) {
    // endpoint path matches the manual URI used elsewhere: /auth/sign-in
    return ApiHelper.buildUri(
      endpoint: "citizen/district",
      params: {
        "province_id": provinceId,
      },
    );
  }
}
