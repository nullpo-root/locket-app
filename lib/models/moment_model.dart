class Moment {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String imagePath;
  final String caption;
  final DateTime createdAt;
  final Map<String, int> reactions;
  final List<String> recipients; // ['all'] or list of friendIds

  Moment({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.imagePath,
    this.caption = '',
    required this.createdAt,
    this.reactions = const {},
    this.recipients = const ['all'],
  });

  Moment copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? imagePath,
    String? caption,
    DateTime? createdAt,
    Map<String, int>? reactions,
    List<String>? recipients,
  }) {
    return Moment(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      imagePath: imagePath ?? this.imagePath,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      reactions: reactions ?? this.reactions,
      recipients: recipients ?? this.recipients,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'senderAvatar': senderAvatar,
    'imagePath': imagePath,
    'caption': caption,
    'createdAt': createdAt.toIso8601String(),
    'reactions': reactions,
    'recipients': recipients,
  };

  factory Moment.fromJson(Map<String, dynamic> json) => Moment(
    id: json['id'] as String,
    senderId: json['senderId'] as String,
    senderName: json['senderName'] as String,
    senderAvatar: json['senderAvatar'] as String? ?? '',
    imagePath: json['imagePath'] as String,
    caption: json['caption'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
    reactions: (json['reactions'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as int),
        ) ??
        {},
    recipients: (json['recipients'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        ['all'],
  );
}
