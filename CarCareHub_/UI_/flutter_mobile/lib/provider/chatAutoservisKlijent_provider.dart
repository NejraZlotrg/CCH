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
