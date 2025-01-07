# Testing Guide for Audio IME

## Local Development Setup

1. **Prerequisites**
```bash
# Required tools
- Xcode 14.0+
- Swift 5.7+
- macOS 13.0+ or iOS 16.0+
```

2. **Build and Test**
```bash
# Clone the repository
git clone <repository-url>
cd project-audio-ime

# Build the project
swift build

# Run tests
swift test
```

3. **Running on macOS**

```bash
# Build the Input Method bundle
xcodebuild -scheme AudioIMEMacOS build

# Install the Input Method
sudo cp -r build/Debug/AudioIME.app /Library/Input\ Methods/

# Enable in System Settings
1. Open System Settings
2. Navigate to Keyboard > Input Sources
3. Click '+' and find "Audio IME"
4. Enable and grant permissions
```

4. **Running on iOS**
```bash
# Build the Keyboard Extension
xcodebuild -scheme AudioIMEiOS build

# Install via TestFlight or direct installation
1. Open project in Xcode
2. Select your device
3. Build and run
4. Enable keyboard in Settings
```

## Testing Components

### 1. Core Components Testing

```swift
// Test Audio Capture
func testAudioCapture() {
    let capture = AppleAudioCapture()
    XCTAssertTrue(capture.isAvailable)
    // Test audio session setup
    // Test buffer management
}

// Test Speech Recognition
func testSpeechRecognition() {
    let engine = AppleNeuralSpeechEngine()
    XCTAssertTrue(engine.supportsNeuralEngine)
    // Test recognition accuracy
    // Test language support
}

// Test LLM Processing
func testLLMProcessing() {
    let processor = OptimizedLLMProcessor()
    // Test confidence threshold
    // Test caching
    // Test batch processing
}
```

### 2. Integration Testing

```swift
// Test Complete Pipeline
func testRecognitionPipeline() {
    let pipeline = RecognitionPipeline(...)
    // Test end-to-end flow
    // Test error handling
    // Test performance
}
```

### 3. Performance Testing

```swift
// Test Neural Engine Performance
func testNeuralEnginePerformance() {
    measure {
        // Measure recognition speed
        // Measure accuracy
        // Measure resource usage
    }
}
```

## Debugging

1. **Enable Debug Logging**
```swift
AudioIME.enableDebugLogging()
```

2. **Monitor Performance**
```swift
AudioIME.startPerformanceMonitoring()
```

3. **Common Issues**
- Permission errors
- Audio session conflicts
- Neural Engine availability
- Memory management

## Continuous Integration

1. **GitHub Actions Workflow**
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build and Test
        run: swift test
```

## Release Testing Checklist

- [ ] All unit tests pass
- [ ] Integration tests pass
- [ ] Performance benchmarks meet targets
- [ ] Permissions handling verified
- [ ] Memory usage within limits
- [ ] Battery impact acceptable
- [ ] User interface responsive
- [ ] Error handling verified
