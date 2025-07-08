import 'package:hive/hive.dart';

part 'friend.g.dart';

@HiveType(typeId: 0)
enum ClosenessTier {
  @HiveField(0)
  close,
  @HiveField(1)
  medium,
  @HiveField(2)
  distant,
}

@HiveType(typeId: 1)
class Friend extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final ClosenessTier closenessTier;
  
  @HiveField(3)
  final String? notes;
  
  @HiveField(4)
  final DateTime? lastContacted;

  Friend({
    required this.id,
    required this.name,
    required this.closenessTier,
    this.notes,
    this.lastContacted,
  });

  // Copy method for updating friends
  Friend copyWith({
    String? id,
    String? name,
    ClosenessTier? closenessTier,
    String? notes,
    DateTime? lastContacted,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      closenessTier: closenessTier ?? this.closenessTier,
      notes: notes ?? this.notes,
      lastContacted: lastContacted ?? this.lastContacted,
    );
  }
} 