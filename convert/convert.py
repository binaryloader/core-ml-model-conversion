"""
Core ML Model Conversion Script

Converts a pre-trained PyTorch MobileNetV2 model to Core ML format (.mlpackage).
The converted model can be directly integrated into an iOS/macOS app.

Usage:
    python convert.py
    python convert.py --quantize float16
    python convert.py --quantize palettize --nbits 8
"""

import argparse
from pathlib import Path

import coremltools as ct
import torch
import torchvision


def load_pytorch_model() -> torch.nn.Module:
    """Load a pre-trained MobileNetV2 model in evaluation mode."""
    model = torchvision.models.mobilenet_v2(
        weights=torchvision.models.MobileNet_V2_Weights.DEFAULT
    )
    model.eval()
    return model


def trace_model(model: torch.nn.Module) -> torch.jit.ScriptModule:
    """Trace the PyTorch model with example input to produce TorchScript."""
    example_input = torch.rand(1, 3, 224, 224)
    traced = torch.jit.trace(model, example_input)
    return traced


def convert_to_coreml(traced_model: torch.jit.ScriptModule) -> ct.models.MLModel:
    """Convert a TorchScript model to Core ML format."""
    mlmodel = ct.convert(
        traced_model,
        inputs=[
            ct.ImageType(
                name="image",
                shape=(1, 3, 224, 224),
                scale=1 / 255.0
            )
        ],
        minimum_deployment_target=ct.target.iOS16,
    )
    return mlmodel


def set_metadata(mlmodel: ct.models.MLModel) -> None:
    """Set descriptive metadata on the Core ML model."""
    mlmodel.author = "CoreMLDemo"
    mlmodel.short_description = "MobileNetV2 image classification model (ImageNet 1000 classes)"
    mlmodel.version = "1.0"

    spec = mlmodel.get_spec()

    input_desc = spec.description.input[0]
    input_desc.shortDescription = "224x224 RGB image"

    output_desc = spec.description.output[0]
    output_desc.shortDescription = "Classification probabilities for ImageNet 1000 classes"


def quantize_float16(mlmodel: ct.models.MLModel) -> ct.models.MLModel:
    """Quantize model weights to Float16 (~50% size reduction)."""
    import coremltools.optimize as cto

    return cto.coreml.linear_quantize_weights(
        mlmodel,
        dtype="float16"
    )


def quantize_palettize(
    mlmodel: ct.models.MLModel,
    nbits: int = 8
) -> ct.models.MLModel:
    """Palettize model weights (~75% size reduction at 8-bit)."""
    import coremltools.optimize as cto

    config = cto.coreml.OptimizationConfig(
        global_config=cto.coreml.OpPalettizerConfig(nbits=nbits)
    )
    return cto.coreml.palettize_weights(mlmodel, config)


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert MobileNetV2 to Core ML")
    parser.add_argument(
        "--output",
        type=str,
        default="MobileNetV2.mlpackage",
        help="Output file path (default: MobileNetV2.mlpackage)"
    )
    parser.add_argument(
        "--quantize",
        type=str,
        choices=["float16", "palettize"],
        help="Quantization method (optional)"
    )
    parser.add_argument(
        "--nbits",
        type=int,
        default=8,
        help="Palettization bit width (default: 8, used with --quantize palettize)"
    )
    args = parser.parse_args()

    print("Loading PyTorch MobileNetV2...")
    model = load_pytorch_model()

    print("Tracing model with TorchScript...")
    traced = trace_model(model)

    print("Converting to Core ML format...")
    mlmodel = convert_to_coreml(traced)

    set_metadata(mlmodel)

    if args.quantize == "float16":
        print("Applying Float16 quantization...")
        mlmodel = quantize_float16(mlmodel)
    elif args.quantize == "palettize":
        print(f"Applying {args.nbits}-bit palettization...")
        mlmodel = quantize_palettize(mlmodel, args.nbits)

    output_path = Path(args.output)
    mlmodel.save(str(output_path))
    print(f"Model saved to {output_path}")
    print(f"Model size: {sum(f.stat().st_size for f in output_path.rglob('*') if f.is_file()) / 1024 / 1024:.1f} MB")


if __name__ == "__main__":
    main()
