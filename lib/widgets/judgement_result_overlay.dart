import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_colors.dart';

class JudgementResultOverlay extends StatefulWidget {
  final Map<String, dynamic> resultData;

  const JudgementResultOverlay({super.key, required this.resultData});

  @override
  State<JudgementResultOverlay> createState() => _JudgementResultOverlayState();
}

class _JudgementResultOverlayState extends State<JudgementResultOverlay> {
  int stage = 1;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  void _startSequence() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          if (stage < 3) {
            stage++;
          } else {
            _timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.resultData['result']?.toString() == 'executed';
    final yesCount = widget.resultData['yesCount'] ?? 0;
    final noCount = widget.resultData['noCount'] ?? 0;
    final nickname = widget.resultData['nickname'] ?? '?';

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (stage == 1)
              ZoomIn(
                duration: const Duration(milliseconds: 400),
                child: Flash(
                  infinite: true,
                  duration: const Duration(milliseconds: 800),
                  child: const Text(
                    '투표 종료!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      shadows: [Shadow(color: Colors.white, blurRadius: 20)],
                    ),
                  ),
                ),
              ),
            if (stage >= 2) ...[
              FadeIn(
                duration: const Duration(milliseconds: 300),
                child: _buildVoteGraph(yesCount, noCount),
              ),
              const SizedBox(height: 50),
            ],
            if (stage == 3)
              ElasticIn(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  children: [
                    Text(
                      nickname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      result ? '처형 확정' : '방면',
                      style: TextStyle(
                        color: result ? AppColors.mafiaRed : Colors.greenAccent,
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: result ? Colors.red : Colors.green,
                            blurRadius: 30,
                          ),
                          Shadow(
                            color: result ? Colors.red : Colors.green,
                            blurRadius: 60,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteGraph(int yes, int no) {
    final total = (yes + no) > 0 ? (yes + no) : 1;
    final yesRatio = yes / total;
    final noRatio = no / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '찬성 $yes',
                style: const TextStyle(
                  color: AppColors.mafiaRed,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '반대 $no',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Expanded(
                  flex: (yesRatio * 100).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.mafiaRed.withValues(alpha: 0.5),
                          AppColors.mafiaRed,
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: (noRatio * 100).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.greenAccent,
                          Colors.greenAccent.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
