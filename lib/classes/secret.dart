class Secret {
  Secret({required this.spotifyClientId});
  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return Secret(spotifyClientId: jsonMap['spotify_client_id']);
  }

  final String spotifyClientId;
}
