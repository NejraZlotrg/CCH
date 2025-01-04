import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatKlijentZaposlenik.dart';
import 'package:flutter_mobile/provider/chatKlijentZaposlenik_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/screens/chatKlijentZaposlenikMessagesScreen.dart';
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
    chatKlijentZaposlenikProvider = context.read<ChatKlijentZaposlenikProvider>();
    fetchChats();
  }

Future<void> fetchChats() async {
  final userProvider = context.read<UserProvider>();
  int userId = userProvider.userId;

  // Print the userId
  print("User ID: $userId");

  try {
    var response = await chatKlijentZaposlenikProvider.getById__(userId);

    if (response != null && response.isNotEmpty) {
      // Iterate over the response to check for nulls and handle them
      for (var chat in response) {
        // Check for null values in the response before accessing them
        int? klijentId = chat.klijentId;
        int? zaposlenikId = chat.zaposlenikId;

        // Make sure you handle nulls properly
        if (klijentId != null && zaposlenikId != null) {
          print('Chat with Klijent ID: $klijentId and Zaposlenik ID: $zaposlenikId');
        } else {
          print('Chat data contains null IDs.');
        }
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
                    'Chat with ${chat.klijent?.ime} - ${chat.zaposlenik?.ime}  ${chat.zaposlenik?.prezime}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => chatKlijentZaposlenikMessagesScreen(
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
