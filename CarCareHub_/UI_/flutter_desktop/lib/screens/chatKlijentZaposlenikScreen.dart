import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatKlijentZaposlenik.dart';
import 'package:flutter_mobile/provider/chatKlijentZaposlenik_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/screens/chatKlijentZaposlenikMessagesScreen.dart';
import 'package:provider/provider.dart';

class ChatListScreen2 extends StatefulWidget {
  const ChatListScreen2({super.key});

  @override
  _ChatListScreen2State createState() => _ChatListScreen2State();
}

class _ChatListScreen2State extends State<ChatListScreen2> {
  List<chatKlijentZaposlenik> chats = [];
  late ChatKlijentZaposlenikProvider chatKlijentZaposlenikProvider;

  @override
  void initState() {
    super.initState();
    chatKlijentZaposlenikProvider = context.read<ChatKlijentZaposlenikProvider>();
    fetchChats();
  }

  Future<void> fetchChats() async {
    final userProvider = context.read<UserProvider>();
    int userId = userProvider.userId;

    print("User ID: $userId");

    try {
      var response = await chatKlijentZaposlenikProvider.getById__(userId);

      if (response.isNotEmpty) {
        for (var chat in response) {
          int? klijentId = chat.klijentId;
          int? zaposlenikId = chat.zaposlenikId;
          
          // Dohvati zadnju poruku za svaki chat
          var messages = await chatKlijentZaposlenikProvider.getMessages(klijentId, zaposlenikId);
          if (messages.isNotEmpty) {
            chat.poruka = messages.last.poruka; // Postavi zadnju poruku u model
          }

          print('Chat with Klijent ID: $klijentId and Zaposlenik ID: $zaposlenikId');
        }

        setState(() {
          chats = response;
        });
      } else {
        print("No chats available for this user.");
      }
    } catch (e) {
      print("Error fetching chats: $e");
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
                final chatName = isKlijent ? chat.zaposlenikIme : chat.klijentIme;

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
                        chat.poruka ?? 'No messages yet',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => chatKlijentZaposlenikMessagesScreen(
                              selectedChat: chat,
                            ),
                          ),
                        );

                        // Nakon povratka sa ekrana poruka, ponovo dohvatimo chatove
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
