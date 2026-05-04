English | [한국어](docs/i18n/ko/README.md) | [日本語](docs/i18n/ja/README.md)

# core-ml-model-conversion

A sample project demonstrating how to convert a PyTorch model to Core ML format using coremltools and integrate it into an iOS app with SwiftUI.

## Features

- **Model Conversion**: Python script to convert MobileNetV2 (PyTorch) to `.mlpackage`
- **Image Classification**: SwiftUI app that classifies photos using Vision + Core ML
- **Quantization**: Float16 and palettization options for model size reduction
- **Photo Picker**: Select images from the photo library for classification

## Components

| Path | Description |
|------|-------------|
| `convert/convert.py` | PyTorch → Core ML conversion script with quantization options |
| `convert/requirements.txt` | Python dependencies |
| `Sources/CoreMLDemo/ImageClassifier.swift` | Core ML + Vision wrapper for image classification |
| `Sources/CoreMLDemo/ContentView.swift` | SwiftUI interface with photo picker and results display |
| `Sources/CoreMLDemo/CoreMLDemoApp.swift` | App entry point |
| `Tests/CoreMLDemoTests/` | Unit tests for ImageClassifier |

## Requirements

- Python 3.8+
- Xcode 16.0+
- iOS 17.0+

## Usage

### 1. Convert the Model

```bash
cd convert
pip install -r requirements.txt
python convert.py
```

Quantization options:

```bash
python convert.py --quantize float16
python convert.py --quantize palettize --nbits 8
```

### 2. Run the App

1. Open `CoreMLDemo.xcodeproj` in Xcode
2. Drag the generated `MobileNetV2.mlpackage` into the project
3. Select an iOS simulator or device and run

To regenerate the Xcode project from `project.yml`:

```bash
brew install xcodegen
xcodegen generate
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
