import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class LobbyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('LOBBY'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'WAITING FOR PLAYERS...',
              style: TextStyle(color: Colors.white70, fontSize: 20),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: game.players.length,
              itemBuilder: (context, index) {
                final player = game.players[index];
                final isMe = player.id == game.socket.id;
                return Card(
                  color: Colors.white10,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: ListTile(
                    leading: Icon(Icons.person, color: Colors.white),
                    title: Text(
                      player.nickname + (isMe ? ' (You)' : ''),
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: isMe
                        ? Icon(Icons.star, color: Colors.yellow)
                        : null,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Ideally only host starts, but for now anyone
                  game.startGame();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('START GAME'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
