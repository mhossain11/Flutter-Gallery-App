class GalleryModel {
  final String id, name;

  GalleryModel({
    required this.id,
    required this.name,

  });

  factory GalleryModel.fromJson(String id, Map<String, dynamic> json) {
    return GalleryModel(
      id: id,
      name: json['name'],

    );
  }
}