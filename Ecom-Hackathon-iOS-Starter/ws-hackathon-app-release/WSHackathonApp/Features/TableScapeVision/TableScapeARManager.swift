//
//  TableScapeARManager.swift
//  WSHackathonApp
//
//  TableScape Vision - AR Session & Scene Manager
//

import ARKit
import SceneKit
import Combine
import UIKit
import Vision

// MARK: - AR State
enum TableScapeARState: Equatable {
    case initializing
    case scanning
    case surfaceDetected
    case placing
    case placed
    case error(String)
    
    static func == (lhs: TableScapeARState, rhs: TableScapeARState) -> Bool {
        switch (lhs, rhs) {
        case (.initializing, .initializing),
             (.scanning, .scanning),
             (.surfaceDetected, .surfaceDetected),
             (.placing, .placing),
             (.placed, .placed):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - AR Manager
@MainActor
final class TableScapeARManager: NSObject, ObservableObject {
    
    @Published var arState: TableScapeARState = .initializing
    @Published var coachingMessage: String = "Initializing AR..."
    @Published var detectedPlaneCount: Int = 0
    
    private(set) var sceneView: ARSCNView!
    private var detectedPlanes: [UUID: SCNNode] = [:]
    private var productNodes: [SCNNode] = []
    private var placementAnchor: ARPlaneAnchor?
    private var cartItems: [CartItem] = []
    private var downloadedImages: [String: UIImage] = [:]
    
    // MARK: - Setup
    func setupARView() -> ARSCNView {
        sceneView = ARSCNView(frame: .zero)
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        // Environment
        sceneView.scene.lightingEnvironment.intensity = 1.0
        
        // Add ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 500
        ambientLight.light?.color = UIColor.white
        sceneView.scene.rootNode.addChildNode(ambientLight)
        
        return sceneView
    }
    
    func startSession() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.smoothedSceneDepth) {
            config.frameSemantics.insert(.smoothedSceneDepth)
        }
        
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        arState = .scanning
        coachingMessage = "Point your camera at your table"
    }
    
    func pauseSession() {
        sceneView?.session.pause()
    }
    
    // MARK: - Cart Items
    func setCartItems(_ items: [CartItem]) {
        self.cartItems = items
        preloadImages()
    }
    
    // MARK: - Image Preloading
    private func preloadImages() {
        for item in cartItems {
            guard let url = item.imageURL else { continue }
            Task {
                if let image = await downloadImage(from: url) {
                    // Remove background during preloading for cleaner AR placement
                    let processed = await Self.removeBackground(from: image)
                    downloadedImages[item.id] = processed
                }
            }
        }
    }
    
    private func downloadImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    // MARK: - Background Removal
    private static func removeBackground(from image: UIImage) async -> UIImage {
        return await Task.detached(priority: .userInitiated) {
            if #available(iOS 17.0, *) {
                if let result = await TableScapeARManager.visionRemoveBackground(from: image) {
                    return result
                }
            }
            return await TableScapeARManager.floodFillRemoveBackground(from: image) ?? image
        }.value
    }
    
    // MARK: - Vision Framework Background Removal (iOS 17+)
    @available(iOS 17.0, *)
    private static func visionRemoveBackground(from image: UIImage) -> UIImage? {
        guard let inputCG = image.cgImage else { return nil }
        
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: inputCG, options: [:])
        
        do {
            try handler.perform([request])
            guard let result = request.results?.first else { return nil }
            
            let maskBuffer = try result.generateScaledMaskForImage(
                forInstances: result.allInstances,
                from: handler
            )
            
            let originalCI = CIImage(cgImage: inputCG)
            let maskCI = CIImage(cvPixelBuffer: maskBuffer)
            let background = CIImage(color: CIColor.clear).cropped(to: originalCI.extent)
            
            guard let blend = CIFilter(name: "CIBlendWithMask") else { return nil }
            blend.setValue(originalCI, forKey: kCIInputImageKey)
            blend.setValue(background, forKey: kCIInputBackgroundImageKey)
            blend.setValue(maskCI, forKey: kCIInputMaskImageKey)
            
            guard let output = blend.outputImage else { return nil }
            
            let ctx = CIContext()
            guard let cgOut = ctx.createCGImage(output, from: originalCI.extent) else { return nil }
            
            return UIImage(cgImage: cgOut)
        } catch {
            print("Vision background removal failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Handle Tap (Place Items)
    func handleTap(at point: CGPoint) {
        guard arState == .surfaceDetected || arState == .placed else { return }
        
        // Use raycast for accurate tap-to-world positioning
        guard let query = sceneView.raycastQuery(from: point, allowing: .existingPlaneGeometry, alignment: .horizontal) else { return }
        let results = sceneView.session.raycast(query)
        guard let result = results.first else { return }
        
        arState = .placing
        coachingMessage = "Placing items..."
        
        // Remove old product nodes
        productNodes.forEach { $0.removeFromParentNode() }
        productNodes.removeAll()
        
        // Hide plane visualizations
        detectedPlanes.values.forEach { $0.isHidden = true }
        
        let position = SCNVector3(
            result.worldTransform.columns.3.x,
            result.worldTransform.columns.3.y,
            result.worldTransform.columns.3.z
        )
        
        placeProducts(at: position)
    }
    
    // MARK: - Place Products on Table
    private func placeProducts(at center: SCNVector3) {
        let itemCount = cartItems.count
        guard itemCount > 0 else { return }
        
        if itemCount == 1 {
            // Single item — place directly at tap point
            let node = createProductNode(for: cartItems[0], at: center, index: 0)
            sceneView.scene.rootNode.addChildNode(node)
            productNodes.append(node)
            
            let shadow = createShadowNode(for: cartItems[0], at: center)
            sceneView.scene.rootNode.addChildNode(shadow)
            productNodes.append(shadow)
        } else {
            // Multiple items — arrange in a circle around tap point
            let radius: Float = 0.06 + 0.03 * Float(min(itemCount, 6))
            
            for (index, item) in cartItems.enumerated() {
                let angle = (2.0 * Float.pi / Float(itemCount)) * Float(index) - Float.pi / 2
                let x = center.x + radius * cos(angle)
                let z = center.z + radius * sin(angle)
                
                let node = createProductNode(for: item, at: SCNVector3(x, center.y, z), index: index)
                sceneView.scene.rootNode.addChildNode(node)
                productNodes.append(node)
                
                let shadow = createShadowNode(for: item, at: SCNVector3(x, center.y, z))
                sceneView.scene.rootNode.addChildNode(shadow)
                productNodes.append(shadow)
            }
        }
        
        arState = .placed
        coachingMessage = "Items placed! Tap again to reposition"
        
        // Haptic
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: - Create Product Node (Upright cutout, billboard)
    private func createProductNode(for item: CartItem, at position: SCNVector3, index: Int) -> SCNNode {
        // Images are already pre-processed with background removal during preloading
        let cutoutImage = downloadedImages[item.id]
        
        // Larger size — 15cm base so it's clearly visible
        let baseSize: CGFloat = 0.15
        var planeWidth: CGFloat = baseSize
        var planeHeight: CGFloat = baseSize
        
        if let img = cutoutImage {
            let aspect = img.size.width / img.size.height
            if aspect > 1 {
                planeHeight = baseSize / aspect
            } else {
                planeWidth = baseSize * aspect
            }
        }
        
        let plane = SCNPlane(width: planeWidth, height: planeHeight)
        
        let material = SCNMaterial()
        material.diffuse.contents = cutoutImage
        material.isDoubleSided = true
        material.lightingModel = .constant
        material.transparencyMode = .aOne
        material.writesToDepthBuffer = true
        plane.materials = [material]
        
        let node = SCNNode(geometry: plane)
        // Stand UPRIGHT — bottom edge sits on the table
        node.position = SCNVector3(position.x, position.y + Float(planeHeight / 2), position.z)
        
        // Billboard constraint — always faces the camera
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y  // Only rotate around Y axis (stays upright)
        node.constraints = [billboardConstraint]
        
        // Entry animation
        node.scale = SCNVector3(0.01, 0.01, 0.01)
        node.opacity = 0
        
        let delay = Double(index) * 0.15
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
            node.scale = SCNVector3(1, 1, 1)
            node.opacity = 1
            SCNTransaction.commit()
        }
        
        return node
    }
    
    // MARK: - Flood-Fill Background Removal (Fallback)
    private static func floodFillRemoveBackground(from image: UIImage, threshold: CGFloat = 0.95) -> UIImage? {
        // Resize large images first for performance
        let maxDim: CGFloat = 512
        let resized: UIImage
        if max(image.size.width, image.size.height) > maxDim {
            let scale = maxDim / max(image.size.width, image.size.height)
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        } else {
            resized = image
        }
        
        guard let cgImage = resized.cgImage else { return image }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return image }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return image }
        let pixels = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        let thresholdByte = UInt8(threshold * 255)
        
        // Flood-fill from all edge pixels
        var visited = [Bool](repeating: false, count: width * height)
        var queue = [(Int, Int)]()
        queue.reserveCapacity(width * 2 + height * 2)
        
        // Seed with all border pixels
        for x in 0..<width {
            queue.append((x, 0))
            queue.append((x, height - 1))
        }
        for y in 1..<(height - 1) {
            queue.append((0, y))
            queue.append((width - 1, y))
        }
        
        var head = 0
        var transparentCount = 0
        while head < queue.count {
            let (x, y) = queue[head]
            head += 1
            
            guard x >= 0, x < width, y >= 0, y < height else { continue }
            let idx = y * width + x
            guard !visited[idx] else { continue }
            
            let offset = idx * bytesPerPixel
            let r = pixels[offset]
            let g = pixels[offset + 1]
            let b = pixels[offset + 2]
            
            // Only flood into near-pure-white pixels (stricter threshold)
            guard r > thresholdByte && g > thresholdByte && b > thresholdByte else { continue }
            
            visited[idx] = true
            transparentCount += 1
            
            // Spread to 4 neighbors
            queue.append((x + 1, y))
            queue.append((x - 1, y))
            queue.append((x, y + 1))
            queue.append((x, y - 1))
        }
        
        // Safety check: if more than 50% of pixels would be removed,
        // the product itself is likely white — skip background removal
        let totalPixels = width * height
        if transparentCount > totalPixels / 2 {
            return image
        }
        
        // Apply transparency to visited pixels
        for y in 0..<height {
            for x in 0..<width {
                let idx = y * width + x
                if visited[idx] {
                    let offset = idx * bytesPerPixel
                    pixels[offset + 3] = 0  // Make transparent
                }
            }
        }
        
        // Edge feathering — soften the boundary between transparent & opaque
        for y in 1..<(height - 1) {
            for x in 1..<(width - 1) {
                let idx = y * width + x
                if !visited[idx] {
                    // Count transparent neighbors
                    var transparentNeighbors = 0
                    let neighbors = [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]
                    for (nx, ny) in neighbors {
                        if visited[ny * width + nx] { transparentNeighbors += 1 }
                    }
                    // If touching transparent area, soften alpha
                    if transparentNeighbors > 0 {
                        let offset = idx * bytesPerPixel
                        let currentAlpha = pixels[offset + 3]
                        let newAlpha = UInt8(Double(currentAlpha) * (1.0 - Double(transparentNeighbors) * 0.15))
                        pixels[offset + 3] = newAlpha
                    }
                }
            }
        }
        
        guard let outputCGImage = context.makeImage() else { return image }
        return UIImage(cgImage: outputCGImage)
    }
    
    // MARK: - Shadow Node (Soft circular shadow on table)
    private func createShadowNode(for item: CartItem, at position: SCNVector3) -> SCNNode {
        let shadowSize: CGFloat = 0.10
        let shadowPlane = SCNPlane(width: shadowSize, height: shadowSize)
        
        // Create a soft radial gradient shadow image
        let shadowImage = createShadowImage(size: CGSize(width: 128, height: 128))
        
        let shadowMaterial = SCNMaterial()
        shadowMaterial.diffuse.contents = shadowImage
        shadowMaterial.lightingModel = .constant
        shadowMaterial.writesToDepthBuffer = false
        shadowMaterial.transparencyMode = .aOne
        shadowPlane.materials = [shadowMaterial]
        
        let shadowNode = SCNNode(geometry: shadowPlane)
        shadowNode.eulerAngles.x = -Float.pi / 2
        shadowNode.position = SCNVector3(position.x, position.y + 0.001, position.z)
        return shadowNode
    }
    
    // MARK: - Create Soft Shadow Image
    private func createShadowImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            
            let colors = [
                UIColor(white: 0, alpha: 0.25).cgColor,
                UIColor(white: 0, alpha: 0.08).cgColor,
                UIColor(white: 0, alpha: 0.0).cgColor
            ]
            let locations: [CGFloat] = [0.0, 0.5, 1.0]
            
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations) {
                ctx.cgContext.drawRadialGradient(
                    gradient,
                    startCenter: center, startRadius: 0,
                    endCenter: center, endRadius: radius,
                    options: .drawsAfterEndLocation
                )
            }
        }
    }
    
    // MARK: - Create Plane Visualization
    private func createPlaneVisualization(for anchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(anchor.planeExtent.width), height: CGFloat(anchor.planeExtent.height))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 0.15)
        material.lightingModel = .constant
        material.isDoubleSided = true
        plane.materials = [material]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.position = SCNVector3(
            anchor.center.x,
            0,
            anchor.center.z
        )
        
        // Border
        let border = SCNPlane(width: CGFloat(anchor.planeExtent.width), height: CGFloat(anchor.planeExtent.height))
        let borderMaterial = SCNMaterial()
        borderMaterial.diffuse.contents = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 0.4)
        borderMaterial.lightingModel = .constant
        borderMaterial.isDoubleSided = true
        borderMaterial.fillMode = .lines
        border.materials = [borderMaterial]
        
        let borderNode = SCNNode(geometry: border)
        borderNode.eulerAngles.x = -.pi / 2
        borderNode.position = planeNode.position
        borderNode.position.y += 0.001
        
        let containerNode = SCNNode()
        containerNode.addChildNode(planeNode)
        containerNode.addChildNode(borderNode)
        
        // Pulse animation
        let fadeIn = SCNAction.fadeOpacity(to: 0.8, duration: 1.0)
        let fadeOut = SCNAction.fadeOpacity(to: 0.4, duration: 1.0)
        containerNode.runAction(SCNAction.repeatForever(SCNAction.sequence([fadeIn, fadeOut])))
        
        return containerNode
    }
}

// MARK: - ARSCNViewDelegate
extension TableScapeARManager: ARSCNViewDelegate {
    
    nonisolated func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              planeAnchor.alignment == .horizontal else { return }
        
        Task { @MainActor in
            let planeNode = createPlaneVisualization(for: planeAnchor)
            node.addChildNode(planeNode)
            detectedPlanes[anchor.identifier] = planeNode
            detectedPlaneCount = detectedPlanes.count
            
            if arState == .scanning {
                arState = .surfaceDetected
                coachingMessage = "Surface detected! Tap on your table to place items"
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }
    
    nonisolated func renderer(_ renderer: any SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              planeAnchor.alignment == .horizontal else { return }
        
        Task { @MainActor in
            if let existingNode = detectedPlanes[anchor.identifier] {
                existingNode.enumerateChildNodes { child, _ in
                    if let plane = child.geometry as? SCNPlane {
                        plane.width = CGFloat(planeAnchor.planeExtent.width)
                        plane.height = CGFloat(planeAnchor.planeExtent.height)
                    }
                    child.position = SCNVector3(planeAnchor.center.x, child.position.y, planeAnchor.center.z)
                }
            }
        }
    }
    
    nonisolated func renderer(_ renderer: any SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        Task { @MainActor in
            detectedPlanes.removeValue(forKey: anchor.identifier)
            detectedPlaneCount = detectedPlanes.count
        }
    }
}

// MARK: - ARSessionDelegate
extension TableScapeARManager: ARSessionDelegate {
    
    nonisolated func session(_ session: ARSession, didFailWithError error: any Error) {
        Task { @MainActor in
            arState = .error(error.localizedDescription)
            coachingMessage = "AR Error: \(error.localizedDescription)"
        }
    }
    
    nonisolated func sessionWasInterrupted(_ session: ARSession) {
        Task { @MainActor in
            coachingMessage = "Session interrupted"
        }
    }
    
    nonisolated func sessionInterruptionEnded(_ session: ARSession) {
        Task { @MainActor in
            startSession()
        }
    }
}
