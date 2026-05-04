[English](../../../README.md) | **한국어** | [日本語](../ja/README.md)

# core-ml-model-conversion

coremltools로 PyTorch 모델을 Core ML 형식으로 변환하고 SwiftUI iOS 앱에 통합하는 방법을 보여주는 샘플 프로젝트이다.

## Features

- **Model Conversion**: MobileNetV2(PyTorch)를 `.mlpackage`로 변환하는 Python 스크립트
- **Image Classification**: Vision과 Core ML을 사용해 사진을 분류하는 SwiftUI 앱
- **Quantization**: 모델 크기 축소를 위한 Float16 및 팔레트화 옵션
- **Photo Picker**: 사진 라이브러리에서 이미지를 선택해 분류

## Components

| Path | 설명 |
|------|------|
| `convert/convert.py` | PyTorch → Core ML 변환 스크립트, 양자화 옵션 포함 |
| `convert/requirements.txt` | Python 의존성 |
| `Sources/CoreMLDemo/ImageClassifier.swift` | 이미지 분류를 위한 Core ML과 Vision 래퍼 |
| `Sources/CoreMLDemo/ContentView.swift` | 사진 선택과 결과 표시를 담당하는 SwiftUI 인터페이스 |
| `Sources/CoreMLDemo/CoreMLDemoApp.swift` | 앱 진입점 |
| `Tests/CoreMLDemoTests/` | ImageClassifier 단위 테스트 |

## Requirements

- Python 3.8+
- Xcode 16.0+
- iOS 17.0+

## Usage

### 1. 모델 변환

```bash
cd convert
pip install -r requirements.txt
python convert.py
```

양자화 옵션은 아래와 같다.

```bash
python convert.py --quantize float16
python convert.py --quantize palettize --nbits 8
```

### 2. 앱 실행

1. Xcode에서 `CoreMLDemo.xcodeproj`를 연다
2. 생성된 `MobileNetV2.mlpackage`를 프로젝트로 드래그한다
3. iOS 시뮬레이터 또는 기기를 선택해 실행한다

`project.yml`에서 Xcode 프로젝트를 다시 생성하려면 아래 명령을 실행한다.

```bash
brew install xcodegen
xcodegen generate
```

## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details.
