// ignore_for_file: library_private_types_in_public_api, empty_catches, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatKlijentZaposlenik.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/chatKlijentZaposlenik_provider.dart';
import 'package:flutter_mobile/screens/chatKlijentZaposlenikMessagesScreen.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class ChatListScreen2 extends StatefulWidget {
  const ChatListScreen2({super.key});

  @override
  _ChatListScreen2State createState() => _ChatListScreen2State();
}

const String apiHost = String.fromEnvironment('API_HOST', defaultValue: 'localhost');
const String apiPort = String.fromEnvironment('API_PORT', defaultValue: '5269');

class _ChatListScreen2State extends State<ChatListScreen2> {
  List<chatKlijentZaposlenik> chats = [];
  Map<String, bool> unreadStatus = {};
  late ChatKlijentZaposlenikProvider chatProvider;
  late HubConnection connection;
  late bool isConnected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatKlijentZaposlenikProvider>();
    _initializeSignalR();
    _loadChats();
  }

  Future<void> _initializeSignalR() async {
    const signalRUrl = 'http://$apiHost:$apiPort/chat-hub';
    connection = HubConnectionBuilder().withUrl(signalRUrl).build();

    connection.onclose(({Exception? error}) {
      print('Connection closed: $error');
      if (mounted) setState(() => isConnected = false);
    });

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.userId;

    connection.on('ReceiveMessageZaposlenikKlijent', (message) {
      if (mounted) _handleNewMessage(message);
    });

    connection.on('ReceiveChatUpdate_$userId', (_) {
      if (mounted) _loadChats();
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
    final userProvider = context.read<UserProvider>();
    
    setState(() {
      final index = chats.indexWhere((c) => 
        c.klijentId == message.klijentId && 
        c.zaposlenikId == message.zaposlenikId
      );
      
      if (index != -1) {
        chats[index].poruka = message.poruka ?? '';
        
        final shouldBeBold = (userProvider.role == 'Zaposlenik' && message.poslanoOdKlijenta) || 
                            (userProvider.role == 'Klijent' && !message.poslanoOdKlijenta);
        
        unreadStatus[chatKey] = shouldBeBold;
      } else {
        _loadChats();
      }
    });
  } catch (e) {
    print('Error processing new message: $e');
  }
}
  String _getChatKey(int klijentId, int zaposlenikId) => '${klijentId}_$zaposlenikId';

Future<void> _loadChats() async {
  if (mounted) setState(() => _isLoading = true);
  final userProvider = context.read<UserProvider>();
  final userId = userProvider.userId;
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
          
          final shouldBeBold = (userProvider.role == 'Zaposlenik' && lastMessage.poslanoOdKlijenta) || 
                              (userProvider.role == 'Klijent' && !lastMessage.poslanoOdKlijenta);
          
          unreadStatus[chatKey] = shouldBeBold;
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
  } finally {
    if (mounted) setState(() => _isLoading = false);
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
    final isKlijent = userProvider.role == 'Klijent';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Chats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChats,
            tooltip: 'Refresh chats',
          ),
          if (!isConnected)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.wifi_off, size: 20, color: Colors.red),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.forum_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start a new chat to see it here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadChats,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: chats.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      final chatKey = _getChatKey(chat.klijentId, chat.zaposlenikId);
                      final chatName = isKlijent ? chat.zaposlenikIme : chat.klijentIme;
                      final isUnread = unreadStatus[chatKey] ?? false;

                      return _ChatListItem(
                        chatName: chatName,
                        lastMessage: chat.poruka ?? 'No messages yet',
                        isUnread: isUnread,
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
                          await _loadChats();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final String chatName;
  final String lastMessage;
  final bool isUnread;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.chatName,
    required this.lastMessage,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isUnread ? Colors.blue[50] : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isUnread ? Colors.blue : Colors.grey,
                child: Text(
                  chatName.isNotEmpty ? chatName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isUnread)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}