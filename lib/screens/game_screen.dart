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

                        // Calculate optimal columns and rows to fit screen
                        // Try to keep it somewhat square or landscape
                        int cols = 4;
                        if (playerCount <= 4)
                          cols = 2;
                        else if (playerCount <= 9)
                          cols = 3;
                        else
                          cols = 4;

                        // If we have many players, we might need 5 cols
                        if (playerCount > 12) cols = 5;

                        final rows = (playerCount / cols).ceil();

                        // Calculate Aspect Ratio to fit the height exactly (minus spacing)
                        final spacing = 4.0;
                        final totalHorizontalSpacing = (cols - 1) * spacing;
                        final totalVerticalSpacing =
                            (rows - 1) *
                            spacing; // Rough estimate of vertical spacing usage

                        final availableWidth =
                            constraints.maxWidth - 20; // 10 padding each side
                        final availableHeight = constraints.maxHeight - 20;

                        final itemWidth =
                            (availableWidth - totalHorizontalSpacing) / cols;
                        final itemHeight =
                            (availableHeight - totalVerticalSpacing) / rows;

                        final ratio = itemWidth / itemHeight;

                        return GridView.builder(
                          padding: EdgeInsets.all(10),
                          physics:
                              NeverScrollableScrollPhysics(), // Disable scrolling
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
                                : Colors.red[900]!.withOpacity(0.8);

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
                                  if (!player.isAlive) return;
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
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      player.isAlive
                                          ? Icons.person
                                          : Icons
                                                .sentiment_dissatisfied, // Changed icon for dead
                                      size: 40,
                                      color: player.isAlive
                                          ? Colors.white
                                          : Colors.grey, // Grey for dead icon
                                    ),
                                    if (!player.isAlive)
                                      Container(
                                        margin: EdgeInsets.only(top: 2),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red[900],
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          "사망",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: 5),
                                    Text(
                                      player.nickname + (isMe ? ' (나)' : ''),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (game.gameState == '낮' && player.isAlive)
                                      Text(
                                        '득표수: $voteCount',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    if (game.gameState == '낮' && player.isAlive)
                                      Builder(
                                        builder: (context) {
                                          // Find players who voted for this player
                                          final votersForThis = game
                                              .voters
                                              .entries
                                              .where(
                                                (entry) =>
                                                    entry.value == player.id,
                                              )
                                              .map((entry) {
                                                final voterId = entry.key;
                                                final voter = game.players
                                                    .firstWhere(
                                                      (p) => p.id == voterId,
                                                      orElse: () => Player(
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
                                              margin: EdgeInsets.only(top: 4),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black45,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '지목: ${votersForThis.join(", ")}',
                                                style: TextStyle(
                                                  color: Colors.redAccent,
                                                  fontSize: 10,
                                                ),
                                                textAlign: TextAlign.center,
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
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          selectionTargetForRole.join(', '),
                                          style: TextStyle(
                                            color: Colors.yellowAccent,
                                            fontSize: 10,
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
