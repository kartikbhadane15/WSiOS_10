# Visual Search / Style Board – Integration Guide

## Files to add to `WSHackathonApp/`

| File | Purpose |
|------|---------|
| `VisualSearchView.swift` | Root SwiftUI view — camera/picker entry, layout orchestration |
| `VisualSearchViewModel.swift` | `@MainActor ObservableObject` — state machine & pipeline driver |
| `VisionAnalysisService.swift` | On-device Vision: dominant colours (k-means), scene classification, FeaturePrint embedding |
| `StyleSearchService.swift` | Server-side similarity search API call + mock data for demo |
| `VisualSearchSupportViews.swift` | `ProductItem` model, `ProductGridView`, `ColorPaletteView`, `StyleTagsView`, `ErrorView`, `WrapLayout` |
| `CameraPickerView.swift` | `UIViewControllerRepresentable` wrapping `UIImagePickerController` |

---

## 1. Add privacy keys to Info.plist (or Generated Info.plist via build settings)

```xml
<key>NSCameraUsageDescription</key>
<string>WSI Hackathon uses your camera to photograph your kitchen décor and find matching products.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>WSI Hackathon accesses your photos so you can select an image of your kitchen for style matching.</string>
```

If your project uses `GENERATE_INFOPLIST_FILE = YES` (it does), add these in
**Build Settings → Info.plist Values** or directly in **Signing & Capabilities → Info** tab.

---

## 2. Hook into your existing navigation / tab bar

```swift
// In your ContentView or TabView:
TabView {
    // ... other tabs ...
    VisualSearchView()
        .tabItem {
            Label("Style Match", systemImage: "camera.viewfinder")
        }
}
```

Or navigate to it from a product detail button:

```swift
NavigationLink(destination: VisualSearchView()) {
    Label("Find matching items", systemImage: "camera.viewfinder")
}
```

---

## 3. Server API contract

`POST /v1/products/visual-search`

### Request body (JSON)
```json
{
  "embedding":       [0.12, -0.34, ...],   // 512-d float array from VNFeaturePrintObservation
  "colorHexValues":  ["#D4A96A", "#F2EDE4", "#8B6553"],
  "tags":            ["Rustic", "Wood", "Warm Palette"],
  "limit":           20
}
```

### Response (JSON)
```json
{
  "products": [
    {
      "id":         "P001",
      "name":       "Rustic Ceramic Vase",
      "price":      49.99,
      "currency":   "USD",
      "imageURL":   "https://cdn.wsi.com/products/P001.jpg",
      "matchScore": 0.95,
      "tags":       ["Rustic", "Ceramic"]
    }
  ]
}
```

The backend should:
1. Receive the embedding and store it temporarily.
2. Run cosine-similarity (or ANN search via FAISS / pgvector) against pre-indexed product embeddings.
3. Optionally boost results whose `colorHexValues` are within a CIELAB distance threshold of the query colours.
4. Return the top-N products sorted by `matchScore` descending.

---

## 4. Demo mode (no server needed for hackathon)

In the Xcode scheme, add environment variable:
```
USE_MOCK_DATA = 1
```

`StyleSearchService` detects this at runtime (`#if DEBUG`) and returns
`MockProductData.generate(…)` without hitting the network.

---

## 5. Required frameworks (already available, no SPM packages needed)

- `Vision` — on-device analysis
- `PhotosUI` — `PhotosPicker`
- `CoreImage` — pixel manipulation

All are system frameworks; no additional SPM dependencies are required.

---

## Architecture at a glance

```
VisualSearchView
    └─ VisualSearchViewModel  (@StateObject)
           ├─ VisionAnalysisService   → on-device (Vision.framework)
           │      • k-means dominant colours
           │      • VNClassifyImageRequest  → style tags
           │      • VNGenerateImageFeaturePrintRequest → embedding
           └─ StyleSearchService      → server (URLSession async/await)
                  • POST /v1/products/visual-search
                  • Decodes [ProductItem]
```
