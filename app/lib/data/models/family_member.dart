// lib/data/models/family_member.dart
import 'package:flutter/foundation.dart';

class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final String access;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.access,
  });

  factory FamilyMember.fromDoc(String id, Map<String, dynamic>? map) {
    final data = map ?? <String, dynamic>{};
    return FamilyMember(
      id: id,
      name: (data['name'] as String?) ?? '',
      relation: (data['relation'] as String?) ?? '',
      access: (data['access'] as String?) ?? 'View Only',
    );
  }

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      relation: (map['relation'] as String?) ?? '',
      access: (map['access'] as String?) ?? 'View Only',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'relation': relation,
      'access': access,
    };
  }

  @override
  String toString() {
    return 'FamilyMember(id: $id, name: $name, relation: $relation, access: $access)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FamilyMember &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              relation == other.relation &&
              access == other.access;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ relation.hashCode ^ access.hashCode;
}
