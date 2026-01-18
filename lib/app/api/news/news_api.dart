import 'package:epesantren_mob/app/api/news/news_model.dart';
import 'package:epesantren_mob/app/helpers/api_helpers.dart';

class NewsApi {
  final ApiHelper _apiHelper = ApiHelper();

  Future<List<BeritaModel>> getNews() async {
    final uri = ApiHelper.buildUri(endpoint: 'news');

    return await _apiHelper.getData(
      uri: uri,
      builder: (data) {
        // Response format: {status, data: { data: [...], current_page, ... }, message, code}
        // Laravel's pagination usually wraps items in its own 'data' property
        try {
          if (data == null) return <BeritaModel>[];

          final responseData = data['data'];
          if (responseData == null) return <BeritaModel>[];

          // Handle both paginated and non-paginated responses
          final List<dynamic> newsJson;
          if (responseData is List) {
            newsJson = responseData;
          } else if (responseData is Map && responseData['data'] != null) {
            newsJson = responseData['data'];
          } else {
            return <BeritaModel>[];
          }

          return newsJson.map((json) => BeritaModel.fromJson(json)).toList();
        } catch (e) {
          print('News parsing error: $e');
          return <BeritaModel>[];
        }
      },
      header: ApiHelper.header(),
    );
  }
}
