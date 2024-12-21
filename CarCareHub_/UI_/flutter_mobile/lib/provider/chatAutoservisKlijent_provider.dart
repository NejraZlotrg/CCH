import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/chatAutoservisKlijent.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter_mobile/provider/base_provider.dart';


class ChatAutoservisKlijentProvider extends BaseProvider<chatAutoservisKlijent> {
  ChatAutoservisKlijentProvider(): super("api/chatAutoservisKlijent");

  @override
  chatAutoservisKlijent fromJson(data) {
    // TODO: implement fromJson
    return chatAutoservisKlijent.fromJson(data);
  }
  // Inicijalizacija SignalR konekcije
  // Future<void> initSignalR() async {
  //   _hubConnection = HubConnectionBuilder()
  //       .withUrl('http://localhost:7209/chatAutoservisKlijent') // URL SignalR hub-a
  //       .build();

  //   _hubConnection?.onclose(({Exception? error}) {
  //     isConnected = false;
  //     notifyListeners();
  //   });

//     // Primanje poruka
// _hubConnection?.on('ReceiveMessage', (message) {
//   if (message != null && message.isNotEmpty && message[0] is Map<String, dynamic>) {
//     var chatMessage = chatAutoservisKlijent.fromJson(message[0] as Map<String, dynamic>);
//     _messages.add(chatMessage);
//     notifyListeners();
//   }
// });

  //   // Povezivanje na SignalR hub
  //   try {
  //     await _hubConnection?.start();
  //     isConnected = true;
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error starting SignalR connection: $e');
  //   }
  // }

  // Slanje poruke
  Future<void> sendMessage(int klijentId, int autoservisId, String poruka, bool poslanoOdKlijenta) async {
    try {
     // if (isConnected) {
        // Poslati poruku putem SignalR-a
       // await _hubConnection?.invoke('SendMessage', args: [klijentId, autoservisId, poruka, poslanoOdKlijenta]);

        // Također, poslati poruku na backend API za snimanje u bazu
        await _sendMessageToBackend(klijentId, autoservisId, poruka, poslanoOdKlijenta);
      //}
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Funkcija za slanje poruke na backend
  Future<void> _sendMessageToBackend(int klijentId, int autoservisId, String poruka, bool poslanoOdKlijenta) async {
    final url = Uri.parse('http://localhost:7209/api/ChatAutoservisKlijent/posalji?klijentId=$klijentId&poruka=$poruka');
    final headers = createHeaders();

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

  // Dohvatiti poruke između klijenta i autoservis-a sa backend-a
  Future<dynamic> getMessages(int klijentId, int autoservisId) async {
    try {
      final url = Uri.parse('http://localhost:7209/api/chatAutoservisKlijent/$klijentId/$autoservisId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
  final List<dynamic> messagesData = jsonDecode(response.body);
  return messagesData.map((msg) => chatAutoservisKlijent.fromJson(msg)).toList();
} else {
  print('Error fetching messages: ${response.statusCode}, Body: ${response.body}');
  throw Exception('Failed to load messages');
}
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }
}
