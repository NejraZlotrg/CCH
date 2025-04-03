import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatKlijentZaposlenik.dart';
import 'package:flutter_mobile/provider/chatKlijentZaposlenik_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/screens/chatKlijentZaposlenikMessagesScreen.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class ChatListScreen2 extends StatefulWidget {
  const ChatListScreen2({super.key});

  @override
  _ChatListScreen2State createState() => _ChatListScreen2State();
}

class _ChatListScreen2State extends State<ChatListScreen2> {
  List<chatKlijentZaposlenik> chats = [];
  Map<String, bool> unreadStatus = {};
  late ChatKlijentZaposlenikProvider chatProvider;
  late HubConnection connection;
  late bool isConnected = false;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatKlijentZaposlenikProvider>();
    _initializeSignalR();
    fetchChats();
  }

  Future<void> _initializeSignalR() async {
    connection = HubConnectionBuilder()
        .withUrl('http://localhost:7209/chat-hub')
        .build();

    connection.onclose(({Exception? error}) {
      print('Connection closed: $error');
      if (mounted) {
        setState(() => isConnected = false);
      }
    });

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.userId;

    // Listen for specific chat updates
    connection.on('ReceiveMessageZaposlenikKlijent', (message) {
      if (mounted) _handleNewMessage(message);
    });

    // Listen for general updates
    connection.on('ReceiveChatUpdate_$userId', (_) {
      if (mounted) fetchChats();
    });

    try {
      await connection.start();
      if (mounted) {
        setState(() => isConnected = true);
      }
      print("SignalR connection established for chat list.");
    } catch (e) {
      print('Error starting SignalR connection: $e');
    }
  }

  void _handleNewMessage(dynamic messageData) {
    try {
      final message = chatKlijentZaposlenik.fromJson(messageData);
      final chatKey = _getChatKey(message.klijentId, message.zaposlenikId);
      
      setState(() {
        final index = chats.indexWhere((c) => 
          c.klijentId == message.klijentId && 
          c.zaposlenikId == message.zaposlenikId
        );
        
        if (index != -1) {
          // Update existing chat
          chats[index].poruka = message.poruka;
          
          // Mark as unread if message is from other user
          final userProvider = context.read<UserProvider>();
          final isCurrentUser = (userProvider.role == 'Klijent') 
              ? message.poslanoOdKlijenta 
              : !message.poslanoOdKlijenta;
          
          if (!isCurrentUser) {
            unreadStatus[chatKey] = true;
          }
        } else {
          // If new chat, refresh the whole list
          fetchChats();
        }
      });
    } catch (e) {
      print('Error processing new message: $e');
    }
  }

  String _getChatKey(int klijentId, int zaposlenikId) => '${klijentId}_$zaposlenikId';

  Future<void> fetchChats() async {
    final userProvider = context.read<UserProvider>();
    int userId = userProvider.userId;

    try {
      var response = await chatProvider.getById__(userId);

      if (response.isNotEmpty) {
        for (var chat in response) {
          int? klijentId = chat.klijentId;
          int? zaposlenikId = chat.zaposlenikId;
          final chatKey = _getChatKey(klijentId, zaposlenikId);
          
          var messages = await chatProvider.getMessages(klijentId, zaposlenikId);
          if (messages.isNotEmpty) {
            final lastMessage = messages.last;
            chat.poruka = lastMessage.poruka;
            
            final isCurrentUser = (userProvider.role == 'Klijent') 
                ? lastMessage.poslanoOdKlijenta 
                : !lastMessage.poslanoOdKlijenta;
            
            if (!isCurrentUser && (unreadStatus[chatKey] ?? true)) {
              unreadStatus[chatKey] = true;
            }
          }
        }

        if (mounted) {
          setState(() {
            chats = response;
          });
        }
      }
    } catch (e) {
      print("Error fetching chats: $e");
    }
  }

  void _markChatAsRead(int klijentId, int zaposlenikId) {
    setState(() {
      unreadStatus[_getChatKey(klijentId, zaposlenikId)] = false;
    });
  }

  @override
  void dispose() {
    connection.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final username = userProvider.username;
    final isKlijent = userProvider.role == 'Klijent';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Chats of $username'),
            if (!isConnected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(Icons.wifi_off, size: 20, color: Colors.red[300]),
              ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchChats,
        child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final chatKey = _getChatKey(chat.klijentId, chat.zaposlenikId);
            final chatName = isKlijent ? chat.zaposlenikIme : chat.klijentIme;
            final isUnread = unreadStatus[chatKey] ?? false;

            return _buildChatItem(chat, chatName, isUnread);
          },
        ),
      ),
    );
  }

  Widget _buildChatItem(chatKlijentZaposlenik chat, String chatName, bool isUnread) {
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
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              color: isUnread ? Colors.black : Colors.grey[700],
            ),
          ),
          subtitle: Text(
            chat.poruka ?? 'No messages yet',
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              color: isUnread ? Colors.black : Colors.grey,
            ),
          ),
          trailing: isUnread
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                )
              : null,
          onTap: () async {
            _markChatAsRead(chat.klijentId, chat.zaposlenikId);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => chatKlijentZaposlenikMessagesScreen(
                  selectedChat: chat,
                ),
              ),
            );
            await fetchChats();
          },
        ),
      ),
    );
  }
}