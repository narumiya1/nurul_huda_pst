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
