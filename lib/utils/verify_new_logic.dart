import 'package:flutter/material.dart';

class TestColorUtils {
  static const List<Color> _senderColors = [
    Color(0xFF38BDF8),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFF97316),
    Color(0xFF06B6D4),
    Color(0xFF6366F1),
    Color(0xFFF43F5E),
    Color(0xFF2DD4BF),
    Color(0xFFA855F7),
    Color(0xFFFB7185),
    Color(0xFFE879F9),
    Color(0xFFFACC15),
    Color(0xFF4ADE80),
    Color(0xFF22D3EE),
    Color(0xFF818CF8),
    Color(0xFFC084FC),
    Color(0xFFFB923C),
    Color(0xFFF472B6),
  ];

  static int getHash(String name) {
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = (hash * 31) + name.codeUnitAt(i);
    }
    hash = (hash ^ (hash >> 16)) * 0x45d9f3b;
    hash = (hash ^ (hash >> 16)) * 0x45d9f3b;
    hash = hash ^ (hash >> 16);
    return hash.abs() % _senderColors.length;
  }
}

void main() {
  final names = [
    'Player 1',
    'Player 2',
    'Player 3',
    'Player 4',
    '플레이어 1',
    '플레이어 2',
    '플레이어 3',
    '플레이어 4',
    '테스트1',
    '테스트2',
    '테스트3',
    '테스트4',
    '1',
    '2',
    '3',
    '4',
    'User1',
    'User2',
    'User3',
    'User4',
    '마피아1',
    '마피아2',
    '마피아3',
  ];

  print('--- Nickname Color Index Distribution (New Logic) ---');
  Map<int, int> counts = {};
  for (var name in names) {
    final index = TestColorUtils.getHash(name);
    print('$name: Index $index');
    counts[index] = (counts[index] ?? 0) + 1;
  }

  print('\n--- Collision Summary ---');
  int collisions = 0;
  counts.forEach((index, count) {
    if (count > 1) {
      print('Index $index: $count names');
      collisions += (count - 1);
    }
  });
  print('Total collisions: $collisions in ${names.length} names');
}
