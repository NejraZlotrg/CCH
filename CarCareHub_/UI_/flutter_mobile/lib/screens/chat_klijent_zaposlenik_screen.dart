// ignore_for_file: library_private_types_in_public_api, empty_catches, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatKlijentZaposlenik.dart';
import 'package:flutter_mobile/provider/chat_klijent_zaposlenik_provider.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
import 'package:flutter_mobile/screens/chat_klijent_zaposlenik_messages_screen.dart';
import 'package:provider/provider.dart';

class ChatListScreen2 extends StatefulWidget {
  const ChatListScreen2({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen2> {
  List<chatKlijentZaposlenik> chats = [];
  late ChatKlijentZaposlenikProvider chatKlijentZaposlenikProvider;

  @override
  void initState() {
    super.initState();
    chatKlijentZaposlenikProvider =
        context.read<ChatKlijentZaposlenikProvider>();
    fetchChats();
  }

  Future<void> fetchChats() async {
    final userProvider = context.read<UserProvider>();
    int userId = userProvider.userId;

    try {
      var response = await chatKlijentZaposlenikProvider.getById__(userId);

      if (response.isNotEmpty) {
        setState(() {
          chats = response;
        });
      } else {}
    } catch (e) {}
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
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final isKlijent = userProvider.role == 'Klijent';
                final chatName = isKlijent
                    ? '${chat.zaposlenikIme} '
                    : '${chat.klijentIme} ';

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 5.0),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                chatKlijentZaposlenikMessagesScreen(
                              selectedChat: chat,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
