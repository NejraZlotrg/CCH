import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/provider/chatAutoservisKlijent_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/screens/chatAutoservisKlijentMessagesScreen.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<chatAutoservisKlijent> chats = [];
  Map<int, String> lastMessages = {}; // Čuvamo zadnje poruke za svaki chat
  late ChatAutoservisKlijentProvider chatAutoservisKlijentProvider;

  @override
  void initState() {
    super.initState();
    chatAutoservisKlijentProvider = context.read<ChatAutoservisKlijentProvider>();
    fetchChats();
  }

  Future<void> fetchChats() async {
    final userProvider = context.read<UserProvider>();
    int userId = userProvider.userId;

    try {
      var response = await chatAutoservisKlijentProvider.getById__(userId);

      if (response.isNotEmpty) {
        setState(() {
          chats = response;
        });

        // Nakon što dobijemo sve chatove, dohvaćamo zadnje poruke
        for (var chat in response) {
          fetchLastMessage(chat.klijentId, chat.autoservisId);
        }
      } else {
        print("No chats available for this user.");
      }
    } catch (e) {
      print("Error fetching chats: $e");
    }
  }

  Future<void> fetchLastMessage(int klijentId, int autoservisId) async {
    try {
      var messages = await chatAutoservisKlijentProvider.getMessages(klijentId, autoservisId);

      if (messages.isNotEmpty) {
        setState(() {
          lastMessages[klijentId] = messages.last.poruka!; // Uzimamo zadnju poruku
        });
      } else {
        setState(() {
          lastMessages[klijentId] = 'No messages yet';
        });
      }
    } catch (e) {
      print("Error fetching messages for chat ($klijentId, $autoservisId): $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final username = userProvider.username;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats of $username'),
      ),
      body: chats.isEmpty
          ? const Center(
              child: Text(
                'Nemate nijedan razgovor',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final isKlijent = userProvider.role == 'Klijent';
                final chatName = isKlijent ? chat.autoservisNaziv : chat.klijentIme;

                // Dohvati zadnju poruku za ovaj chat
                String lastMessage = lastMessages[chat.klijentId] ?? 'Loading...';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          chatName.isNotEmpty ? chatName[0] : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        'Chat with $chatName',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        lastMessage,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatAutoservisKlijentMessagesScreen(
        selectedChat: chat,
      ),
    ),
  );
  
  // Nakon povratka sa chat ekrana, ponovo dohvatimo poruke
  fetchChats();
},

                    ),
                  ),
                );
              },
            ),
    );
  }
}
