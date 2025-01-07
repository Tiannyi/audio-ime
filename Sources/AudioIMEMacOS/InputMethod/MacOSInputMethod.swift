import Foundation
import InputMethodKit
import AudioIMECore

public class MacOSInputMethod: IMKInputController {
    private let recognitionPipeline: RecognitionPipeline
    private var isRecording: Bool = false
    private let statusItem: NSStatusItem
    
    public init(server: IMKServer, delegate: Any, client: Any) {
        // Initialize status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "mic", accessibilityDescription: "Audio IME")
        }
        
        // Initialize recognition pipeline
        let audioCapture = AppleAudioCapture()
        let primaryEngine = AppleNeuralSpeechEngine()
        let fallbackEngine = WhisperFallbackEngine()
        let llmProcessor = OptimizedLLMProcessor()
        
        self.recognitionPipeline = RecognitionPipeline(
            audioCapture: audioCapture,
            primaryEngine: primaryEngine,
            fallbackEngine: fallbackEngine,
            llmProcessor: llmProcessor
        )
        
        super.init(server: server, delegate: delegate, client: client)
        setupMenus()
    }
    
    private func setupMenus() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Start Recording", action: #selector(toggleRecording), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc private func toggleRecording() {
        Task {
            if isRecording {
                await recognitionPipeline.stopRecognition()
                updateStatusItemImage(recording: false)
            } else {
                try? await recognitionPipeline.startRecognition()
                updateStatusItemImage(recording: true)
            }
            isRecording = !isRecording
        }
    }
    
    private func updateStatusItemImage(recording: Bool) {
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: recording ? "mic.fill" : "mic",
                accessibilityDescription: "Audio IME"
            )
        }
    }
    
    @objc private func showPreferences() {
        // Implement preferences window
    }
    
    // MARK: - IMKInputController Override Methods
    
    public override func inputText(_ string: String!, key keyCode: Int, modifiers flags: Int, client sender: Any!) -> Bool {
        // Handle text input from recognition pipeline
        return true
    }
    
    public override func didCommand(by string: String!, client sender: Any!) -> Bool {
        // Handle commands
        return false
    }
    
    public override func recognizedEvents(_ sender: Any!) -> Int {
        // Register for key and command events
        return Int(IMKKeyboardEvent | IMKCommandEvent)
    }
}
