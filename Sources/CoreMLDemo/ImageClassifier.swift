//
//  ImageClassifier.swift
//  CoreMLDemo
//
//  Created by BinaryLoader on 2/18/26.
//

import CoreML
import Vision

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// A classification result containing the label and confidence score.
public struct ClassificationResult: Identifiable, Sendable {

    public let id = UUID()
    public let label: String
    public let confidence: Float

    public var confidencePercentage: String {
        String(
            format: "%.1f%%",
            confidence * 100
        )
    }
}

/// Wraps a Core ML model to perform image classification using the Vision framework.
@MainActor
public final class ImageClassifier: ObservableObject {

    @Published public var results: [ClassificationResult] = []
    @Published public var isClassifying = false
    @Published public var errorMessage: String?

    private var vnModel: VNCoreMLModel?

    public init() {
        loadBundledModel()
    }

    /// Loads the Core ML model. Call this before performing classification.
    /// - Parameter mlModel: A compiled `MLModel` instance.
    public func loadModel(_ mlModel: MLModel) {
        do {
            vnModel = try VNCoreMLModel(for: mlModel)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load model: \(error.localizedDescription)"
        }
    }

    private func loadBundledModel() {
        guard let url = Bundle.main.url(
            forResource: "MobileNetV2",
            withExtension: "mlmodelc"
        ) else {
            errorMessage = "Model not found. Add MobileNetV2.mlpackage to the project."
            return
        }

        do {
            let mlModel = try MLModel(contentsOf: url)
            loadModel(mlModel)
        } catch {
            errorMessage = "Failed to load model: \(error.localizedDescription)"
        }
    }

    /// Classifies the given image and updates `results`.
    /// - Parameter cgImage: The image to classify.
    public func classify(_ cgImage: CGImage) {
        guard let vnModel else {
            errorMessage = "Model not loaded"
            return
        }

        isClassifying = true
        results = []
        errorMessage = nil

        let request = VNCoreMLRequest(model: vnModel) { [weak self] request, error in
            Task { @MainActor in
                self?.handleResults(
                    request: request,
                    error: error
                )
            }
        }

        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
        } catch {
            isClassifying = false
            errorMessage = "Classification failed: \(error.localizedDescription)"
        }
    }

    private func handleResults(
        request: VNRequest,
        error: Error?
    ) {
        isClassifying = false

        if let error {
            errorMessage = "Classification error: \(error.localizedDescription)"
            return
        }

        guard let observations = request.results as? [VNClassificationObservation] else {
            errorMessage = "Unexpected result type"
            return
        }

        results = observations.prefix(5).map { observation in
            ClassificationResult(
                label: observation.identifier,
                confidence: observation.confidence
            )
        }
    }
}
