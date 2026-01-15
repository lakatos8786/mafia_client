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
  ];

  for (var name in names) {
    print('$name: ${name.hashCode % 10}');
  }
}
