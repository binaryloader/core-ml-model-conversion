//
//  ContentView.swift
//  CoreMLDemo
//
//  Created by BinaryLoader on 2/18/26.
//

#if canImport(SwiftUI) && canImport(UIKit)
import PhotosUI
import SwiftUI

/// Main view that allows users to pick a photo and classify it with Core ML.
public struct ContentView: View {

    @StateObject private var classifier = ImageClassifier()
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                imageSection
                resultsSection
                Spacer()
            }
            .padding()
            .navigationTitle("Core ML Demo")
            .onChange(of: selectedItem) {
                loadImage()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images
                    ) {
                        Label(
                            "Select Photo",
                            systemImage: "photo.on.rectangle"
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var imageSection: some View {
        if let selectedImage {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)
        } else {
            ContentUnavailableView(
                "No Photo Selected",
                systemImage: "photo",
                description: Text("Select a photo to classify")
            )
        }
    }

    @ViewBuilder
    private var resultsSection: some View {
        if classifier.isClassifying {
            ProgressView("Classifying...")
        } else if let error = classifier.errorMessage {
            Label(
                error,
                systemImage: "exclamationmark.triangle"
            )
            .foregroundStyle(.red)
        } else if !classifier.results.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Results")
                    .font(.headline)

                ForEach(classifier.results) { result in
                    HStack {
                        Text(result.label)
                            .lineLimit(1)

                        Spacer()

                        Text(result.confidencePercentage)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func loadImage() {
        guard let selectedItem else { return }

        Task {
            guard
                let data = try? await selectedItem.loadTransferable(type: Data.self),
                let uiImage = UIImage(data: data)
            else { return }

            selectedImage = uiImage

            guard let cgImage = uiImage.cgImage else { return }

            classifier.classify(cgImage)
        }
    }
}

#Preview {
    ContentView()
}
#endif
