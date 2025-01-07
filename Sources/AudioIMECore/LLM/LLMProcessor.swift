import Foundation

public protocol LLMProcessor {
    var isAvailable: Bool { get }
    
    func processText(_ text: String, confidence: Float, context: LLMContext) async throws -> LLMResult
    func shouldProcess(_ text: String, confidence: Float, context: LLMContext) -> Bool
}

public struct LLMContext {
    public let previousText: String
    public let languageCode: String
    public let domain: String?
    public let timestamp: Date
    
    public init(
        previousText: String = "",
        languageCode: String = "en-US",
        domain: String? = nil,
        timestamp: Date = Date()
    ) {
        self.previousText = previousText
        self.languageCode = languageCode
        self.domain = domain
        self.timestamp = timestamp
    }
}

public struct LLMResult {
    public let originalText: String
    public let correctedText: String
    public let confidence: Float
    public let corrections: [TextCorrection]
    public let metadata: [String: Any]
    
    public init(
        originalText: String,
        correctedText: String,
        confidence: Float,
        corrections: [TextCorrection] = [],
        metadata: [String: Any] = [:]
    ) {
        self.originalText = originalText
        self.correctedText = correctedText
        self.confidence = confidence
        self.corrections = corrections
        self.metadata = metadata
    }
}

public struct TextCorrection {
    public let range: Range<String.Index>
    public let originalText: String
    public let correctedText: String
    public let type: CorrectionType
    
    public enum CorrectionType {
        case grammar
        case spelling
        case punctuation
        case context
        case other
    }
}
