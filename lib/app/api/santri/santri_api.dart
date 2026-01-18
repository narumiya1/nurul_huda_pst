import 'package:epesantren_mob/app/helpers/api_helpers.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';

class SantriApi {
  final ApiHelper _apiHelper = ApiHelper();

  Map<String, String> _getAuthHeader() {
    final token = LocalStorage.getToken();
    return ApiHelper.tokenHeader(token ?? '');
  }

  Future<dynamic> getMyBills() async {
    final uri = ApiHelper.buildUri(endpoint: 'santri/my-bills');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getMyPayments() async {
    final uri = ApiHelper.buildUri(endpoint: 'santri/my-payments');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getMyProfile() async {
    final uri = ApiHelper.buildUri(endpoint: 'santri/my-profile');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getMySchedule() async {
    final uri = ApiHelper.buildUri(endpoint: 'santri/my-schedule');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getMyActivities() async {
    final uri = ApiHelper.buildUri(endpoint: 'santri/my-activities');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getMyTahfidz() async {
    final uri = ApiHelper.buildUri(endpoint: 'santri/my-tahfidz');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> getMyPerizinan() async {
    final uri = ApiHelper.buildUri(endpoint: 'santri/my-perizinan');
    return await _apiHelper.getData(
      uri: uri,
      builder: (data) => data,
      header: _getAuthHeader(),
    );
  }

  Future<dynamic> requestPerizinan(Map<String, dynamic> data) async {
    final uri = ApiHelper.buildUri(endpoint: 'santri/my-perizinan');
    return await _apiHelper.postData(
      uri: uri,
      builder: (data) => data,
      jsonBody: data,
      header: _getAuthHeader(),
    );
  }
}
