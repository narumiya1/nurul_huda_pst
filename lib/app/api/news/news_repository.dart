import 'package:epesantren_mob/app/api/news/news_api.dart';
import 'package:epesantren_mob/app/api/news/news_model.dart';

class NewsRepository {
  final NewsApi _newsApi;

  NewsRepository(this._newsApi);

  Future<List<BeritaModel>> getAllNews() async {
    try {
      return await _newsApi.getNews();
    } catch (e) {
      rethrow;
    }
  }
}
