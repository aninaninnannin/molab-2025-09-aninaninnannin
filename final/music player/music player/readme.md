Cyberpunk Droplet Music Player

A SwiftUI music player with a neon yellow/purple cyberpunk theme, droplet-style controls (Volume / Reverb / Distortion), a wave seek bar, and a procedural background sweep.

How to Run
    1.    Open in Xcode → Build & Run.
    2.    Add audio files to the app target (Target Membership checked).
    3.    In AudioPlayerVM, match your filenames (e.g., song1.mp3 → resourceName: "song1", fileExtension: "mp3").

Notes
    •    UI is state-driven via @StateObject + @Published ViewModel properties.
    •    Audio uses AVAudioEngine with an FX chain (player → reverb → distortion).

References / Sources
Apple Developer Documentation — SwiftUI
    •    Apple Developer Documentation — Canvas (SwiftUI)
    •    Apple Developer Documentation — TimelineView (SwiftUI)
    •    Apple Developer Documentation — AVAudioEngine
    •    Apple Developer Documentation — AVAudioUnitReverb
    •    Apple Developer Documentation — AVAudioUnitDistortion
    •    Apple Developer Documentation — AVAudioSession
    •    Apple SF Symbols — icons used in UI
    •    Visual inspiration — Cyberpunk: Edgerunners (Studio Trigger, 2022) (visual reference only)
    •    chatgpt
