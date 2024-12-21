import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:flutter_mobile/provider/UserProvider.dart';
import 'package:flutter_mobile/provider/chatAutoservisKlijent_provider.dart';
import 'package:provider/provider.dart';

class ChatAutoservisKlijentScreen extends StatefulWidget {
  final int klijentId;
  final int autoservisId;
  

  const ChatAutoservisKlijentScreen({Key? key, required this.klijentId, required this.autoservisId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatAutoservisKlijentScreen> {
  TextEditingController _messageController = TextEditingController();


List<chatAutoservisKlijent> messages= List.empty();

late ChatAutoservisKlijentProvider chatAutoservisKlijentProvider;

  @override
  void initState() {
    super.initState();
    chatAutoservisKlijentProvider = context.read<ChatAutoservisKlijentProvider>();
    GetMessages();
    // Initialize SignalR connection and fetch messages
    // Future.microtask(() {
    //   // Initialize SignalR connection
    //   Provider.of<ChatAutoservisKlijentProvider>(context, listen: false)
    //       //.initSignalR()
    //       .then((_) {
    //     // Fetch messages after the connection is initialized
    //     Provider.of<ChatAutoservisKlijentProvider>(context, listen: false)
    //         .getMessages(widget.klijentId, widget.autoservisId);
    //   });
    // });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future GetMessages() async{
    if(mounted){
      var response = await chatAutoservisKlijentProvider.getMessages(2, 2);

      setState((){
        messages = response;
      });
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
        return Center(child: CircularProgressIndicator());
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
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text;
                    if (message.isNotEmpty) {

                      // Send the message via SignalR and backend API
                      Provider.of<ChatAutoservisKlijentProvider>(context, listen: false)
                          .sendMessage(widget.klijentId, widget.autoservisId , message, true);

                      // Clear the message input
                      _messageController.clear();
                    }
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
