import Foundation
import Combine
import AVFoundation

@MainActor
final class AudioPlayerVM: ObservableObject {
    struct Track {
        let title: String
        let resourceName: String
        let fileExtension: String
    }

    let tracks: [Track] = [
        .init(title: "Song One", resourceName: "song1", fileExtension: "mp3"),
        .init(title: "Song Two", resourceName: "song2", fileExtension: "mp3")
    ]

    @Published private(set) var index: Int = 0
    @Published private(set) var isPlaying: Bool = false

    @Published var volume: Float = 0.7 {
        didSet { playerNode.volume = max(0, min(volume, 1)) }
    }

    @Published private(set) var duration: TimeInterval = 0
    @Published var currentTime: TimeInterval = 0

    @Published var reverbMix: Double = 0.20 { didSet { applyFX() } }
    @Published var distortionMix: Double = 0.00 { didSet { applyFX() } }   

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let reverbUnit = AVAudioUnitReverb()
    private let distortionUnit = AVAudioUnitDistortion()

    private var audioFile: AVAudioFile?
    private var sampleRate: Double = 44100
    private var totalFrames: AVAudioFramePosition = 0
    private var startFrame: AVAudioFramePosition = 0

    private var timer: Timer?
    private var isSeeking = false

    init() {
        configureAudioSession()
        configureEngineGraph()
        load(0)
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("AudioSession error:", error)
        }
    }

    private func configureEngineGraph() {
        engine.attach(playerNode)
        engine.attach(reverbUnit)
        engine.attach(distortionUnit)

        engine.connect(playerNode, to: reverbUnit, format: nil)
        engine.connect(reverbUnit, to: distortionUnit, format: nil)
        engine.connect(distortionUnit, to: engine.mainMixerNode, format: nil)

        playerNode.volume = max(0, min(volume, 1))
        applyFX()

        engine.prepare()
        do {
            try engine.start()
        } catch {
            print("Engine start error:", error)
        }
    }

    private func applyFX() {
        reverbUnit.loadFactoryPreset(.mediumHall)
        reverbUnit.wetDryMix = Float(max(0, min(reverbMix, 1)) * 100)

        distortionUnit.loadFactoryPreset(.multiDistortedCubed)
        distortionUnit.preGain = 6
        distortionUnit.wetDryMix = Float(max(0, min(distortionMix, 1)) * 100)
    }

    func load(_ i: Int) {
        stopTimer()
        stopPlaybackInternal(resetTime: false)

        index = (i + tracks.count) % tracks.count
        let t = tracks[index]

        guard let url = Bundle.main.url(forResource: t.resourceName, withExtension: t.fileExtension) else {
            print("Missing file:", "\(t.resourceName).\(t.fileExtension)")
            audioFile = nil
            duration = 0
            currentTime = 0
            isPlaying = false
            return
        }

        do {
            let file = try AVAudioFile(forReading: url)
            audioFile = file
            sampleRate = file.processingFormat.sampleRate
            totalFrames = file.length

            duration = (sampleRate > 0) ? Double(totalFrames) / sampleRate : 0
            currentTime = 0
            startFrame = 0
            isPlaying = false

            scheduleFromFrame(0)
        } catch {
            print("AVAudioFile error:", error)
            audioFile = nil
            duration = 0
            currentTime = 0
            isPlaying = false
        }
    }

    private func scheduleFromFrame(_ frame: AVAudioFramePosition) {
        guard let file = audioFile else { return }

        playerNode.stop()

        let clampedStart = max(0, min(frame, totalFrames))
        startFrame = clampedStart
        let remaining = max(0, totalFrames - clampedStart)
        guard remaining > 0 else { return }

        playerNode.scheduleSegment(
            file,
            startingFrame: clampedStart,
            frameCount: AVAudioFrameCount(remaining),
            at: nil,
            completionCallbackType: .dataPlayedBack
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handlePlaybackEndedIfNeeded()
            }
        }
    }

    private func handlePlaybackEndedIfNeeded() {
        guard isPlaying, !isSeeking else { return }
        if duration > 0, currentTime >= duration - 0.05 {
            next()
        }
    }

    func playPause() {
        guard audioFile != nil else { return }

        if isPlaying {
            playerNode.pause()
            isPlaying = false
            stopTimer()
            return
        }

        if !engine.isRunning {
            do { try engine.start() }
            catch { print("Engine restart error:", error) }
        }

        scheduleFromFrame(timeToFrame(currentTime))
        playerNode.play()
        isPlaying = true
        startTimer()
    }

    func next() {
        let wasPlaying = isPlaying
        load(index + 1)
        if wasPlaying { playPause() }
    }

    func prev() {
        if currentTime > 3 {
            seek(to: 0)
            return
        }
        let wasPlaying = isPlaying
        load(index - 1)
        if wasPlaying { playPause() }
    }

    func seek(to time: TimeInterval) {
        guard audioFile != nil else { return }
        let clamped = max(0, min(time, duration))

        isSeeking = true
        currentTime = clamped

        scheduleFromFrame(timeToFrame(clamped))
        if isPlaying {
            playerNode.play()
        }
        isSeeking = false
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.updateCurrentTimeFromNode()
            }
        }
    }

    private func updateCurrentTimeFromNode() {
        guard isPlaying, !isSeeking else { return }
        guard let nodeTime = playerNode.lastRenderTime,
              let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else {
            return
        }

        let played = AVAudioFramePosition(playerTime.sampleTime)
        let frame = startFrame + played
        let t = (sampleRate > 0) ? (Double(frame) / sampleRate) : 0
        currentTime = max(0, min(t, duration))
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func stopPlaybackInternal(resetTime: Bool) {
        playerNode.stop()
        isPlaying = false
        isSeeking = false
        if resetTime {
            currentTime = 0
            startFrame = 0
        }
    }

    private func timeToFrame(_ t: TimeInterval) -> AVAudioFramePosition {
        guard sampleRate > 0 else { return 0 }
        let f = AVAudioFramePosition(t * sampleRate)
        return max(0, min(f, totalFrames))
    }
}
