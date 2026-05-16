// VisualSearchView.swift
// WSHackathonApp – Visual Search / Style Board
//
// Entry point: a "Find matching items" button that opens the camera or
// photo library. After the user picks a photo the app runs on-device
// Vision analysis (dominant colours + style tags) and then fires a
// server-side embedding similarity search to surface matching products.

import SwiftUI
import PhotosUI

struct VisualSearchView: View {

    @StateObject private var viewModel = VisualSearchViewModel()

    // Photo-picker state
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showSourcePicker = false
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // ── Hero / inspiration header ──────────────────────
                        headerSection

                        // ── Captured image preview ─────────────────────────
                        if let image = viewModel.capturedImage {
                            capturedImageSection(image: image)
                        }

                        // ── Colour palette chips ───────────────────────────
                        if !viewModel.dominantColors.isEmpty {
                            ColorPaletteView(colors: viewModel.dominantColors)
                        }

                        // ── Style tags ────────────────────────────────────
                        if !viewModel.styleTags.isEmpty {
                            StyleTagsView(tags: viewModel.styleTags)
                        }

                        // ── Results grid ──────────────────────────────────
                        switch viewModel.state {
                        case .idle:
                            EmptyView()
                        case .analyzing:
                            ProgressView("Analysing your photo…")
                                .padding(.top, 40)
                        case .searching:
                            ProgressView("Finding matching products…")
                                .padding(.top, 16)
                        case .results(let products):
                            ProductGridView(products: products)
                        case .error(let message):
                            ErrorView(message: message) {
                                viewModel.retry()
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                }

                // ── Floating "Find matching items" button ─────────────────
                if viewModel.capturedImage == nil {
                    VStack {
                        Spacer()
                        findMatchingButton
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Style Board")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if viewModel.capturedImage != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("New Search") {
                            viewModel.reset()
                            selectedPhotoItem = nil
                        }
                        .foregroundColor(.accentColor)                    }
                }
            }
            // Source action sheet ─────────────────────────────────────────
            .confirmationDialog("Choose a source", isPresented: $showSourcePicker) {
                Button("Camera") { showCamera = true }

                // PhotosPicker is handled inline via the button below
                PhotosPickerButton(selectedItem: $selectedPhotoItem,
                                   label: "Photo Library")

                Button("Cancel", role: .cancel) {}
            }
            // Camera sheet ────────────────────────────────────────────────
            .sheet(isPresented: $showCamera) {
                CameraPickerView { uiImage in
                    viewModel.process(image: uiImage)
                }
                .ignoresSafeArea()
            }
            // Photo library selection ──────────────────────────────────────
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        viewModel.process(image: uiImage)
                    }
                }
            }
        }
    }

    // MARK: – Sub-views

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Find your perfect match")
                .font(.title2.bold())
            Text("Photograph your kitchen décor and we'll surface products that share its colour palette and style.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private func capturedImageSection(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .bottomLeading) {
                Label("Your photo", systemImage: "camera.fill")
                    .font(.caption.bold())
                    .padding(8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(10)
            }
    }

    private var findMatchingButton: some View {
        Button {
            showSourcePicker = true
        } label: {
            Label("Find matching items", systemImage: "camera.viewfinder")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .accentColor.opacity(0.4), radius: 10, y: 4)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: – Inline PhotosPicker helper button
// Wraps PhotosPickerItem inside a confirmation-dialog-compatible view.

private struct PhotosPickerButton: View {
    @Binding var selectedItem: PhotosPickerItem?
    let label: String

    var body: some View {
        PhotosPicker(selection: $selectedItem,
                     matching: .images,
                     photoLibrary: .shared()) {
            Text(label)
        }
    }
}

#Preview {
    VisualSearchView()
}
