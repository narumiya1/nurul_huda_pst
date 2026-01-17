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
        final List<dynamic> newsJson = data['data']['data'];
        return newsJson.map((json) => BeritaModel.fromJson(json)).toList();
      },
      header: ApiHelper.header(),
    );
  }
}
