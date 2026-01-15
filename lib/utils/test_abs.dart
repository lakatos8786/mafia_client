void main() {
  int minInt = -9223372036854775808;
  print('minInt: $minInt');
  print('minInt.abs(): ${minInt.abs()}');
  print('minInt.abs() % 10: ${minInt.abs() % 10}');

  try {
    List<int> list = [1, 2, 3];
    print('list[minInt.abs() % 3]: ${list[minInt.abs() % 3]}');
  } catch (e) {
    print('Caught error: $e');
  }
}
