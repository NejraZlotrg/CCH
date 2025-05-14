// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class ChatAutoservisKlijentProvider
    extends BaseProvider<chatAutoservisKlijent> {
  ChatAutoservisKlijentProvider() : super("api/chatAutoservisKlijent");

  @override
  chatAutoservisKlijent fromJson(data) {
    return chatAutoservisKlijent.fromJson(data);
  }

  late HubConnection connection;
  late bool isConnected = false;

  Future<void> runSignalR(Function onMessageReceived) async {
    connection = HubConnectionBuilder()
        .withUrl(buildUrl('chatAutoservisKlijent'))
        .build();

    connection.onclose(({Exception? error}) {
      isConnected = false;
    });

    connection.on('ReceiveMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        if (arguments[0] != null) {
          try {
            var chatMessage = chatAutoservisKlijent
                .fromJson(arguments[0] as Map<String, dynamic>);
            onMessageReceived(chatMessage);
          } catch (e) {}
        }
      }
    });

    try {
      await connection.start();
      isConnected = true;
    } catch (e) {
      isConnected = false;
    }
  }

  Future<List<chatAutoservisKlijent>> getMessages(
      int klijentId, int autoservisId) async {
    try {
      final url = Uri.parse(buildUrl("/$klijentId/$autoservisId"));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = jsonDecode(response.body);
        return messagesData
            .map((msg) => chatAutoservisKlijent.fromJson(msg))
            .toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendMessage(
      int klijentId, int autoservisId, String message) async {
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
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ignore: non_constant_identifier_names
  Future<List<chatAutoservisKlijent>> getById__(int userId) async {
    final url = Uri.parse(buildUrl("/byLoggedUser?klijent_id=$userId"));
    final headers = createHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((e) => chatAutoservisKlijent.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load chats: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
