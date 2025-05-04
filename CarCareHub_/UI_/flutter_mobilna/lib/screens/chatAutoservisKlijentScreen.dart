import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/provider/chatAutoservisKlijent_provider.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/screens/chatAutoservisKlijentMessagesScreen.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<chatAutoservisKlijent> chats = [];
  Map<String, String> lastMessages = {};
  Map<String, bool> unreadStatus = {};
  late ChatAutoservisKlijentProvider chatProvider;
  late HubConnection connection;
  late bool isConnected = false;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatAutoservisKlijentProvider>();
    _initializeSignalR();
    _loadChats();
  }

  Future<void> _initializeSignalR() async {
    connection = HubConnectionBuilder()
        .withUrl('http://localhost:7209/chat-hub')
        .build();

    connection.onclose(({Exception? error}) {
      print('Connection closed: $error');
      if (mounted) setState(() => isConnected = false);
    });

    // Setup listeners for each chat when they're loaded
    connection.on('ReceiveMessageAutoservisKlijent', (message) {
      if (mounted) _handleNewMessage(message);
    });

    try {
      await connection.start();
      if (mounted) setState(() => isConnected = true);
      print("SignalR connection established for autoservis chat list.");
    } catch (e) {
      print('Error starting SignalR connection: $e');
    }
  }

  void _handleNewMessage(dynamic messageData) {
    try {
      final message = chatAutoservisKlijent.fromJson(messageData);
      final chatKey = _getChatKey(message.klijentId, message.autoservisId);
      
      setState(() {
        final index = chats.indexWhere((c) => 
          c.klijentId == message.klijentId && 
          c.autoservisId == message.autoservisId
        );
        
        if (index != -1) {
          // Update existing chat
          lastMessages[chatKey] = message.poruka ?? '';
          
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
          _loadChats();
        }
      });
    } catch (e) {
      print('Error processing new message: $e');
    }
  }

  String _getChatKey(int klijentId, int autoservisId) => '${klijentId}_$autoservisId';

  Future<void> _loadChats() async {
    try {
      final userProvider = context.read<UserProvider>();
      final userId = userProvider.userId;
      final response = await chatProvider.getById__(userId);

      if (mounted) {
        setState(() {
          chats = response;
          // Initialize unread status for all chats
          for (final chat in response) {
            final chatKey = _getChatKey(chat.klijentId, chat.autoservisId);
            unreadStatus[chatKey] = unreadStatus[chatKey] ?? false;
          }
        });

        // Load last messages for each chat
        await Future.wait(
          response.map((chat) => _loadLastMessage(chat.klijentId, chat.autoservisId)),
        );
      }
    } catch (e) {
      debugPrint("Error loading chats: $e");
    }
  }

  Future<void> _loadLastMessage(int klijentId, int autoservisId) async {
    try {
      final messages = await chatProvider.getMessages(klijentId, autoservisId);
      if (messages.isEmpty) return;

      final lastMessage = messages.last;
      final chatKey = _getChatKey(klijentId, autoservisId);
      final userProvider = context.read<UserProvider>();
      final isCurrentUser = (userProvider.role == 'Klijent') 
          ? lastMessage.poslanoOdKlijenta 
          : !lastMessage.poslanoOdKlijenta;

      if (mounted) {
        setState(() {
          lastMessages[chatKey] = lastMessage.poruka ?? '';
          if (!isCurrentUser) {
            unreadStatus[chatKey] = true;
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading last message: $e");
    }
  }

  void _markChatAsRead(int klijentId, int autoservisId) {
    setState(() {
      unreadStatus[_getChatKey(klijentId, autoservisId)] = false;
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
      body: chats.isEmpty
          ? const Center(child: Text('No conversations yet'))
          : RefreshIndicator(
              onRefresh: _loadChats,
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final chatKey = _getChatKey(chat.klijentId, chat.autoservisId);
                  final chatName = isKlijent ? chat.autoservisNaziv : chat.klijentIme;
                  final isUnread = unreadStatus[chatKey] ?? false;
                  final lastMessage = lastMessages[chatKey] ?? 'Loading...';

                  return _buildChatItem(
                    context,
                    chatName: chatName,
                    lastMessage: lastMessage,
                    isUnread: isUnread,
                    onTap: () => _openChat(context, chat),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String chatName,
    required String lastMessage,
    required bool isUnread,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Text(
              chatName.isNotEmpty ? chatName[0].toUpperCase() : '?',
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
            lastMessage,
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              color: isUnread ? Colors.black : Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: isUnread
              ? const CircleAvatar(
                  radius: 6,
                  backgroundColor: Colors.blue,
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }

  Future<void> _openChat(BuildContext context, chatAutoservisKlijent chat) async {
    // Mark as read before opening
    _markChatAsRead(chat.klijentId, chat.autoservisId);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatAutoservisKlijentMessagesScreen(
          selectedChat: chat,
        ),
      ),
    );

    // Refresh the chat when returning
    if (mounted) {
      await _loadLastMessage(chat.klijentId, chat.autoservisId);
    }
  }
} 