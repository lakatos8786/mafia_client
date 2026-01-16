import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/noir_design.dart';

class GameLogView extends StatelessWidget {
  final List<Map<String, dynamic>> gameLog;
  final VoidCallback onClose;

  const GameLogView({super.key, required this.gameLog, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.9),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onClose,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '게임 로그',
                      style: GoogleFonts.gowunDodum(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '총 ${gameLog.length}개',
                    style: GoogleFonts.gowunDodum(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Log list
            Expanded(
              child: gameLog.isEmpty
                  ? Center(
                      child: Text(
                        '게임 로그가 없습니다.',
                        style: GoogleFonts.gowunDodum(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: gameLog.length,
                      itemBuilder: (context, index) {
                        final entry = gameLog[index];
                        return _buildLogEntry(entry, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogEntry(Map<String, dynamic> entry, int index) {
    final type = entry['type'] as String? ?? 'unknown';
    final timestamp = entry['timestamp'] as String?;
    final data = entry['data'] as Map<String, dynamic>? ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getTypeColor(type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getTypeColor(type).withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getTypeColor(type).withValues(alpha: 0.2),
            ),
            child: Icon(
              _getTypeIcon(type),
              size: 16,
              color: _getTypeColor(type),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getTypeLabel(type),
                      style: GoogleFonts.gowunDodum(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(type),
                      ),
                    ),
                    if (timestamp != null) ...[
                      const Spacer(),
                      Text(
                        _formatTimestamp(timestamp),
                        style: GoogleFonts.gowunDodum(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatLogMessage(type, data),
                  style: GoogleFonts.gowunDodum(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'system':
        return NoirColors.textPrimary;
      case 'chat':
        return NoirColors.textSecondary;
      case 'vote':
        return NoirColors.crimson;
      case 'kill':
        return NoirColors.crimson;
      case 'heal':
        return NoirColors.textPrimary;
      case 'investigate':
        return NoirColors.textSecondary;
      case 'phase':
        return NoirColors.textPrimary;
      default:
        return Colors.white;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'system':
        return Icons.info;
      case 'chat':
        return Icons.chat_bubble;
      case 'vote':
        return Icons.how_to_vote;
      case 'kill':
        return Icons.theater_comedy; // Mask icon - represents mafia
      case 'heal':
        return Icons.medical_services;
      case 'investigate':
        return Icons.search;
      case 'phase':
        return Icons.access_time;
      default:
        return Icons.circle;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'system':
        return '시스템';
      case 'chat':
        return '채팅';
      case 'vote':
        return '투표';
      case 'kill':
        return '마피아';
      case 'heal':
        return '치료';
      case 'investigate':
        return '조사';
      case 'phase':
        return '페이즈';
      default:
        return type;
    }
  }

  String _formatLogMessage(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'system':
        return data['message'] as String? ?? '';
      case 'chat':
        final sender = data['sender'] as String? ?? '???';
        final message = data['message'] as String? ?? '';
        return '$sender: $message';
      default:
        return data.toString();
    }
  }

  String _formatTimestamp(String isoTimestamp) {
    try {
      final dt = DateTime.parse(isoTimestamp);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
