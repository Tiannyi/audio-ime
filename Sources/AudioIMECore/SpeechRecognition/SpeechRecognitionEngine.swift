import Foundation

public protocol SpeechRecognitionEngine {
    var isAvailable: Bool { get }
    var supportsNeuralEngine: Bool { get }
    
    func startRecognition() async throws
    func stopRecognition() async
    func getRecognitionResult() async -> RecognitionResult
}

public struct RecognitionResult {
    public let text: String
    public let confidence: Float
    public let timestamp: Date
    public let metadata: [String: Any]
    
    public init(text: String, confidence: Float, timestamp: Date = Date(), metadata: [String: Any] = [:]) {
        self.text = text
        self.confidence = confidence
        self.timestamp = timestamp
        self.metadata = metadata
    }
}
