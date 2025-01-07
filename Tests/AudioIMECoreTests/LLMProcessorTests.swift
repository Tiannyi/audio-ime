import XCTest
@testable import AudioIMECore

final class LLMProcessorTests: XCTestCase {
    func testShouldProcessLowConfidence() throws {
        let processor = OptimizedLLMProcessor()
        let shouldProcess = processor.shouldProcess(
            "test text",
            confidence: 0.5,
            context: LLMContext()
        )
        XCTAssertTrue(shouldProcess, "Should process text with low confidence")
    }
    
    func testShouldNotProcessHighConfidence() throws {
        let processor = OptimizedLLMProcessor()
        let shouldProcess = processor.shouldProcess(
            "test text",
            confidence: 0.9,
            context: LLMContext()
        )
        XCTAssertFalse(shouldProcess, "Should not process text with high confidence")
    }
}
