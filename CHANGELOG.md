## 2.0.3
- Add a standalone metronome
  - Add standalone metronome with wheel spinner for tempo and tap tempo support.
  - Make a route/button for standalone metronome from home screen.
  - Update tempo editor to use new metronome.
  - Refactor some common utilities in both standalone and track based metronomes.
- Add rich text editor for track notes.
- Add track duration information.
   - Create header for track list with duration information (total duration, remaining duration).
   - Add a play button that will expand this to tell you expected end time of the set, as well as time elapsed.
- UI changes/fixes.
  - Use draggable bottom panel to allow user to access track metronome and expand notes.
  - "Auto Scroll to Item" feature allows user to advance track using bluetooth device or media controls, keeping selected track visible.
- Bug Fixes:
  - Remove "null" track title (and track title in general) above for track tempos list.
  - Add wait spinner when importing from other setlist.
  - Slightly increase metronome click duration.  Makes the bulb icons more visible, especially in dark mode.

## 2.0.2
- Bug Fixes:
  - Fix Spotify redirect URL.
- Update flutter/dart and many dependencies.
- Start storing/displaying artist name.
- Minor UI fixes around display of back/next, and metronome.
   - Metronome shows link to edit song if no tempos exist.
   - Back/next are disabled appropriately for first/last track.
- Detect dark mode on device and allow dark mode theme.
- Use getSongBPM for song BPM's and fix some UI around BPM importing.
- UI refresh, along with dark mode.

## 2.0.1
Bug Fixes:
- Fix bug where you cannot delete a setlist with tracks.
  - Delete tracks (cascade) first, with tempos, etc.

## 2.0.0
Initial published release (version 1.0 in App Store)