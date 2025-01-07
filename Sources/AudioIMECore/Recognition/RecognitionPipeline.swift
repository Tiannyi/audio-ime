import Foundation

public class RecognitionPipeline {
    private let audioCapture: AudioCaptureSystem
    private let primaryEngine: SpeechRecognitionEngine
    private let fallbackEngine: SpeechRecognitionEngine
    private let llmProcessor: LLMProcessor
    private let settings: PipelineSettings
    
    public struct PipelineSettings {
        let useNeuralEngine: Bool
        let minimumConfidence: Float
        let powerEfficiencyMode: Bool
        
        public init(
            useNeuralEngine: Bool = true,
            minimumConfidence: Float = 0.8,
            powerEfficiencyMode: Bool = true
        ) {
            self.useNeuralEngine = useNeuralEngine
            self.minimumConfidence = minimumConfidence
            self.powerEfficiencyMode = powerEfficiencyMode
        }
    }
    
    public init(
        audioCapture: AudioCaptureSystem,
        primaryEngine: SpeechRecognitionEngine,
        fallbackEngine: SpeechRecognitionEngine,
        llmProcessor: LLMProcessor,
        settings: PipelineSettings = PipelineSettings()
    ) {
        self.audioCapture = audioCapture
        self.primaryEngine = primaryEngine
        self.fallbackEngine = fallbackEngine
        self.llmProcessor = llmProcessor
        self.settings = settings
    }
    
    public func startRecognition() async throws {
        // Start audio capture
        try await audioCapture.startCapture()
        
        // Select and start appropriate recognition engine
        let engine = selectOptimalEngine()
        try await engine.startRecognition()
    }
    
    public func stopRecognition() async {
        await audioCapture.stopCapture()
        await primaryEngine.stopRecognition()
        await fallbackEngine.stopRecognition()
    }
    
    private func selectOptimalEngine() -> SpeechRecognitionEngine {
        if settings.useNeuralEngine && 
           primaryEngine.supportsNeuralEngine && 
           primaryEngine.isAvailable {
            return primaryEngine
        }
        return fallbackEngine
    }
    
    public func processRecognitionResult(_ result: RecognitionResult) async throws -> String {
        // Check if LLM processing is needed
        if llmProcessor.shouldProcess(result.text, confidence: result.confidence, context: LLMContext()) {
            let llmResult = try await llmProcessor.processText(
                result.text,
                confidence: result.confidence,
                context: LLMContext()
            )
            return llmResult.correctedText
        }
        
        return result.text
    }
}
