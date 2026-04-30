## 2.0.3
- Add a standalone metronome
  - Add standalone metronome with wheel spinner for tempo and tap tempo support.
  - Make a route/button for standalone metronome from home screen.
  - Update tempo editor to use new metronome.
  - Refactor some common utilities in both standalone and track based metronomes.
- Add rich text editor for track notes.
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