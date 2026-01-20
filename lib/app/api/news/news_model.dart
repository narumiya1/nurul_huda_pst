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

    // Default to 10.0.2.2 for emulator if not specified,
    // better to use config/ApiHelper if available.
    // Since this is a model, maybe just return what it is and let view handle it.
    // BUT looking at other parts, we prefix it.
    return 'http://10.0.2.2:8000${image!.startsWith('/') ? image! : '/$image'}';
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
