class NoteModel {
  final int? id;
  final String title;
  final String content;
  final String? lat;
  final String? long;
  final String? address;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    this.lat,
    this.long,
    this.address
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      lat: json['lat'],
      long: json['long'],
      address: json['address'],
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
    };
  }
}
