import 'package:epesantren_mob/app/api/orangtua/orangtua_api.dart';

class OrangtuaRepository {
  final OrangtuaApi _orangtuaApi;

  OrangtuaRepository(this._orangtuaApi);

  Future<List<dynamic>> getMyChildren() async {
    try {
      final response = await _orangtuaApi.getMyChildren();
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getChildSummary(int santriId) async {
    try {
      final response = await _orangtuaApi.getChildSummary(santriId);
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getChildProfile(int santriId) async {
    try {
      final response = await _orangtuaApi.getChildProfile(santriId);
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getChildSchedule(int santriId) async {
    try {
      final response = await _orangtuaApi.getChildSchedule(santriId);
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getChildScores(int santriId) async {
    try {
      final response = await _orangtuaApi.getChildScores(santriId);
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getChildBills(int santriId) async {
    try {
      final response = await _orangtuaApi.getChildBills(santriId);
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
