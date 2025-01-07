# Audio IME

A smart Input Method Engine that combines always-on conversation tracking with hardware-triggered text input.

![Build Status](https://github.com/Tiannyi/audio-ime/workflows/CI/badge.svg)

## Features

- Always-on conversation tracking and summarization
- Hardware-triggered (USB/Bluetooth) text input mode
- Efficient LLM-powered text processing
- Optimized local storage with tiered caching
- Power-efficient background operation

## Requirements

- macOS 13.0+ or iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/[username]/audio-ime.git
cd audio-ime
```

2. Build the project:
```bash
swift build
```

3. Run tests:
```bash
swift test
```

## Usage

### As Input Method

1. Build the Input Method bundle:
```bash
xcodebuild -scheme AudioIMEMacOS build
```

2. Install:
```bash
sudo cp -r build/Debug/AudioIME.app /Library/Input\ Methods/
```

3. Enable in System Settings:
   - Open System Settings
   - Navigate to Keyboard > Input Sources
   - Click '+' and find "Audio IME"
   - Enable and grant permissions

### Hardware Trigger Setup

1. USB Device:
   - Plug in your USB trigger device
   - System will automatically detect and configure

2. Bluetooth Device:
   - Enable Bluetooth
   - Put device in pairing mode
   - Connect through System Settings

## Architecture

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed system design.

## Testing

See [TESTING.md](docs/TESTING.md) for testing instructions.

## License

MIT License - see LICENSE file

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
