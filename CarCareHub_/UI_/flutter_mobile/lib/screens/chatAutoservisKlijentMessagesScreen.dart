import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/provider/chatAutoservisKlijent_provider.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class ChatAutoservisKlijentMessagesScreen extends StatefulWidget {
  final chatAutoservisKlijent selectedChat;

  const ChatAutoservisKlijentMessagesScreen(
      {super.key, required this.selectedChat});

  @override
  _ChatMessagesScreenState createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState
    extends State<ChatAutoservisKlijentMessagesScreen> {
  late HubConnection connection;
  List<chatAutoservisKlijent> messages = [];
  late bool isConnected = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // ScrollController

  @override
  void initState() {
    super.initState();
    fetchMessages(); // Pozivamo fetchMessages iz provider-a
    Provider.of<ChatAutoservisKlijentProvider>(context, listen: false)
        .runSignalR((chatMessage) {
          // Ovdje ćemo obraditi novu poruku i dodati je u listu
          setState(() {
            messages.add(chatMessage);
          });
          // Automatsko skrolovanje na dno kad stigne nova poruka
          _scrollToBottom();
        });
  }

  // Fetch messages for the selected chat
  Future<void> fetchMessages() async {
    try {
      final provider = Provider.of<ChatAutoservisKlijentProvider>(context, listen: false);
      final fetchedMessages = await provider.getMessages(
        widget.selectedChat.klijentId,
        widget.selectedChat.autoservisId,
      );

      setState(() {
        messages = fetchedMessages;
      });

      // Automatsko skrolovanje na dno kad se učitaju poruke
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  // Funckija koja skroluje na dno
  void _scrollToBottom() {
    // Provjeravamo da li je lista poruka prazna
    if (_scrollController.hasClients) {
      // Skrolujemo na dno liste
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  // Send a message via SignalR and backend API
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Chat with ${widget.selectedChat.klijent.ime} - ${widget.selectedChat.autoservis.naziv}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('No messages yet.'))
                : ListView.builder(
                    controller: _scrollController, // Postavljamo ScrollController
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(messages[index].poruka ?? 'No message'),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Enter message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      String message = _messageController.text;
                      if (message.isNotEmpty) {
                        // Pozivamo sendMessage funkciju iz provider-a
                        Provider.of<ChatAutoservisKlijentProvider>(context,
                                listen: false)
                            .sendMessage(
                                widget.selectedChat.klijentId,
                                widget.selectedChat.autoservisId,
                                message)
                            .then((_) {
                          _messageController.clear();
                          fetchMessages(); // Refresh messages after sending
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())));
                        });
                      }
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
