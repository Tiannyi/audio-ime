# Audio IME Architecture

## System Architecture

```mermaid
graph TB
    subgraph Platform Layer
        MacOS[macOS Input Method]
        iOS[iOS Keyboard Extension]
    end

    subgraph Core Engine
        AP[Audio Pipeline]
        RP[Recognition Pipeline]
        LP[LLM Pipeline]
        TP[Text Processing]
    end

    subgraph Hardware Integration
        NE[Neural Engine]
        AC[Audio Capture]
        HT[Hardware Trigger]
    end

    subgraph External Services
        LLM[LLM Service]
    end

    %% Platform connections
    MacOS --> RP
    iOS --> RP
    
    %% Core pipeline
    AC --> AP
    AP --> RP
    RP --> LP
    LP --> TP
    TP --> MacOS
    TP --> iOS
    
    %% Hardware integration
    NE --> RP
    NE --> LP
    HT --> AC
    HT --> RP
    
    %% External services
    LP --> LLM
```

## Operational Modes

### Dual-Mode System
```mermaid
graph TB
    subgraph Passive Mode
        AL[Always Listening]
        BC[Background Capture]
        LS[Local Storage]
    end

    subgraph Active Mode
        HT[Hardware Trigger]
        IM[IME Mode]
        TI[Text Input]
    end

    subgraph Hardware Integration
        USB[USB Switch]
        BT[Bluetooth Device]
        HD[HID Interface]
    end

    AL --> BC
    BC --> LS
    HT --> IM
    IM --> TI
    USB --> HT
    BT --> HT
    HD --> HT
```

### Mode Switching Flow
```mermaid
sequenceDiagram
    participant HW as Hardware Switch
    participant AM as Audio Manager
    participant IM as Input Method
    participant ST as Storage

    Note over AM: Always Running
    loop Background Mode
        AM->>ST: Capture & Store
    end

    HW->>AM: Trigger Signal
    AM->>IM: Activate IME
    Note over AM,IM: Switch to Active Mode
    
    IM->>AM: Process Recent Buffer
    AM->>IM: Return Text
    
    HW->>AM: Release Signal
    AM->>IM: Deactivate IME
    Note over AM: Return to Background Mode
```

## Component Interaction Flow

1. **User Input Flow**
```mermaid
sequenceDiagram
    participant User
    participant IME
    participant Audio
    participant Recognition
    participant LLM
    participant TextOutput

    User->>IME: Start Recording
    IME->>Audio: Initialize Capture
    Audio->>Recognition: Stream Audio
    Recognition->>LLM: Check Confidence
    alt High Confidence
        LLM->>TextOutput: Direct Output
    else Low Confidence
        LLM->>LLM: Process Text
        LLM->>TextOutput: Corrected Output
    end
    TextOutput->>IME: Insert Text
    IME->>User: Show Result
```

## Data Flow

```mermaid
graph LR
    subgraph Input
        Audio[Audio Data]
        Config[Configuration]
    end

    subgraph Processing
        ASR[Speech Recognition]
        Cache[LLM Cache]
        Batch[Batch Processor]
    end

    subgraph Output
        Text[Text Output]
        UI[User Interface]
    end

    Audio --> ASR
    ASR --> Cache
    Cache --> Batch
    Batch --> Text
    Text --> UI
    Config --> ASR
    Config --> Cache
    Config --> Batch
```

## Conversation Tracking & Summarization

### System Architecture
```mermaid
graph TB
    subgraph Audio Processing
        AC[Audio Capture]
        SR[Speech Recognition]
        TS[Timestamp Manager]
    end

    subgraph Text Processing
        TM[Text Manager]
        CS[Conversation Segmenter]
        KB[Knowledge Base]
    end

    subgraph Summarization
        SP[Summary Processor]
        AP[Action Parser]
        CM[Context Manager]
    end

    subgraph Storage
        LS[Local Storage]
        IC[Intelligent Cache]
    end

    AC --> SR
    SR --> TS
    TS --> TM
    TM --> CS
    CS --> SP
    SP --> AP
    CM --> SP
    KB --> SP
    SP --> IC
    IC --> LS
```

### Optimization Strategies

1. **LLM Usage Optimization**
   - Local preprocessing to identify significant segments
   - Batch processing of summaries
   - Incremental summarization
   - Context-aware compression

2. **Storage Optimization**
   - Tiered storage system
     * Hot: Recent conversations (in memory)
     * Warm: Summaries and actions (local cache)
     * Cold: Archive (compressed storage)
   - Intelligent pruning of redundant information
   - Vector embeddings for efficient retrieval

3. **Processing Pipeline**
```mermaid
sequenceDiagram
    participant Audio as Audio Stream
    participant Buffer as Smart Buffer
    participant Processor as Text Processor
    participant LLM as LLM Service
    participant Storage as Storage

    Audio->>Buffer: Stream audio
    Buffer->>Buffer: Accumulate segment
    Buffer->>Processor: Process when complete
    Processor->>Processor: Local analysis
    alt Requires LLM
        Processor->>LLM: Send batch
        LLM->>Processor: Return summary
    end
    Processor->>Storage: Store results
```

### Key Components

1. **Smart Buffer**
```swift
class SmartBuffer {
    - Rolling window of recent audio
    - Automatic segmentation
    - Intelligent flush triggers
}
```

2. **Conversation Segmenter**
```swift
class ConversationSegmenter {
    - Speaker diarization
    - Topic detection
    - Natural breakpoint identification
}
```

3. **Summary Processor**
```swift
class SummaryProcessor {
    - Incremental summarization
    - Action item extraction
    - Priority scoring
}
```

4. **Storage Manager**
```swift
class StorageManager {
    - Tiered storage handling
    - Compression
    - Retention policies
}
```

### Optimization Metrics

1. **LLM Usage**
   - Target: < 1 API call per 5 minutes of conversation
   - Batch size: 10-15 segments per call
   - Context window: Maximum 2000 tokens

2. **Storage**
   - Raw audio: None (real-time processing only)
   - Text: < 1MB per hour of conversation
   - Summaries: < 100KB per hour
   - Actions: < 10KB per hour

3. **Processing**
   - Real-time transcription
   - Summary generation: < 30s delay
   - Action extraction: < 15s delay

### Integration with Existing IME

1. **Shared Components**
   - Audio capture system
   - Speech recognition engine
   - Text processing pipeline

2. **Additional Features**
   - Background processing
   - Notification system
   - Export capabilities

## Hardware Integration

### Switch Interface
1. **Connection Types**
   - USB HID Device
   - Bluetooth LE Device
   - GPIO Interface (for custom hardware)

2. **Signal Processing**
   - Debouncing
   - Multi-click detection
   - Long-press handling

3. **Power Management**
   - Low-power modes
   - Battery monitoring (for wireless)
   - Auto-sleep functionality

### State Management
```mermaid
stateDiagram-v2
    [*] --> Passive
    Passive --> Active: Hardware Trigger
    Active --> Passive: Release Trigger
    
    state Passive {
        [*] --> Listening
        Listening --> Processing: Buffer Full
        Processing --> Storing: Process Complete
        Storing --> Listening: Storage Complete
    }
    
    state Active {
        [*] --> Capturing
        Capturing --> Converting: Process Buffer
        Converting --> Inserting: Text Ready
        Inserting --> Capturing: Text Inserted
    }
```

## Component Details

### Core Components

1. **Audio Capture System**
   - Handles real-time audio input
   - Manages audio sessions
   - Provides buffering and preprocessing

2. **Speech Recognition Engine**
   - Primary: Apple Neural Engine
   - Fallback: Whisper.cpp
   - Handles language detection and processing

3. **LLM Processing Pipeline**
   - Confidence evaluation
   - Batch processing
   - Caching system
   - Error correction

4. **Text Processing**
   - Format management
   - Input method integration
   - Context handling

### Platform Integration

1. **macOS Integration**
   - Input Method Kit framework
   - Status bar management
   - System preferences
   - Keyboard event handling

2. **iOS Integration**
   - Custom keyboard extension
   - Touch interaction
   - System integration

## Performance Considerations

1. **Neural Engine Optimization**
   - Dynamic power management
   - Batch processing optimization
   - Cache management

2. **Memory Management**
   - Audio buffer optimization
   - Recognition result caching
   - LLM context management

3. **Battery Efficiency**
   - Power mode adaptation
   - Processing throttling
   - Background task management
