import Foundation
import AVFoundation
import Combine

public enum AudioMode {
    case passive  // Always listening, storing locally
    case active   // IME input mode
}

public class AudioManager: NSObject {
    public static let shared = AudioManager()
    
    private let audioEngine = AVAudioEngine()
    private let inputNode: AVAudioInputNode
    private let hardwareTrigger = HardwareTrigger.shared
    private var mode: AudioMode = .passive
    private var cancellables = Set<AnyCancellable>()
    
    // Buffer management
    private let passiveBuffer = SmartBuffer(maxBufferSize: 100)  // Larger buffer for background
    private let activeBuffer = SmartBuffer(maxBufferSize: 20)    // Smaller buffer for IME
    
    public override init() {
        self.inputNode = audioEngine.inputNode
        super.init()
        setupAudio()
        setupTriggerObserver()
    }
    
    private func setupAudio() {
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            self?.processAudioBuffer(buffer, time: time)
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func setupTriggerObserver() {
        hardwareTrigger.statePublisher()
            .sink { [weak self] state in
                self?.handleTriggerState(state)
            }
            .store(in: &cancellables)
    }
    
    private func handleTriggerState(_ state: TriggerState) {
        switch state {
        case .active:
            switchToActiveMode()
        case .inactive:
            switchToPassiveMode()
        }
    }
    
    private func switchToActiveMode() {
        mode = .active
        // Clear active buffer for new input
        activeBuffer.clear()
    }
    
    private func switchToPassiveMode() {
        mode = .passive
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        // Convert buffer to text using speech recognition
        let segment = ConversationSegment()
        // Process audio to text...
        
        Task {
            switch mode {
            case .passive:
                await passiveBuffer.add(segment)
            case .active:
                await activeBuffer.add(segment)
                // Trigger IME update when segment is ready
                if let text = segment.text {
                    NotificationCenter.default.post(
                        name: .imeTextReady,
                        object: nil,
                        userInfo: ["text": text]
                    )
                }
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let imeTextReady = Notification.Name("imeTextReady")
}
