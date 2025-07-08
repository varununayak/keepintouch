import 'package:hive_flutter/hive_flutter.dart';
import '../models/friend.dart';

class DataService {
  static const String _friendsBoxName = 'friends';
  static Box<Friend>? _friendsBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ClosenessTierAdapter());
    Hive.registerAdapter(FriendAdapter());
    
    // Open boxes
    _friendsBox = await Hive.openBox<Friend>(_friendsBoxName);
  }

  // Friends CRUD operations
  static List<Friend> getAllFriends() {
    return _friendsBox?.values.toList() ?? [];
  }

  static Future<void> addFriend(Friend friend) async {
    await _friendsBox?.put(friend.id, friend);
  }

  static Future<void> updateFriend(Friend friend) async {
    await _friendsBox?.put(friend.id, friend);
  }

  static Future<void> deleteFriend(String id) async {
    await _friendsBox?.delete(id);
  }

  static Future<void> clearAllFriends() async {
    await _friendsBox?.clear();
  }

  // Close boxes when app is done
  static Future<void> close() async {
    await _friendsBox?.close();
  }
} 