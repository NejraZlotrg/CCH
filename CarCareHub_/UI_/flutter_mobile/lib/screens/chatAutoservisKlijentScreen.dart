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
      } else {
        print("No chats available for this user.");
      }
    } catch (e) {
      print("Error fetching chats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: chats.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  title: Text(
                    'Chat with ${chat.klijent.ime} - ${chat.autoservis.naziv}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatAutoservisKlijentMessagesScreen(
                          selectedChat: chat,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
