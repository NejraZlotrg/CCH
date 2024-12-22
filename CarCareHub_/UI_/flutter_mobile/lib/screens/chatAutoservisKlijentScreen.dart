import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/http_connection_options.dart';

import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/chatAutoservisKlijent_provider.dart';
import 'package:http/http.dart' as http;  // Dodajte ovaj uvoz

class ChatAutoservisKlijentScreen extends StatefulWidget {
  final int klijentId;
  final int autoservisId;

  const ChatAutoservisKlijentScreen({
    super.key,
    required this.klijentId,
    required this.autoservisId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatAutoservisKlijentScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<chatAutoservisKlijent> messages = List.empty(growable: true);

  late ChatAutoservisKlijentProvider chatAutoservisKlijentProvider;
  late HubConnection connection;

      late bool isConnected = false;

  @override
  void initState() {
    super.initState();
    chatAutoservisKlijentProvider = context.read<ChatAutoservisKlijentProvider>();
    print("Initializing ChatAutoservisKlijentScreen...");
    GetMessages();
    runSignalR();
  }

  Future<void> runSignalR() async {
    print("Setting up SignalR connection...");
    connection = HubConnectionBuilder()
        .withUrl('http://localhost:7209/chatAutoservisKlijent')
        .build();

  // Definicija ponašanja kada se konekcija prekine
  connection.onclose(({Exception? error}) {
    print("SignalR connection closed: ${error?.toString() ?? 'No error'}");
    setState(() {
      isConnected = false;
    });
  });

    // Postavljanje liste koja prima poruke
    connection.on('ReceiveMessage', (arguments) {
      print("Received message through SignalR...");
      if (arguments != null && arguments.isNotEmpty && arguments[0] is Map<String, dynamic>) {
        var chatMessage = chatAutoservisKlijent.fromJson(arguments[0] as Map<String, dynamic>);
        setState(() {
          messages.add(chatMessage);
        });
        print("New message added: ${chatMessage.poruka}");
      } else {
        print("SignalR received invalid or empty message data.");
      }
    });

    // Povezivanje na SignalR hub
    try {
      await connection.start();
        setState(() {
      isConnected = true; // Handle connection failure
    });
          setState(() {
      isConnected = true; // SignalR connection successful
    });
      print("SignalR connection started successfully.");
    } catch (e) {
      print("Error starting SignalR connection: $e");
        setState(() {
      isConnected = false; // Handle connection failure
    });
    }
  }

  Future<void> GetMessages() async {
    print("Fetching messages from API...");
    if (mounted) {
      try {
        var response = await chatAutoservisKlijentProvider.getMessages(
            widget.klijentId, widget.autoservisId);
        setState(() {
          messages = response;
        });
        print("Messages fetched successfully. Total messages: ${messages.length}");
      } catch (e) {
        print("Error fetching messages: $e");
      }
    }
  }

  @override
  void dispose() {
    print("Disposing ChatAutoservisKlijentScreen...");
    _messageController.dispose();
    connection.stop().then((_) {
      print("SignalR connection stopped successfully.");
    }).catchError((e) {
      print("Error stopping SignalR connection: $e");
    });
    super.dispose();
  }

  // Slanje poruke
  Future<void> sendMessage(int klijentId, int autoservisId, String poruka, bool poslanoOdKlijenta) async {
    try {
      if (isConnected) {
        // Poslati poruku putem SignalR-a
        await connection.invoke('SendMessage', args: [klijentId, autoservisId, poruka, poslanoOdKlijenta]);

        // Također, poslati poruku na backend API za snimanje u bazu
        await _sendMessageToBackend(klijentId, autoservisId, poruka, poslanoOdKlijenta);

      // Ponovo učitaj poruke nakon slanja nove poruke
      GetMessages();
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Funkcija za slanje poruke na backend
  Future<void> _sendMessageToBackend(int klijentId, int autoservisId, String poruka, bool poslanoOdKlijenta) async {
    final url = Uri.parse('http://localhost:7209/api/ChatAutoservisKlijent/posalji?klijentId=$klijentId&poruka=$poruka');
    final headers = chatAutoservisKlijentProvider.createHeaders();

    try {
      //final response = await http.post(url, headers: headers);
      final response = await http.post(url,headers: headers);

      if (response.statusCode != 200) {
  print('Backend response: ${response.body}');
  throw Exception('Failed to send message to backend');
}

    } catch (e) {
      print('Error sending message to backend: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    // Access userProvider here
    Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat between Klijent ${widget.klijentId} and Autoservis ${widget.autoservisId}"),
      ),
      body: Column(
        children: [
        // Message List
Expanded(
  child: Consumer<ChatAutoservisKlijentProvider>(
    builder: (context, chatProvider, child) {
      // Show a loading indicator if messages are not yet loaded
      if (messages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(messages[index].poruka ?? 'No message'),
          );
        },
      );
    },
  ),
),


          // Message Input Field
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
                    if (message.isNotEmpty) {

                      // Send the message via SignalR and backend API
                      sendMessage(widget.klijentId, widget.autoservisId , message, true);

                      // Clear the message input
                      _messageController.clear();

                      Provider.of<ChatAutoservisKlijentProvider>(context, listen: false)
                          .getMessages(widget.klijentId, widget.autoservisId );                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
