import 'package:epesantren_mob/app/helpers/config.dart';

class BeritaModel {
  final int? id;
  final String? title;
  final String? content;
  final String? category;
  final String? image;
  final String? publishedAt;
  final String? slug;

  BeritaModel({
    this.id,
    this.title,
    this.content,
    this.category,
    this.image,
    this.publishedAt,
    this.slug,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      image: json['image'],
      publishedAt: json['published_at'],
      slug: json['slug'],
    );
  }

  String? get imageUrl {
    if (image == null || image!.isEmpty) return null;
    if (image!.startsWith('http')) return image;

    // Build URL dynamically from ApiConfig
    const scheme = ApiConfig.useHttps ? 'https' : 'http';
    final portSuffix = ApiConfig.port.isNotEmpty ? ':${ApiConfig.port}' : '';
    final path = image!.startsWith('/') ? image! : '/$image';
    return '$scheme://${ApiConfig.baseUrlAddress}$portSuffix$path';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'image': image,
      'published_at': publishedAt,
      'slug': slug,
    };
  }
}
