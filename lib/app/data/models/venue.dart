class Venue {
  int? id;
  String name;
  String type;

  Venue({
    this.id,
    required this.name,
    required this.type,
  });

  Map<String, dynamic> toSembast() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }

  factory Venue.fromSembast(Map<String, dynamic> map) {
    return Venue(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
    );
  }
}
