class PlaylistModel {
  final String id;
  final String name;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverImage;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
    this.coverImage,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      songIds: List<String>.from(json['songIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      coverImage: json['coverImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songIds': songIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'coverImage': coverImage,
    };
  }

  PlaylistModel copyWith({
    String? name,
    List<String>? songIds,
    String? coverImage,
  }) {
    return PlaylistModel(
      id: id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      coverImage: coverImage ?? this.coverImage,
    );
  }
}