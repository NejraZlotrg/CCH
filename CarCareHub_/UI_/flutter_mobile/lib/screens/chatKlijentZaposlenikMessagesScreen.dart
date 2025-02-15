import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatKlijentZaposlenik.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/chatKlijentZaposlenik_provider.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class chatKlijentZaposlenikMessagesScreen extends StatefulWidget {
  final chatKlijentZaposlenik selectedChat;

  const chatKlijentZaposlenikMessagesScreen(
      {super.key, required this.selectedChat});

  @override
  _ChatMessagesScreenState createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState
    extends State<chatKlijentZaposlenikMessagesScreen> {
  late HubConnection connection;
  List<chatKlijentZaposlenik> messages = [];
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
        .withUrl('http://192.168.0.10:7209/chatKlijentZaposlenik')
        .build();

    connection.onclose(({Exception? error}) {
      print('Connection closed: $error');
      isConnected = false;
    });

    var klijentId = widget.selectedChat.klijentId;
    var zaposlenikId = widget.selectedChat.zaposlenikId;

    // Kad stigne nova poruka, poziva onMessageReceived funkciju (callback)
    connection.on('ReceiveMessageZaposlenikKlijent#${zaposlenikId}/${klijentId}', (arguments) {
      fetchMessages();
    });

    connection.on('ReceiveMessageZaposlenikKlijent#${klijentId}/${zaposlenikId}', (arguments) {
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

  // Fetch messages for the selected chat
  Future<void> fetchMessages() async {
    try {
      final provider = Provider.of<ChatKlijentZaposlenikProvider>(context, listen: false);
      final fetchedMessages = await provider.getMessages(
        widget.selectedChat.klijentId!,
        widget.selectedChat.zaposlenikId!,
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
  @override
Widget build(BuildContext context) {
  final userProvider = context.read<UserProvider>();
  final isLoggedUserZaposlenik = userProvider.role == 'Zaposlenik'; // Check if the logged-in user is 'Zaposlenik'

  return Scaffold(
    backgroundColor: Colors.grey[300], // Set background color of the entire screen to light gray
    appBar: AppBar(
      title: Text(
        'Chat with ${widget.selectedChat.klijent?.ime} - ${widget.selectedChat.zaposlenik?.ime} ${widget.selectedChat.zaposlenik?.prezime}',
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
                      bool isMessageFromLoggedUser = isLoggedUserZaposlenik
                          ? isMessageFromKlijent // If the logged-in user is Zaposlenik, messages from Klijent go left
                          : !isMessageFromKlijent; // If the logged-in user is not Zaposlenik, messages from Klijent go right

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0), // More vertical space between messages
                        child: Align(
                          alignment: isMessageFromLoggedUser
                              ? Alignment.centerLeft // Message goes left
                              : Alignment.centerRight, // Message goes right
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
                      Provider.of<ChatKlijentZaposlenikProvider>(context, listen: false)
                          .sendMessage(
                              widget.selectedChat.klijentId!,
                              widget.selectedChat.zaposlenikId!,
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
}
}
