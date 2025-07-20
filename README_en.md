# Voice Changer Better - Real-time Voice Changer Optimized Version

English | [日本語](README_ja.md) | [中文](README.md)

## Project Introduction

This is a real-time voice changer project based on deep learning, supporting various voice conversion models including RVC, SoVitsSVC, DDSP-SVC, etc. This project is based on [w-okada/voice-changer](https://github.com/w-okada/voice-changer) with UI interface optimizations to provide a better user experience.

## Original Project

This project is developed based on [w-okada/voice-changer](https://github.com/w-okada/voice-changer). Thanks to the original author for the excellent work.

## UI Interface Optimization

This version includes the following UI improvements:

### 1. Overall Layout Optimization
- Improved component spacing and alignment
- Enhanced visual hierarchy and readability
- Better responsive design for different screen sizes

### 2. Control Button Optimization
- Redesigned start/stop/passthrough buttons with better visual feedback
- Improved button states and hover effects
- More intuitive button layout and grouping

### 3. Slider Control Enhancement
- Enhanced slider appearance with better visual indicators
- Improved slider responsiveness and precision
- Better value display and real-time feedback

### 4. Noise Control Area
- Optimized noise suppression controls layout
- Better organization of noise-related settings
- Improved visual clarity for noise control options

### 5. Character Area Control
- Enhanced character selection interface
- Better layout for character-specific controls
- Improved horizontal alignment for control elements

## Technical Implementation

### Key Optimizations
- **CSS Layout Improvements**: Added new CSS classes for better component alignment
- **Component Structure**: Optimized React component hierarchy for better maintainability
- **Responsive Design**: Enhanced mobile and tablet compatibility
- **User Experience**: Improved interaction feedback and visual cues

### Modified Files
- `client/demo/src/App.css` - Added new CSS classes for layout optimization
- `client/demo/src/components/101_CharacterArea.tsx` - Enhanced character area controls
- Various component files for improved styling and layout

## Project Structure

```
voice-changer-better/
├── client/                 # Frontend client application
│   ├── demo/              # Demo application
│   └── lib/               # Client libraries
├── server/                # Backend server
├── docker/                # Docker configurations
└── README.md              # Project documentation
```

## Quick Start

### Prerequisites
- Node.js (v14 or higher)
- Python 3.8+
- CUDA-compatible GPU (recommended)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/voice-changer-better.git
cd voice-changer-better
```

2. Install client dependencies:
```bash
cd client/demo
npm install
```

3. Install server dependencies:
```bash
cd ../../server
pip install -r requirements.txt
```

4. Start the development server:
```bash
# Terminal 1: Start backend
cd server
python main.py

# Terminal 2: Start frontend
cd client/demo
npm start
```

5. Open your browser and navigate to `http://localhost:8080`

## Features

- **Real-time Voice Conversion**: Low-latency voice changing with multiple model support
- **Multiple Model Support**: RVC, SoVitsSVC, DDSP-SVC, and more
- **GPU Acceleration**: CUDA support for improved performance
- **Cross-platform**: Windows, macOS, and Linux support
- **Web Interface**: Easy-to-use browser-based interface
- **Optimized UI**: Enhanced user experience with improved layout and controls

## License

This project follows the same license as the original project. Please refer to the original repository for license details.

## Changelog

### v1.0.0 (UI Optimization Release)
- Enhanced overall layout and component alignment
- Improved control button design and functionality
- Optimized slider controls for better user interaction
- Enhanced noise control area organization
- Improved character area control layout
- Added responsive design improvements
- Better visual feedback and user experience

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## Acknowledgments

- Original project: [w-okada/voice-changer](https://github.com/w-okada/voice-changer)
- All contributors to the original voice-changer project
- The open-source community for various libraries and tools used in this project