# In the Pocket
Thank you for using In the Pocket.  This application is designed to make sure your gigs go smoothly.

## What this application does
This application can store the setlist for your musical gigs, and includes the ability to program a click track for each track.

### Spotify Integration
Grab songs for your setlists from any of your Spotify playlists.  As songs are pulled in, Spotify's metadata will automatically generate a click track for your song.

### Click Track
The click track is auto-generated using Spotify song metadata, or can be manually entered (or altered).  For songs with time signature or tempo changes, you can simply add a duration to each click track and create multiple.

The click track creates a .wav file that plays like a normal media file on your device.  This way you can minimize or leave the app and still hear the click.

While the app is open, you can also see visual indicators of the click on the count, and the device will vibrate on each count.

## What this application does not do
This app is not a conventional metronome, so does not have a standalone metronome with tap tempo support or anything like that.

Since the app builds a wav file for each tempo, the timing for the audio feedback is designed to be immune to any latency issues that could cause playing back individual samples to fail, lag, or otherwise result in bad timing.

The metronome in this app is programmed specifically for each track, so you will need to know, or figure out your track's BPM and time signature, or use the values supplied by Spotify's metadata (for tracks that are imported).

## Privacy Policy

Please read my privacy policy, posted [here](privacy.md).  Simply stated, I do not, and do not want to, track any personal user information, and with that being the case, there is no server-side component to this application.

## Support

Please see my [support page](support.md).  Basically for problems, please enter an issue into the github [issue tracker](https://github.com/timkellypa/inthepocket-flutter/issues).