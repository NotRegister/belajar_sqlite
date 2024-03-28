class NoteModel {
  final int? id;
  final String title;
  final String content;
  final String? lat;
  final String? long;
  final String? address;
  late String? imgPath;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    this.lat,
    this.long,
    this.address,
    this.imgPath,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      lat: json['lat'],
      long: json['long'],
      address: json['address'],
      imgPath: json['imgPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'lat': lat,
      'long': long,
      'address': address,
      'imgPath': imgPath,
    };
  }
}
