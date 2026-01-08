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
            Text('${game.gameState} - DAY ${game.dayCount}'),
            Text(
              'Role: ${game.myRole ?? "Unknown"}',
              style: TextStyle(fontSize: 14, color: Colors.yellowAccent),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Column(
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
                      if (game.gameState == 'DAY') {
                        game.vote(player.id);
                      } else if (game.gameState == 'NIGHT') {
                        String? action;
                        if (game.myRole == 'MAFIA') action = 'kill';
                        if (game.myRole == 'DOCTOR') action = 'heal';
                        if (game.myRole == 'POLICE') action = 'investigate';

                        if (action != null) {
                          game.nightAction(action, player.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Action $action sent!')),
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
                          color: player.isAlive ? Colors.white : Colors.black54,
                        ),
                        SizedBox(height: 5),
                        Text(
                          player.nickname + (isMe ? ' (You)' : ''),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (game.gameState == 'DAY' && player.isAlive)
                          Text(
                            'Votes: $voteCount',
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
                      hintText: 'Type a message...',
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
    );
  }
}
