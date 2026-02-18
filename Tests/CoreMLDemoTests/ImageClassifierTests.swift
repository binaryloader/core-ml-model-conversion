//
//  ImageClassifierTests.swift
//  CoreMLDemoTests
//
//  Created by BinaryLoader on 2/18/26.
//

import XCTest
@testable import CoreMLDemo

final class ImageClassifierTests: XCTestCase {

    @MainActor
    func testInitialState() {
        let classifier = ImageClassifier()

        XCTAssertTrue(classifier.results.isEmpty)
        XCTAssertFalse(classifier.isClassifying)
        XCTAssertNil(classifier.errorMessage)
    }

    @MainActor
    func testClassifyWithoutModelSetsError() {
        let classifier = ImageClassifier()

        let image = createTestImage()
        classifier.classify(image)

        XCTAssertEqual(
            classifier.errorMessage,
            "Model not loaded"
        )
        XCTAssertFalse(classifier.isClassifying)
    }

    func testClassificationResultConfidencePercentage() {
        let result = ClassificationResult(
            label: "cat",
            confidence: 0.956
        )

        XCTAssertEqual(
            result.confidencePercentage,
            "95.6%"
        )
    }

    func testClassificationResultZeroConfidence() {
        let result = ClassificationResult(
            label: "unknown",
            confidence: 0.0
        )

        XCTAssertEqual(
            result.confidencePercentage,
            "0.0%"
        )
    }

    func testClassificationResultFullConfidence() {
        let result = ClassificationResult(
            label: "dog",
            confidence: 1.0
        )

        XCTAssertEqual(
            result.confidencePercentage,
            "100.0%"
        )
    }

    // MARK: - Helpers

    private func createTestImage() -> CGImage {
        let width = 224
        let height = 224
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!

        let fillColor = CGColor(
            red: 0.5,
            green: 0.5,
            blue: 0.5,
            alpha: 1.0
        )
        context.setFillColor(fillColor)
        let fillRect = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height
        )
        context.fill(fillRect)

        return context.makeImage()!
    }
}
