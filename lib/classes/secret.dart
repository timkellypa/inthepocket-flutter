class Secret {
  Secret({this.spotifyClientId = '', this.spotifyClientSecret});
  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return Secret(
      spotifyClientId: jsonMap['spotify_client_id'],
      spotifyClientSecret: jsonMap['spotify_client_secret'],
    );
  }

  final String spotifyClientId;
  final String spotifyClientSecret;
}
