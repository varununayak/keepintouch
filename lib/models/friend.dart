enum ClosenessTier {
  close,
  medium,
  distant,
}

class Friend {
  final String id;
  final String name;
  final ClosenessTier closenessTier;
  final String? notes;
  final DateTime? lastContacted;

  Friend({
    required this.id,
    required this.name,
    required this.closenessTier,
    this.notes,
    this.lastContacted,
  });
} 