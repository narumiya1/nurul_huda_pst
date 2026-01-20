import 'activity_api.dart';

class ActivityRepository {
  final ActivityApi _api = ActivityApi();

  Future<List<dynamic>> getActivities(String filter) async {
    try {
      return await _api.getActivities(filter);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getActivityDetail(dynamic id) async {
    try {
      return await _api.getActivityDetail(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createActivity(Map<String, dynamic> data) async {
    try {
      return await _api.createActivity(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteActivity(dynamic id) async {
    try {
      return await _api.deleteActivity(id);
    } catch (e) {
      rethrow;
    }
  }
}
