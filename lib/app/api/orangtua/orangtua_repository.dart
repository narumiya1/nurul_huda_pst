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

  Future<dynamic> getChildSummary(int santriId, {String? tipe}) async {
    try {
      final response = await _orangtuaApi.getChildSummary(santriId, tipe: tipe);
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getChildProfile(int santriId, {String? tipe}) async {
    try {
      final response = await _orangtuaApi.getChildProfile(santriId, tipe: tipe);
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getChildSchedule(int santriId, {String? tipe}) async {
    try {
      final response =
          await _orangtuaApi.getChildSchedule(santriId, tipe: tipe);
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getChildScores(int santriId, {String? tipe}) async {
    try {
      final response = await _orangtuaApi.getChildScores(santriId, tipe: tipe);
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getChildBills(int santriId, {String? tipe}) async {
    try {
      final response = await _orangtuaApi.getChildBills(santriId, tipe: tipe);
      if (response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getChildAbsensi(int childId, {String? tipe}) async {
    try {
      final response = await _orangtuaApi.getChildAbsensi(childId, tipe: tipe);
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getChildPerizinan(int santriId, {String? tipe}) async {
    try {
      final response =
          await _orangtuaApi.getChildPerizinan(santriId, tipe: tipe);
      if (response['status'] == true) {
        return response['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
