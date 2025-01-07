import Foundation
import RealmSwift
import Logging

actor ConversationProcessor {
    static let shared = ConversationProcessor()
    
    private let logger: Logger
    private let realm: Realm
    private var currentConversation: Conversation?
    private var batchQueue: [ConversationSegment] = []
    private let maxBatchSize = 15
    private let llmThrottler: LLMThrottler
    
    private init() {
        self.logger = Logger(label: "com.audioime.processor")
        self.realm = try! Realm()
        self.llmThrottler = LLMThrottler(maxCallsPerMinute: 2)
    }
    
    func process(_ segments: [ConversationSegment]) async {
        batchQueue.append(contentsOf: segments)
        
        if batchQueue.count >= maxBatchSize {
            await processBatch()
        }
    }
    
    private func processBatch() async {
        guard !batchQueue.isEmpty else { return }
        
        let batch = batchQueue
        batchQueue.removeAll()
        
        // Local processing first
        let processedSegments = await localPreprocess(batch)
        
        // Only use LLM if necessary
        if await shouldUseLLM(for: processedSegments) {
            await llmThrottler.throttle {
                await processWithLLM(processedSegments)
            }
        }
        
        // Store results
        await storeBatch(processedSegments)
    }
    
    private func localPreprocess(_ segments: [ConversationSegment]) async -> [ConversationSegment] {
        // Implement local preprocessing logic
        // - Remove filler words
        // - Merge similar segments
        // - Basic topic detection
        return segments
    }
    
    private func shouldUseLLM(for segments: [ConversationSegment]) async -> Bool {
        // Implement logic to determine if LLM is needed
        // - Check confidence scores
        // - Look for action items
        // - Check topic changes
        return false // Default to false to minimize LLM usage
    }
    
    private func processWithLLM(_ segments: [ConversationSegment]) async {
        // Implement LLM processing
        // - Summarization
        // - Action item extraction
        // - Topic classification
    }
    
    private func storeBatch(_ segments: [ConversationSegment]) async {
        try! realm.write {
            realm.add(segments, update: .modified)
        }
    }
}

// MARK: - LLM Throttling
actor LLMThrottler {
    private var lastCallTimes: [Date] = []
    private let maxCallsPerMinute: Int
    
    init(maxCallsPerMinute: Int) {
        self.maxCallsPerMinute = maxCallsPerMinute
    }
    
    func throttle(action: () async -> Void) async {
        let now = Date()
        lastCallTimes = lastCallTimes.filter { now.timeIntervalSince($0) < 60 }
        
        if lastCallTimes.count < maxCallsPerMinute {
            lastCallTimes.append(now)
            await action()
        } else {
            // Wait until we can make another call
            let oldestCall = lastCallTimes[0]
            let waitTime = 60 - now.timeIntervalSince(oldestCall)
            if waitTime > 0 {
                try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
                await throttle(action: action)
            }
        }
    }
}
