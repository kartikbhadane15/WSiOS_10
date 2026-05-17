// VisualSearchView.swift
// WSHackathonApp – Visual Search / Style Board

import SwiftUI
import PhotosUI
import Photos

struct VisualSearchView: View {

    @StateObject private var viewModel = VisualSearchViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        headerSection

                        if let image = viewModel.capturedImage {
                            capturedImageSection(image: image)
                        }

                        if !viewModel.dominantColors.isEmpty {
                            ColorPaletteView(colors: viewModel.dominantColors)
                        }

                        if !viewModel.styleTags.isEmpty {
                            StyleTagsView(tags: viewModel.styleTags)
                        }

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

                if viewModel.capturedImage == nil {
                    VStack {
                        Spacer()
                        VStack(spacing: 12) {
                            PhotosPicker(selection: $selectedPhotoItem,
                                         matching: .images,
                                         photoLibrary: .shared()) {
                                Label("Choose from Library", systemImage: "photo.on.rectangle")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(.systemGray5))
                                    .foregroundStyle(Color.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            Button {
                                showCamera = true
                            } label: {
                                Label("Take a Photo", systemImage: "camera")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(.systemGray5))
                                    .foregroundStyle(Color.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                        .padding(.horizontal, 24)
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
                        .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraPickerView { uiImage in
                    viewModel.process(image: uiImage)
                }
                .ignoresSafeArea()
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        viewModel.process(image: uiImage)
                    }
                }
            }
            .onAppear {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in }
            }
        }
    }

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
}

#Preview {
    VisualSearchView()
}
