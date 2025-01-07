import Foundation
import RealmSwift

// MARK: - Core Models
class ConversationSegment: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var text: String
    @Persisted var timestamp: Date
    @Persisted var confidence: Double
    @Persisted var speaker: String?
    @Persisted var processed: Bool = false
    @Persisted var parentConversation: Conversation?
}

class Conversation: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var title: String
    @Persisted var startTime: Date
    @Persisted var endTime: Date?
    @Persisted var segments: List<ConversationSegment>
    @Persisted var summary: String?
    @Persisted var actionItems: List<ActionItem>
    @Persisted var topics: List<Topic>
}

class ActionItem: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var text: String
    @Persisted var priority: Int
    @Persisted var dueDate: Date?
    @Persisted var completed: Bool = false
    @Persisted var assignee: String?
}

class Topic: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var name: String
    @Persisted var confidence: Double
    @Persisted var keywords: List<String>
}

// MARK: - Optimization Models
class ProcessingMetrics: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var timestamp: Date
    @Persisted var llmTokensUsed: Int
    @Persisted var processingTimeMs: Int
    @Persisted var segmentsProcessed: Int
}

class CacheEntry: Object {
    @Persisted(primaryKey: true) var key: String
    @Persisted var value: String
    @Persisted var timestamp: Date
    @Persisted var accessCount: Int
}
