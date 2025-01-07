import Foundation

public protocol AudioCaptureSystem {
    var isAvailable: Bool { get }
    var sampleRate: Double { get }
    
    func startCapture() async throws
    func stopCapture() async
    func getAudioBuffer() -> AudioBuffer
}

public struct AudioBuffer {
    public let data: Data
    public let format: AudioFormat
    public let timestamp: Date
    
    public init(data: Data, format: AudioFormat, timestamp: Date = Date()) {
        self.data = data
        self.format = format
        self.timestamp = timestamp
    }
}

public struct AudioFormat {
    public let sampleRate: Double
    public let channels: Int
    public let bitsPerChannel: Int
    
    public init(sampleRate: Double, channels: Int, bitsPerChannel: Int) {
        self.sampleRate = sampleRate
        self.channels = channels
        self.bitsPerChannel = bitsPerChannel
    }
}
