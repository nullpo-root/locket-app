import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/moment_model.dart';
import '../models/friend_model.dart';
import 'widget_sync_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _keyMoments = 'locket_moments_list';
  static const String _keyFriends = 'locket_friends_list';

  final List<Moment> _moments = [];
  final List<Friend> _friends = [];
  bool _initialized = false;

  List<Moment> get moments => List.unmodifiable(_moments);
  List<Friend> get friends => List.unmodifiable(_friends);

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    // Load Friends
    final friendsJson = prefs.getString(_keyFriends);
    if (friendsJson != null) {
      final List decoded = jsonDecode(friendsJson);
      _friends.clear();
      _friends.addAll(decoded.map((e) => Friend.fromJson(e)).toList());
    } else {
      // Seed default friends for initial experience
      _friends.addAll([
        Friend(id: 'friend_1', name: 'Linh Dan', avatarUrl: '', initials: 'LD', isOnline: true),
        Friend(id: 'friend_2', name: 'Minh Quang', avatarUrl: '', initials: 'MQ', isOnline: true),
        Friend(id: 'friend_3', name: 'Bảo Ngọc', avatarUrl: '', initials: 'BN', isOnline: false),
        Friend(id: 'friend_4', name: 'Hoàng Long', avatarUrl: '', initials: 'HL', isOnline: false),
      ]);
      await _saveFriendsToDisk();
    }

    // Load Moments
    final momentsJson = prefs.getString(_keyMoments);
    if (momentsJson != null) {
      final List decoded = jsonDecode(momentsJson);
      _moments.clear();
      _moments.addAll(decoded.map((e) => Moment.fromJson(e)).toList());
    }

    _initialized = true;
  }

  Future<void> addMoment({
    required String imagePath,
    required String caption,
    required List<String> recipients,
  }) async {
    final newMoment = Moment(
      id: const Uuid().v4(),
      senderId: 'current_user',
      senderName: 'You',
      senderAvatar: '',
      imagePath: imagePath,
      caption: caption,
      createdAt: DateTime.now(),
      reactions: {},
      recipients: recipients,
    );

    _moments.insert(0, newMoment);
    await _saveMomentsToDisk();

    // Sync directly to the Home Screen Widget
    await WidgetSyncService().syncMomentToWidget(newMoment);
  }

  Future<void> addReaction(String momentId, String emoji) async {
    final index = _moments.indexWhere((m) => m.id == momentId);
    if (index != -1) {
      final currentMoment = _moments[index];
      final currentReactions = Map<String, int>.from(currentMoment.reactions);
      currentReactions[emoji] = (currentReactions[emoji] ?? 0) + 1;

      _moments[index] = currentMoment.copyWith(reactions: currentReactions);
      await _saveMomentsToDisk();
    }
  }

  Future<void> addFriend(String name) async {
    final words = name.trim().split(' ');
    String initials = 'F';
    if (words.isNotEmpty) {
      initials = words.map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(2).join();
    }
    final newFriend = Friend(
      id: const Uuid().v4(),
      name: name,
      avatarUrl: '',
      initials: initials,
      isOnline: true,
    );
    _friends.add(newFriend);
    await _saveFriendsToDisk();
  }

  Future<void> _saveMomentsToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_moments.map((m) => m.toJson()).toList());
    await prefs.setString(_keyMoments, jsonStr);
  }

  Future<void> _saveFriendsToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_friends.map((f) => f.toJson()).toList());
    await prefs.setString(_keyFriends, jsonStr);
  }
}
