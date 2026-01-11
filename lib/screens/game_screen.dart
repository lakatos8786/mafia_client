import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/day_night_background.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_msgController.text.isNotEmpty) {
      Provider.of<GameProvider>(
        context,
        listen: false,
      ).sendMessage(_msgController.text);
      _msgController.clear();
    }
  }

  String _getPhaseInstruction(GameProvider game) {
    final myPlayer = game.players.firstWhere(
      (p) => p.id == game.socket.id,
      orElse: () => Player(id: '', nickname: '', isAlive: false),
    );

    if (!myPlayer.isAlive) {
      return "당신은 사망했습니다. 게임을 관전하세요.";
    }

    if (game.gameState == '낮') {
      return "의심되는 플레이어에게 투표하세요. (과반수 이상 득표 시 처형)";
    } else if (game.gameState == '밤') {
      if (game.myRole == '마피아') {
        return "제거할 대상을 선택하세요.";
      } else if (game.myRole == '의사') {
        return "마피아로부터 보호할 대상을 선택하세요.";
      } else if (game.myRole == '경찰') {
        return "마피아인지 조사할 대상을 선택하세요.";
      } else {
        return "밤이 되었습니다. 아침이 밝을 때까지 기다리세요.";
      }
    } else if (game.gameState == '대기중') {
      return "게임 시작을 기다리고 있습니다.";
    } else {
      return "진행 중...";
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    // Auto-scroll chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Removed title to prevent truncation and layout issues.
        // Info is now moved to the top of the body.
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: DayNightBackground(
        phase: game.gameState,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: Column(
                children: [
                  // --- Custom Header Area ---
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    color: Colors
                        .black26, // Semi-transparent background for readability
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          '${game.gameState} - ${game.dayCount}일차',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (game.roleCounts.isNotEmpty)
                          Text(
                            game.roleCounts.entries
                                .map((e) => '${e.key}: ${e.value}')
                                .join(' | '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        SizedBox(height: 4),
                        Text(
                          '나의 직업: ${game.myRole ?? "알 수 없음"}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.yellowAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _getPhaseInstruction(game),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.cyanAccent,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Skip Vote Row
                  if (game.gameState == '낮' &&
                      game.players.any(
                        (p) => p.id == game.socket.id && p.isAlive,
                      ))
                    Builder(
                      builder: (context) {
                        // Logic to find who voted 'skip'
                        final skipVoters = game.voters.entries
                            .where((entry) => entry.value == 'skip')
                            .map((entry) {
                              final voter = game.players.firstWhere(
                                (p) => p.id == entry.key,
                                orElse: () => Player(
                                  id: 'unknown',
                                  nickname: '?',
                                  isAlive: true,
                                ),
                              );
                              return voter.nickname;
                            })
                            .toList();

                        final myId = game.socket.id;
                        final iVotedSkip = game.voters[myId] == 'skip';

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (game.votes['skip'] != null &&
                                  game.votes['skip']! > 0)
                                Flexible(
                                  child: Text(
                                    '건너뛰기: ${game.votes['skip']}표 (${skipVoters.join(", ")})  ',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: iVotedSkip
                                      ? Colors.blueAccent
                                      : Colors.grey[800],
                                  foregroundColor: Colors.white,
                                  side: iVotedSkip
                                      ? BorderSide(
                                          color: Colors.white,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                onPressed: () {
                                  game.vote('skip');
                                },
                                child: Text('투표 건너뛰기'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  if (game.gameState == '밤' &&
                      game.myRole == '마피아' &&
                      game.players.any(
                        (p) => p.id == game.socket.id && p.isAlive,
                      ))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[900],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              game.nightAction('kill', 'skip');
                            },
                            child: Text('살인 건너뛰기'),
                          ),
                        ],
                      ),
                    ),

                  // Game Area
                  Expanded(
                    flex: 3,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final playerCount = game.players.length;
                        if (playerCount == 0) return SizedBox.shrink();

                        // --- Responsive Grid Logic ---
                        final availableWidth =
                            constraints.maxWidth - 20; // 10 padding each side
                        final availableHeight = constraints.maxHeight - 20;
                        final spacing = 4.0;

                        // Define minimum comfortable touch target size
                        const double minItemHeight = 110.0;
                        const double minItemWidth = 80.0;

                        // 1. Attempt "Fit to Screen" (Original Logic)
                        int cols = 4;
                        if (playerCount <= 4)
                          cols = 2;
                        else if (playerCount <= 9)
                          cols = 3;
                        else
                          cols = 4;
                        if (playerCount > 12) cols = 5;

                        final fitRows = (playerCount / cols).ceil();
                        final totalVerticalSpacing = (fitRows - 1) * spacing;
                        final fitItemHeight =
                            (availableHeight - totalVerticalSpacing) / fitRows;

                        // 2. Decide: Fit vs Scroll
                        // If fitting makes cards too small, switch to Scroll Mode
                        bool useScroll = fitItemHeight < minItemHeight;

                        ScrollPhysics scrollPhysics;
                        double ratio;

                        if (useScroll) {
                          // Scroll Mode
                          scrollPhysics = AlwaysScrollableScrollPhysics();
                          // Recalculate columns to ensure minimum width
                          cols = (availableWidth / minItemWidth).floor().clamp(
                            3,
                            8,
                          );
                          // Fix aspect ratio for consistent card shape
                          ratio = 0.75; // e.g. 80w / 106h
                        } else {
                          // Fit Mode
                          scrollPhysics = NeverScrollableScrollPhysics();
                          final totalHorizontalSpacing = (cols - 1) * spacing;
                          final itemWidth =
                              (availableWidth - totalHorizontalSpacing) / cols;
                          ratio = itemWidth / fitItemHeight;
                        }

                        return GridView.builder(
                          padding: EdgeInsets.all(10),
                          physics: scrollPhysics,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                childAspectRatio: ratio,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                              ),
                          itemCount: playerCount,
                          itemBuilder: (context, index) {
                            final player = game.players[index];
                            final isMe = player.id == game.socket.id;
                            final voteCount = game.votes[player.id] ?? 0;

                            final selectionTargetForRole = game
                                .nightSelections
                                .entries
                                .where((entry) => entry.value == player.id)
                                .map((entry) => entry.key)
                                .toList();

                            Color? cardColor = player.isAlive
                                ? Colors.black54
                                : Colors.grey[900]; // Dark grey for dead

                            // Highlight card if it's a night selection target
                            if (game.gameState == '밤' &&
                                selectionTargetForRole.isNotEmpty) {
                              if (selectionTargetForRole.contains('마피아')) {
                                cardColor = Colors.red.withOpacity(0.4);
                              } else if (selectionTargetForRole.contains(
                                '의사',
                              )) {
                                cardColor = Colors.green.withOpacity(0.4);
                              } else if (selectionTargetForRole.contains(
                                '경찰',
                              )) {
                                cardColor = Colors.blue.withOpacity(0.4);
                              }
                            }

                            return Card(
                              color: cardColor,
                              shape:
                                  (game.gameState == '밤' &&
                                      selectionTargetForRole.isNotEmpty)
                                  ? RoundedRectangleBorder(
                                      side: BorderSide(
                                        color:
                                            selectionTargetForRole.contains(
                                              '마피아',
                                            )
                                            ? Colors.redAccent
                                            : (selectionTargetForRole.contains(
                                                    '의사',
                                                  )
                                                  ? Colors.greenAccent
                                                  : Colors.blueAccent),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    )
                                  : null,
                              child: InkWell(
                                onTap: () {
                                  if (!player.isAlive) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('이미 사망한 플레이어입니다.'),
                                        duration: Duration(milliseconds: 1000),
                                      ),
                                    );
                                    return;
                                  }
                                  // Handle Tap Actions
                                  if (game.gameState == '낮') {
                                    game.vote(player.id);
                                  } else if (game.gameState == '밤') {
                                    String? action;
                                    if (game.myRole == '마피아') action = 'kill';
                                    if (game.myRole == '의사') action = 'heal';
                                    if (game.myRole == '경찰')
                                      action = 'investigate';

                                    if (action != null) {
                                      String actionName = action;
                                      if (action == 'kill') actionName = '처단';
                                      if (action == 'heal') actionName = '치료';
                                      if (action == 'investigate')
                                        actionName = '조사';

                                      game.nightAction(action, player.id);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '$actionName 대상을 선택했습니다.',
                                          ),
                                          duration: Duration(
                                            milliseconds: 1000,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Stack(
                                  children: [
                                    // Main Content
                                    Opacity(
                                      opacity: player.isAlive ? 1.0 : 0.4,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            player.isAlive
                                                ? Icons.person
                                                : Icons
                                                      .sentiment_dissatisfied, // Changed icon for dead
                                            size: 40,
                                            color: player.isAlive
                                                ? Colors.white
                                                : Colors
                                                      .grey, // Grey for dead icon
                                          ),
                                          SizedBox(height: 5),
                                          Center(
                                            child: Text(
                                              player.nickname +
                                                  (isMe ? ' (나)' : ''),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    12, // Reduced font size to fit
                                              ),
                                            ),
                                          ),
                                          if (game.gameState == '낮' &&
                                              player.isAlive)
                                            Text(
                                              '득표수: $voteCount',
                                              style: TextStyle(
                                                color: Colors.orange,
                                              ),
                                            ),
                                          if (game.gameState == '낮' &&
                                              player.isAlive)
                                            Builder(
                                              builder: (context) {
                                                // Find players who voted for this player
                                                final votersForThis = game
                                                    .voters
                                                    .entries
                                                    .where(
                                                      (entry) =>
                                                          entry.value ==
                                                          player.id,
                                                    )
                                                    .map((entry) {
                                                      final voterId = entry.key;
                                                      final voter = game.players
                                                          .firstWhere(
                                                            (p) =>
                                                                p.id == voterId,
                                                            orElse: () =>
                                                                Player(
                                                                  id: 'unknown',
                                                                  nickname: '?',
                                                                  isAlive: true,
                                                                ),
                                                          );
                                                      return voter.nickname;
                                                    })
                                                    .toList();

                                                if (votersForThis.isNotEmpty) {
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                      top: 4,
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black45,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '지목: ${votersForThis.join(", ")}',
                                                      style: TextStyle(
                                                        color: Colors.redAccent,
                                                        fontSize: 10,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  );
                                                } else {
                                                  return SizedBox.shrink();
                                                }
                                              },
                                            ),
                                          if (game.gameState == '밤' &&
                                              selectionTargetForRole.isNotEmpty)
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                selectionTargetForRole.join(
                                                  ', ',
                                                ),
                                                style: TextStyle(
                                                  color: Colors.yellowAccent,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Dead Overlay
                                    if (!player.isAlive)
                                      Center(
                                        child: Transform.rotate(
                                          angle: -0.5,
                                          child: Text(
                                            'DEAD',
                                            style: TextStyle(
                                              fontSize: 32,
                                              color: Colors.red.withOpacity(
                                                0.8,
                                              ),
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 10.0,
                                                  color: Colors.black,
                                                  offset: Offset(2.0, 2.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Divider(color: Colors.white24),
                  // Chat Area
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.black12,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: game.messages.length,
                        itemBuilder: (context, index) {
                          final msg = game.messages[index];
                          final sender = msg['sender'];
                          final text = msg['message'];
                          final type =
                              msg['type']; // general, dead, mafia, system

                          Color textColor = Colors.white70;
                          String prefix = '';

                          if (type == 'dead') {
                            textColor = Colors.grey;
                            prefix = '[사망] ';
                          } else if (type == 'mafia') {
                            textColor = Colors.redAccent;
                            prefix = '[마피아] ';
                          } else if (msg['isSystem'] == true) {
                            textColor = Colors.yellowAccent;
                            prefix = '[시스템] ';
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: textColor),
                                children: [
                                  TextSpan(
                                    text: prefix,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '$sender: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: text),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '메시지를 입력하세요...',
                              hintStyle: TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.black26,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.blueAccent),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (game.gameState == '결과')
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    if (game.canReturnToLobby) {
                      game.returnToLobby();
                    }
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.9),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Colors.yellowAccent,
                          size: 80,
                        ),
                        SizedBox(height: 20),
                        Text(
                          '게임 종료',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '승리: ${game.winner ?? "?"}',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.yellowAccent,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Results Table
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          constraints: BoxConstraints(maxHeight: 300),
                          child: SingleChildScrollView(
                            child: Table(
                              border: TableBorder.all(color: Colors.white24),
                              columnWidths: {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(1),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '닉네임',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '직업',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '결과',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ...game.endGamePlayers.map((p) {
                                  bool isWinner = false;
                                  if (game.winner == '시민' && p.role != '마피아') {
                                    isWinner = true;
                                  }
                                  if (game.winner == '마피아' && p.role == '마피아') {
                                    isWinner = true;
                                  }

                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          p.nickname,
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          p.role?.toString() ?? '-',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          isWinner ? '승리' : '패배',
                                          style: TextStyle(
                                            color: isWinner
                                                ? Colors.greenAccent
                                                : Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        if (game.canReturnToLobby)
                          Text(
                            '화면을 탭하여 로비로 돌아가기',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
