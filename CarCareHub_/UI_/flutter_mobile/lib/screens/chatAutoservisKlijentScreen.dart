import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/chatAutoservisKlijent_provider.dart';

class ChatAutoservisKlijentScreen extends StatefulWidget {
  const ChatAutoservisKlijentScreen({super.key});

  @override
  _ChatAutoservisKlijentScreenState createState() =>
      _ChatAutoservisKlijentScreenState();
}

class _ChatAutoservisKlijentScreenState
    extends State<ChatAutoservisKlijentScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<chatAutoservisKlijent> chats = [];
  List<chatAutoservisKlijent> messages = [];
  chatAutoservisKlijent? selectedChat;

  late ChatAutoservisKlijentProvider chatAutoservisKlijentProvider;
  late HubConnection connection;

  late bool isConnected = false;

  @override
  void initState() {
    super.initState();
    chatAutoservisKlijentProvider = context.read<ChatAutoservisKlijentProvider>();
    fetchChats(); // Fetch chats when initializing
    runSignalR(); // Start the SignalR connection
  }

  // Run SignalR connection to handle real-time messaging
  Future<void> runSignalR() async {
    connection = HubConnectionBuilder()
        .withUrl('http://localhost:7209/chatAutoservisKlijent')
        .build();

    connection.onclose(({Exception? error}) {
      setState(() {
        isConnected = false;
      });
    });

    connection.on('ReceiveMessage', (arguments) {
      if (arguments != null &&
          arguments.isNotEmpty &&
          arguments[0] is Map<String, dynamic>) {
        var chatMessage =
            chatAutoservisKlijent.fromJson(arguments[0] as Map<String, dynamic>);
        setState(() {
          messages.add(chatMessage);
        });
      }
    });

    try {
      await connection.start();
      setState(() {
        isConnected = true;
      });
    } catch (e) {
      setState(() {
        isConnected = false;
      });
      print('Error starting SignalR connection: $e');
    }
  }

  // Fetch chats for the logged-in user
 Future<void> fetchChats() async {
  final userProvider = context.read<UserProvider>();
  int userId = userProvider.userId;

  try {
    var response = await chatAutoservisKlijentProvider.getById__(userId);

    // Log the response for debugging
    print('Fetched chats: $response');

    if (response.isNotEmpty) {
      setState(() {
        chats = response;
      });
    } else {
      print("No chats available for this user.");
    }
  } catch (e) {
    // Catch different types of errors
    if (e is SocketException) {
      print("Network error: Please check your internet connection.");
    } else if (e is TimeoutException) {
      print("Request timed out: The server is taking too long to respond.");
    } else {
      print("Error fetching chats: $e");
    }
  }
}


  // Send a message via SignalR and backend
  Future<void> sendMessage(
      int klijentId, int autoservisId, String poruka, bool poslanoOdKlijenta) async {
    try {
      if (isConnected) {
        await connection.invoke('SendMessage', args: [
          klijentId,
          autoservisId,
          poruka,
          poslanoOdKlijenta
        ]);
        await _sendMessageToBackend(klijentId, autoservisId, poruka, poslanoOdKlijenta);
       // fetchMessages(autoservisId, klijentId); // Refresh the messages after sending
      } else {
        print("SignalR connection is not established.");
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Send message to backend API
  Future<void> _sendMessageToBackend(
      int klijentId, int autoservisId, String poruka, bool poslanoOdKlijenta) async {
    final url = Uri.parse(
      'http://localhost:7209/api/ChatAutoservisKlijent/posalji?klijentId=$klijentId&autoservisId=$autoservisId&poruka=$poruka',
    );

    final headers = chatAutoservisKlijentProvider.createHeaders();

    try {
      final response = await http.post(url, headers: headers);
      if (response.statusCode != 200) {
        throw Exception('Failed to send message to backend. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message to backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat - ${userProvider.role} ${userProvider.userId}"),
      ),
      body: Row(
        children: [
          // Left Panel: List of Chats
          Expanded(
            flex: 1, // 1/3 of the width
            child: Container(
              color: Colors.grey.shade200,
              child: chats.isEmpty
                  ? const Center(child: CircularProgressIndicator()) // Loading state
                  : ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return ListTile(
                          title: Text(
                            'Chat with ${chat.klijent.ime} + ${chat.autoservis.naziv}', // Customize the title
                          ),
                          selected: selectedChat == chat,
                          onTap: () {
                            setState(() {
                              selectedChat = chat;
                            });
                          //  fetchMessages(chat.autoservisId!, chat.klijentId!);
                          },
                        );
                      },
                    ),
            ),
          ),

          // Right Panel: Chat Messages
          Expanded(
            flex: 2, // 2/3 of the width
            child: Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const Center(child: Text('Select a chat to view messages'))
                      : ListView.builder(
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
                            labelText: 'Enter your message',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          final message = _messageController.text;
                          if (message.isNotEmpty && selectedChat != null) {
                            sendMessage(
                              selectedChat!.klijentId!,
                              selectedChat!.autoservisId!,
                              message,
                              true,
                            );
                            _messageController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
