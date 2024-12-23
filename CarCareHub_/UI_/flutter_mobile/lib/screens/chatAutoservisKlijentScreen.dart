import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/chatAutoservisKlijent_provider.dart';

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
    GetMessages();
    runSignalR();
  }

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
      if (arguments != null && arguments.isNotEmpty && arguments[0] is Map<String, dynamic>) {
        var chatMessage = chatAutoservisKlijent.fromJson(arguments[0] as Map<String, dynamic>);
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
    }
  }

  Future<void> GetMessages() async {
    try {
      var response = await chatAutoservisKlijentProvider.getMessages(widget.klijentId, widget.autoservisId);
      setState(() {
        messages = response;
      });
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    connection.stop();
    super.dispose();
  }

  Future<void> sendMessage(int klijentId, int autoservisId, String poruka, bool poslanoOdKlijenta) async {
    try {
      if (isConnected) {
        await connection.invoke('SendMessage', args: [klijentId, autoservisId, poruka, poslanoOdKlijenta]);
        await _sendMessageToBackend(klijentId, autoservisId, poruka, poslanoOdKlijenta);
        GetMessages();
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> _sendMessageToBackend(int klijentId, int autoservisId, String poruka, bool poslanoOdKlijenta) async {
    final url = Uri.parse(
      'http://localhost:7209/api/ChatAutoservisKlijent/posalji?klijentId=$klijentId&autoservisId=$autoservisId&poruka=$poruka',
    );

    final headers = chatAutoservisKlijentProvider.createHeaders();

    try {
      final response = await http.post(url, headers: headers);
      if (response.statusCode != 200) {
        throw Exception('Failed to send message to backend');
      }
    } catch (e) {
      print('Error sending message to backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat - Klijent ${widget.klijentId}"),
      ),
      body: Row(
        children: [
          // Left Panel: List of Chats
          Expanded(
            flex: 1, // 1/3 of the width
            child: Container(
              color: Colors.grey.shade200,
              child: ListView(
                children: List.generate(
                  10, // Example static list of chats
                  (index) => ListTile(
                    title: Text('Chat $index'),
                    onTap: () {
                      // Handle chat selection
                      print('Selected chat $index');
                    },
                  ),
                ),
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
                      ? const Center(child: CircularProgressIndicator())
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
                          if (message.isNotEmpty) {
                            sendMessage(widget.klijentId, widget.autoservisId, message, true);
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
