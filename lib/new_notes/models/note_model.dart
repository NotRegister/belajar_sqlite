class NoteModel {
  final int? id;
  final String title;
  final String content;
  final String? lat;
  final String? long;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    this.lat,
    this.long,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      lat: json['lat'],
      long: json['long'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'lat': lat,
      'long': long,
    };
  }
}
