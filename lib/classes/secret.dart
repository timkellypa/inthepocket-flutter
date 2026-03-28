class Secret {
  Secret({required this.spotifyClientId, required this.getSongBpmApiKey});
  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return Secret(
        spotifyClientId: jsonMap['spotify_client_id'],
        getSongBpmApiKey: jsonMap['getsongbpm_api_key']);
  }
  final String getSongBpmApiKey;
  final String spotifyClientId;
}
