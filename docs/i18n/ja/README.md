[English](../../../README.md) | [한국어](../ko/README.md) | 日本語

# core-ml-model-conversion

coremltoolsを使ってPyTorchモデルをCore ML形式に変換し、SwiftUIのiOSアプリに統合する方法を示すサンプルプロジェクトです。

## Features

- **Model Conversion**：MobileNetV2(PyTorch)を`.mlpackage`に変換するPythonスクリプト
- **Image Classification**：VisionとCore MLで写真を分類するSwiftUIアプリ
- **Quantization**：モデルサイズ削減のためのFloat16およびパレット化オプション
- **Photo Picker**：写真ライブラリから画像を選択して分類

## Components

| Path | 説明 |
|------|------|
| `convert/convert.py` | PyTorch → Core ML変換スクリプト、量子化オプション付き |
| `convert/requirements.txt` | Pythonの依存関係 |
| `Sources/CoreMLDemo/ImageClassifier.swift` | 画像分類のためのCore MLとVisionのラッパー |
| `Sources/CoreMLDemo/ContentView.swift` | 写真選択と結果表示を担うSwiftUIインターフェース |
| `Sources/CoreMLDemo/CoreMLDemoApp.swift` | アプリのエントリポイント |
| `Tests/CoreMLDemoTests/` | ImageClassifierの単体テスト |

## Requirements

- Python 3.8+
- Xcode 16.0+
- iOS 17.0+

## Usage

### 1. モデルの変換

```bash
cd convert
pip install -r requirements.txt
python convert.py
```

量子化オプションは次のとおりです。

```bash
python convert.py --quantize float16
python convert.py --quantize palettize --nbits 8
```

### 2. アプリの実行

1. Xcodeで`CoreMLDemo.xcodeproj`を開きます
2. 生成された`MobileNetV2.mlpackage`をプロジェクトにドラッグします
3. iOSシミュレータまたは実機を選択して実行します

`project.yml`からXcodeプロジェクトを再生成するには、次のコマンドを実行します。

```bash
brew install xcodegen
xcodegen generate
```

## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details.
