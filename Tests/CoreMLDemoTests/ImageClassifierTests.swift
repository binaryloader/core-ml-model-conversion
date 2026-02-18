//
//  ImageClassifierTests.swift
//  CoreMLDemoTests
//
//  Created by BinaryLoader on 2/18/26.
//

import CoreML
import XCTest
@testable import CoreMLDemo

final class ImageClassifierTests: XCTestCase {

    @MainActor
    func testInitialState() {
        let classifier = ImageClassifier()

        XCTAssertTrue(classifier.results.isEmpty)
        XCTAssertFalse(classifier.isClassifying)
    }

    @MainActor
    func testClassifyProducesResults() {
        let classifier = ImageClassifier()

        guard classifier.errorMessage == nil else {
            XCTFail("Model failed to load: \(classifier.errorMessage!)")
            return
        }

        let image = createTestImage()
        classifier.classify(image)

        let expectation = XCTestExpectation(description: "Classification completes")

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            XCTAssertFalse(classifier.isClassifying)
            XCTAssertNil(classifier.errorMessage)
            XCTAssertFalse(classifier.results.isEmpty)

            if let top = classifier.results.first {
                XCTAssertFalse(top.label.isEmpty)
                XCTAssertGreaterThan(
                    top.confidence,
                    0
                )
                print("Top result: \(top.label) (\(top.confidencePercentage))")
            }

            expectation.fulfill()
        }

        wait(
            for: [expectation],
            timeout: 10
        )
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
