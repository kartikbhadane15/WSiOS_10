//
//  TableScapeVisionView.swift
//  WSHackathonApp
//
//  Main SwiftUI view for the TableScape Vision AR experience
//

import SwiftUI
import ARKit

struct TableScapeVisionView: View {
    
    let cartItems: [CartItem]
    @Environment(\.dismiss) private var dismiss
    @StateObject private var arManager = TableScapeARManager()
    @State private var showInstructions = true
    @State private var animatePulse = false
    @State private var animateGlow = false
    
    var body: some View {
        ZStack {
            // MARK: - AR Camera View
            if ARWorldTrackingConfiguration.isSupported {
                TableScapeARViewContainer(arManager: arManager) { point in
                    arManager.handleTap(at: point)
                }
                .ignoresSafeArea()
            } else {
                // Fallback for simulator / unsupported devices
                unsupportedDeviceView
            }
            
            // MARK: - UI Overlay
            VStack(spacing: 0) {
                // Top bar
                topBar
                
                Spacer()
                
                // Status coaching message
                if arManager.arState != .initializing {
                    coachingOverlay
                }
                
                // Bottom product strip
                if arManager.arState == .placed {
                    placedItemsStrip
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer().frame(height: 16)
            }
            
            // MARK: - Scanning Animation Overlay
            if arManager.arState == .scanning {
                scanningOverlay
            }
            
            // MARK: - Initial Instructions
            if showInstructions {
                instructionOverlay
                    .transition(.opacity)
            }
        }
        .onAppear {
            arManager.setCartItems(cartItems)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showInstructions = false
                }
            }
        }
        .onDisappear {
            arManager.pauseSession()
        }
        .statusBarHidden(true)
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            // Close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 4)
            }
            
            Spacer()
            
            // Title
            HStack(spacing: 6) {
                Image(systemName: "viewfinder")
                    .font(.system(size: 14, weight: .semibold))
                Text(AppStrings.TableScape.title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.3), radius: 4)
            
            Spacer()
            
            // Reset button
            Button(action: {
                arManager.startSession()
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    // MARK: - Coaching Overlay
    private var coachingOverlay: some View {
        VStack(spacing: 8) {
            // State indicator
            HStack(spacing: 8) {
                stateIcon
                Text(arManager.coachingMessage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 8)
            )
        }
        .padding(.bottom, 12)
        .animation(.easeInOut(duration: 0.3), value: arManager.coachingMessage)
    }
    
    @ViewBuilder
    private var stateIcon: some View {
        switch arManager.arState {
        case .scanning:
            Image(systemName: "dot.radiowaves.left.and.right")
                .foregroundColor(.cyan)
                .symbolEffect(.variableColor.iterative)
        case .surfaceDetected:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .placing:
            ProgressView()
                .tint(.white)
                .scaleEffect(0.8)
        case .placed:
            Image(systemName: "sparkles")
                .foregroundColor(.yellow)
        case .error:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
        default:
            EmptyView()
        }
    }
    
    // MARK: - Scanning Overlay
    private var scanningOverlay: some View {
        VStack {
            Spacer()
            
            ZStack {
                // Scanning crosshair
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.cyan.opacity(0.8), .blue.opacity(0.4), .cyan.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 220, height: 220)
                    .scaleEffect(animatePulse ? 1.05 : 0.95)
                    .opacity(animatePulse ? 0.6 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: animatePulse
                    )
                
                // Corner accents
                ForEach(0..<4, id: \.self) { corner in
                    CornerAccent()
                        .rotationEffect(.degrees(Double(corner) * 90))
                        .frame(width: 220, height: 220)
                }
            }
            .onAppear { animatePulse = true }
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Placed Items Strip
    private var placedItemsStrip: some View {
        VStack(spacing: 8) {
            Text(AppStrings.TableScape.itemsOnTable)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .textCase(.uppercase)
                .tracking(1)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(cartItems) { item in
                        VStack(spacing: 6) {
                            CustomAsyncImage(url: item.imageURL)
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            Text(item.title)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(width: 60)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 10)
        )
        .padding(.horizontal, 16)
    }
    
    // MARK: - Instruction Overlay
    private var instructionOverlay: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // AR Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.cyan.opacity(0.3), .blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(animateGlow ? 1.2 : 1.0)
                        .opacity(animateGlow ? 0.5 : 0.8)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateGlow)
                    
                    Image(systemName: "arkit")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .onAppear { animateGlow = true }
                
                VStack(spacing: 12) {
                    Text(AppStrings.TableScape.title)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(AppStrings.TableScape.instructionSubtitle)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Steps
                VStack(alignment: .leading, spacing: 16) {
                    InstructionStep(number: "1", text: AppStrings.TableScape.step1)
                    InstructionStep(number: "2", text: AppStrings.TableScape.step2)
                    InstructionStep(number: "3", text: AppStrings.TableScape.step3)
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
                
                // Items count
                Text("\(cartItems.count) \(AppStrings.TableScape.itemsReady)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.cyan)
                    .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Unsupported Device View
    private var unsupportedDeviceView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "arkit")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text(AppStrings.TableScape.arNotSupported)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(AppStrings.TableScape.arNotSupportedDesc)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: { dismiss() }) {
                    Text("Go Back")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Supporting Views

struct CornerAccent: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let length: CGFloat = 30
                // Top-left corner accent
                path.move(to: CGPoint(x: 0, y: length))
                path.addLine(to: CGPoint(x: 0, y: 8))
                path.addQuadCurve(
                    to: CGPoint(x: 8, y: 0),
                    control: CGPoint(x: 0, y: 0)
                )
                path.addLine(to: CGPoint(x: length, y: 0))
            }
            .stroke(
                LinearGradient(
                    colors: [.cyan, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 3
            )
        }
    }
}

struct InstructionStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 14) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 28, height: 28)
                .background(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
        }
    }
}
