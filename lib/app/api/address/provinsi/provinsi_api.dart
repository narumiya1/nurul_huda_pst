import 'package:epesantren_mob/app/helpers/api_helpers.dart';

class ProvinsiApi {
  Uri provinsiList() {
    // endpoint path matches the manual URI used elsewhere: /auth/sign-in
    return ApiHelper.buildUri(endpoint: "citizen/province");
  }
}
