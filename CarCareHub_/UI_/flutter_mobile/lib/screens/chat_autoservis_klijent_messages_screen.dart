// ignore_for_file: deprecated_member_use, use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/provider/user_provider.dart';
import 'package:flutter_mobile/provider/chat_autoservis_klijent_provider.dart';
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


const String apiHost = String.fromEnvironment('API_HOST', defaultValue: 'localhost');
const String apiPort = String.fromEnvironment('API_PORT', defaultValue: '5269');

class _ChatMessagesScreenState
    extends State<ChatAutoservisKlijentMessagesScreen> {
  late HubConnection connection;
  List<chatAutoservisKlijent> messages = [];
  late bool isConnected = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchMessages();
    runSignalR();
  }

  Future<void> runSignalR() async {
 const signalRUrl = 'http://$apiHost:$apiPort/chat-hub';
connection = HubConnectionBuilder()
    .withUrl(signalRUrl)
    .build();

    connection.onclose(({Exception? error}) {
      isConnected = false;
    });

    var klijentId = widget.selectedChat.klijentId;
    var autoservisId = widget.selectedChat.autoservisId;

    connection.on('ReceiveMessageAutoservisKlijent#$autoservisId/$klijentId',
        (arguments) {
      fetchMessages();
    });

    connection.on('ReceiveMessageAutoservisKlijent#$klijentId/$autoservisId',
        (arguments) {
      fetchMessages();
    });

    try {
      await connection.start();
      isConnected = true;
    } catch (e) {
      isConnected = false;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    if (isConnected) {
      connection.stop();
    }

    super.dispose();
  }

  Future<void> fetchMessages() async {
    try {
      final provider =
          Provider.of<ChatAutoservisKlijentProvider>(context, listen: false);
      final fetchedMessages = await provider.getMessages(
        widget.selectedChat.klijentId,
        widget.selectedChat.autoservisId,
      );

      if (mounted) {
        setState(() {
          messages = fetchedMessages;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      if (mounted) {}
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final isLoggedUserAutoservis = userProvider.role == 'Klijent';

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          'Chat with ${widget.selectedChat.klijentIme} - ${widget.selectedChat.autoservisNaziv}',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.grey[400],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? const Center(child: Text('No messages yet.'))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMessageFromKlijent =
                            message.poslanoOdKlijenta == true;

                        bool isMessageFromLoggedUser = isLoggedUserAutoservis
                            ? isMessageFromKlijent
                            : !isMessageFromKlijent;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Align(
                            alignment: isMessageFromLoggedUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: isMessageFromLoggedUser
                                    ? Colors.blue[50]
                                    : Colors.green[50],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey[400]!,
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(
                                    message.poruka ?? 'No message',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Enter message',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 15.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      String message = _messageController.text;
                      if (message.isNotEmpty) {
                        Provider.of<ChatAutoservisKlijentProvider>(context,
                                listen: false)
                            .sendMessage(widget.selectedChat.klijentId,
                                widget.selectedChat.autoservisId, message)
                            .then((_) {
                          _messageController.clear();
                          fetchMessages();
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())));
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
