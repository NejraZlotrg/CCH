class RezultatPlacanja {
  late String id;
  late String clientSecret;

  RezultatPlacanja({required this.id, required this.clientSecret});

  factory RezultatPlacanja.fromJson(Map<String, dynamic> json) {
    return RezultatPlacanja(
      id: json['id'], // Ensure this matches the JSON response
      clientSecret:
          json['clientSecret'], // Ensure this matches the JSON response
    );
  }
}
