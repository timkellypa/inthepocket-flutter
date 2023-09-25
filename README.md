# In The Pocket

Setlist organizer with Spotify integration.  Specialized for drummers, this includes a metronome for each track, supporting multiple time signatures and tempos.

## Issues / Feature Requests

For issues and feature requests, please submit them, [here](https://github.com/timkellypa/inthepocket-flutter/issues).

## Contributing

To contribute to this project, please submit a pull request.

### Building/Testing locally

Everything is essentially the same as a normal flutter application, but here are some things you may need to know if you would like to contribute.

#### Database updates

If you update models in setlistdb.dart, you need to run the following to update setlistdb.g.dart:

```flutter pub run build_runner build --delete-conflicting-outputs```

#### Secrets

If you are locally testing spotify integration, you need to create an api_secrets.json file.  This should contain JSON in the following format:

```
{
    "spotify_client_id": "{Your Spotify Client ID here}"
}
```

To get a spotify API client ID, please go to the Spotify Developer Dashboard, and create an app:  https://developer.spotify.com/dashboard