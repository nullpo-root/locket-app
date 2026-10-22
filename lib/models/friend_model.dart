class Friend {
  final String id;
  final String name;
  final String avatarUrl;
  final String initials;
  final bool isOnline;

  Friend({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.initials,
    this.isOnline = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
    'initials': initials,
    'isOnline': isOnline,
  };

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
    id: json['id'] as String,
    name: json['name'] as String,
    avatarUrl: json['avatarUrl'] as String? ?? '',
    initials: json['initials'] as String? ?? '??',
    isOnline: json['isOnline'] as bool? ?? false,
  );
}
