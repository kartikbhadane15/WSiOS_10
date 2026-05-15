//
//  TableScapeARViewContainer.swift
//  WSHackathonApp
//
//  UIViewRepresentable bridging ARSCNView into SwiftUI
//

import SwiftUI
import ARKit

struct TableScapeARViewContainer: UIViewRepresentable {
    
    @ObservedObject var arManager: TableScapeARManager
    let onTap: (CGPoint) -> Void
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = arManager.setupARView()
        
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        sceneView.addGestureRecognizer(tapGesture)
        
        // Start AR session after a brief delay for smooth transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            arManager.startSession()
        }
        
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }
    
    class Coordinator: NSObject {
        let onTap: (CGPoint) -> Void
        
        init(onTap: @escaping (CGPoint) -> Void) {
            self.onTap = onTap
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            onTap(location)
        }
    }
}
