import 'package:epesantren_mob/app/api/santri/santri_api.dart';

class SantriRepository {
  final SantriApi _santriApi;

  SantriRepository(this._santriApi);

  Future<dynamic> getMyBills() async {
    try {
      final response = await _santriApi.getMyBills();
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMyPayments() async {
    try {
      final response = await _santriApi.getMyPayments();
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMyProfile() async {
    try {
      final response = await _santriApi.getMyProfile();
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMySchedule() async {
    try {
      final response = await _santriApi.getMySchedule();
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMyActivities() async {
    try {
      final response = await _santriApi.getMyActivities();
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMyTahfidz() async {
    try {
      final response = await _santriApi.getMyTahfidz();
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMyPerizinan() async {
    try {
      final response = await _santriApi.getMyPerizinan();
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> requestPerizinan(Map<String, dynamic> data) async {
    try {
      final response = await _santriApi.requestPerizinan(data);
      return response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }
}
