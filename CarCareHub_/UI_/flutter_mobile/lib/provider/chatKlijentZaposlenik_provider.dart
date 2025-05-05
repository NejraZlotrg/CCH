import 'dart:convert';
import 'package:flutter_mobile/models/chatKlijentZaposlenik.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_mobile/provider/base_provider.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class ChatKlijentZaposlenikProvider
    extends BaseProvider<chatKlijentZaposlenik> {
  ChatKlijentZaposlenikProvider() : super("/api/chatKlijentZaposlenik");

  @override
  chatKlijentZaposlenik fromJson(data) {
    return chatKlijentZaposlenik.fromJson(data);
  }

  late HubConnection connection;
  late bool isConnected = false;

  String getSignalRUrl(String path) {
    return buildUrl(path);
  }

  // Dohvatiti poruke između klijenta i zaposleik-a sa backend-a
  Future<List<chatKlijentZaposlenik>> getMessages(
      int klijentId, int zaposlenikId) async {
    try {
      final url = Uri.parse(buildUrl("/$klijentId/$zaposlenikId"));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = jsonDecode(response.body);
        return messagesData
            .map((msg) => chatKlijentZaposlenik.fromJson(msg))
            .toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Slanje poruke između klijenta i zaposlenika
  Future<void> sendMessage(
      int klijentId, int zaposlenikId, String message) async {
    try {
      final url = Uri.parse(buildUrl("/posalji"));
      final response = await http.post(
        url,
        headers: createHeaders(),
        body: jsonEncode({
          'klijentId': klijentId,
          'zaposlenikId': zaposlenikId,
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
  Future<List<chatKlijentZaposlenik>> getById__(int userId) async {
    final url = Uri.parse(buildUrl("/byLoggedUser?klijent_id=$userId"));
    final headers = createHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((e) => chatKlijentZaposlenik.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load chats: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
