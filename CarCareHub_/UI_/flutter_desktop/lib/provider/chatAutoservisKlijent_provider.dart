import 'dart:convert';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class ChatAutoservisKlijentProvider extends BaseProvider<chatAutoservisKlijent> {
  ChatAutoservisKlijentProvider() : super("api/chatAutoservisKlijent");

  @override
  chatAutoservisKlijent fromJson(data) {
    return chatAutoservisKlijent.fromJson(data);
  }
  
  late HubConnection connection;
  late bool isConnected = false;

  // Ovo je metoda koja pokreće SignalR konekciju i osluškuje poruke
  Future<void> runSignalR(Function onMessageReceived) async {
    connection = HubConnectionBuilder()
        .withUrl('http://localhost:7209/chatAutoservisKlijent')
        .build();

    connection.onclose(({Exception? error}) {
      print('Connection closed: $error');
      isConnected = false;
    });

    // Kad stigne nova poruka, poziva onMessageReceived funkciju (callback)
    connection.on('ReceiveMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        if (arguments[0] != null) {
          try {
            var chatMessage = chatAutoservisKlijent
                .fromJson(arguments[0] as Map<String, dynamic>);
            onMessageReceived(chatMessage); // Prosleđujemo poruku u ekran
          } catch (e) {
            print("Error parsing message from SignalR: $e");
          }
        }
      }
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



  // Dohvatiti poruke između klijenta i autoservis-a sa backend-a
  Future<List<chatAutoservisKlijent>> getMessages(int klijentId, int autoservisId) async {
    try {
      final url = Uri.parse(buildUrl("/$klijentId/$autoservisId"));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = jsonDecode(response.body);
        return messagesData
            .map((msg) => chatAutoservisKlijent.fromJson(msg))
            .toList();
      } else {
        print('Error fetching messages: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      rethrow;
    }
  }

  // Slanje poruke između klijenta i autoservis-a
  Future<void> sendMessage(int klijentId, int autoservisId, String message) async {
    try {
      final url = Uri.parse(buildUrl("/posalji"));
      final response = await http.post(
        url,
        headers: createHeaders(),
        body: jsonEncode({
          'klijentId': klijentId,
          'autoservisId': autoservisId,
          'poruka': message,
        }),
      );

      if (response.statusCode == 200) {
        print('Message sent successfully');
      } else {
        print('Error sending message: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Implementing getById method
  Future<List<chatAutoservisKlijent>> getById__(int userId) async {
    final url = Uri.parse(buildUrl("/byLoggedUser?klijent_id=$userId"));
    final headers = createHeaders();

    try {
      final response = await http.get(url, headers: headers);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((e) => chatAutoservisKlijent.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load chats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chats: $e');
      rethrow;
    }
  }
}