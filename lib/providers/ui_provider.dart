import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI 관련 상태를 관리하는 프로바이더
/// 현재 생존자만 필터링해서 볼지 여부를 저장합니다.
final showSurvivorsOnlyProvider = StateProvider<bool>((ref) => false);
