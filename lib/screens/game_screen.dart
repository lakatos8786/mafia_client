import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class GameScreen extends StatefulWidget {
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
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Column(
          children: [
            Text('${game.gameState} - ${game.dayCount}일차'),
            Text(
              '직업: ${game.myRole ?? "알 수 없음"}',
              style: TextStyle(fontSize: 14, color: Colors.yellowAccent),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Game Area
              Expanded(
                flex: 2,
                child: GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: game.players.length,
                  itemBuilder: (context, index) {
                    final player = game.players[index];
                    final isMe = player.id == game.socket.id;
                    final voteCount = game.votes[player.id] ?? 0;

                    return Card(
                      color: player.isAlive
                          ? Colors.blueGrey[800]
                          : Colors.red[900],
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
                            if (game.myRole == '경찰') action = 'investigate';

                            if (action != null) {
                              String actionName = action;
                              if (action == 'kill') actionName = '처단';
                              if (action == 'heal') actionName = '치료';
                              if (action == 'investigate') actionName = '조사';

                              game.nightAction(action, player.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$actionName 완료!')),
                              );
                            }
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              player.isAlive ? Icons.person : Icons.cancel,
                              size: 40,
                              color: player.isAlive
                                  ? Colors.white
                                  : Colors.black54,
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
                          ],
                        ),
                      ),
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        child: Text(
                          '$sender: $text',
                          style: TextStyle(color: Colors.white70),
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
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
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
          if (game.gameState == '결과')
            Positioned.fill(
              child: GestureDetector(
                onTap: () => game.returnToLobby(),
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
                                if (game.winner == '시민' && p.role != '마피아')
                                  isWinner = true;
                                if (game.winner == '마피아' && p.role == '마피아')
                                  isWinner = true;

                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        p.nickname,
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        p.role ?? '-',
                                        style: TextStyle(color: Colors.white70),
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
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '화면을 탭하여 로비로 돌아가기',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
