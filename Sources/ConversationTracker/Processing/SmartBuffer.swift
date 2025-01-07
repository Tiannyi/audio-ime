import Foundation
import AudioIMECore
import Collections
import AsyncAlgorithms
import Logging

actor SmartBuffer {
    private var buffer: Deque<ConversationSegment>
    private let maxBufferSize: Int
    private let logger: Logger
    private var currentSilenceDuration: TimeInterval = 0
    private let silenceThreshold: TimeInterval = 2.0
    
    init(maxBufferSize: Int = 50) {
        self.maxBufferSize = maxBufferSize
        self.buffer = Deque()
        self.logger = Logger(label: "com.audioime.smartbuffer")
    }
    
    func add(_ segment: ConversationSegment) async {
        buffer.append(segment)
        
        if buffer.count > maxBufferSize {
            await flushIfNeeded()
        }
    }
    
    func updateSilence(duration: TimeInterval) async {
        currentSilenceDuration = duration
        if currentSilenceDuration >= silenceThreshold {
            await flushIfNeeded()
        }
    }
    
    private func flushIfNeeded() async {
        guard !buffer.isEmpty else { return }
        
        // Group segments by potential topics or speakers
        let segments = Array(buffer)
        buffer.removeAll()
        
        // Notify processor
        await ConversationProcessor.shared.process(segments)
    }
    
    func clear() {
        buffer.removeAll()
        currentSilenceDuration = 0
    }
}
