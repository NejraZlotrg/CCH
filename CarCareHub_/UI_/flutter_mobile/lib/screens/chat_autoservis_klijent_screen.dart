// ignore_for_file: library_private_types_in_public_api, empty_catches, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/provider/chat_autoservis_klijent_provider.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
import 'package:flutter_mobile/screens/chat_autoservis_klijent_messages_screen.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<chatAutoservisKlijent> chats = [];
  late ChatAutoservisKlijentProvider chatAutoservisKlijentProvider;

  @override
  void initState() {
    super.initState();
    chatAutoservisKlijentProvider =
        context.read<ChatAutoservisKlijentProvider>();
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
                final chatName =
                    isKlijent ? chat.autoservisNaziv : chat.klijentIme;

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
                                ChatAutoservisKlijentMessagesScreen(
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
