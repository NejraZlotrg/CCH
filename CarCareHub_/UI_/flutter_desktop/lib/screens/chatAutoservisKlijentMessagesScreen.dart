import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
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
    runSignalR();
  }

  Future<void> runSignalR() async {
    connection = HubConnectionBuilder()
        .withUrl('http://localhost:7209/chat-hub')
        .build();

    connection.onclose(({Exception? error}) {
      print('Connection closed: $error');
      isConnected = false;
    });

    var klijentId = widget.selectedChat.klijentId;
    var autoservisId = widget.selectedChat.autoservisId;

    // Kad stigne nova poruka, poziva onMessageReceived funkciju (callback)
    connection.on('ReceiveMessageAutoservisKlijent#${autoservisId}/${klijentId}', (arguments) {
      print('dosla poruka');
      fetchMessages();
    });

    connection.on('ReceiveMessageAutoservisKlijent#${klijentId}/${autoservisId}', (arguments) {
      print('dosla poruka');
      fetchMessages();
    });

    try {
      await connection.start();
      isConnected = true;
      print("SignalR connection established.");
    } catch (e) {
      isConnected = false;
      print('Error starting SignalR connection: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    if (isConnected) {
      connection.stop(); // Zaustavi SignalR konekciju
    }
    
    super.dispose();
  }


  // Fetch messages for the selected chat
Future<void> fetchMessages() async {
    try {
      final provider = Provider.of<ChatAutoservisKlijentProvider>(context, listen: false);
      final fetchedMessages = await provider.getMessages(
        widget.selectedChat.klijentId,
        widget.selectedChat.autoservisId,
      );

      if (mounted) { // Sprječava crash ako je widget unmountovan
        setState(() {
          messages = fetchedMessages;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }

    } catch (e) {
      if (mounted) { // Provjeri da li je widget još uvijek aktivan
        print('Error fetching messages: $e');
      }
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
  
  
  @override
Widget build(BuildContext context) {
  final userProvider = context.read<UserProvider>();
  final isLoggedUserAutoservis = userProvider.role == 'Klijent'; // Check if the logged-in user is 'Zaposlenik'


  return Scaffold(
    backgroundColor: Colors.grey[300], // Set background color of the entire screen to light gray

    appBar: AppBar(
      title: Text(
        'Chat with ${widget.selectedChat.klijentIme} - ${widget.selectedChat.autoservisNaziv}',
        textAlign: TextAlign.center, // Ensures the title text itself is centered
      ),
      backgroundColor: Colors.grey[400], // Set the AppBar background color to grey
      centerTitle: true, // Center the title in the AppBar
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0), // Add left and right margin for the body
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
                      final isMessageFromKlijent = message.poslanoOdKlijenta == true;

                      // Determine if the message is from the logged-in user
                      bool isMessageFromLoggedUser = isLoggedUserAutoservis
                          ? isMessageFromKlijent // If the logged-in user is Zaposlenik, messages from Klijent go left
                          : !isMessageFromKlijent; // If the logged-in user is not Zaposlenik, messages from Klijent go right

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0), // More vertical space between messages
                        child: Align(
                          alignment: isMessageFromLoggedUser
                              ? Alignment.centerRight // Message goes left
                              : Alignment.centerLeft, // Message goes right
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: isMessageFromLoggedUser
                                  ? Colors.blue[50] // Light blue background for the logged-in user
                                  : Colors.green[50], // Light green background for the other user
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey[400]!, // Grey border around each message
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
            padding: const EdgeInsets.symmetric(vertical: 8.0), // Vertical space around the input field
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0), // Margin at the top of the TextField
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Enter message',
                        labelStyle: TextStyle(color: Colors.grey), // Grey text for the label
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0), // Padding inside the field
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    String message = _messageController.text;
                    if (message.isNotEmpty) {
                      // Calling sendMessage function from the provider
                      Provider.of<ChatAutoservisKlijentProvider>(context, listen: false)
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
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}}
