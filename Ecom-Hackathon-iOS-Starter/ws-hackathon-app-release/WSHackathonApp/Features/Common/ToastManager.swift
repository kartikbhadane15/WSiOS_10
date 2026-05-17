//
//  ToastManager.swift
//  WSHackathonApp
//

import Foundation
import SwiftUI
import UIKit
import Combine

class ToastManager: ObservableObject {
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    
    private var workItem: DispatchWorkItem?
    
    func show(message: String, duration: TimeInterval = 2.5) {
        workItem?.cancel()
        
        // ensure UI updates are on main thread
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                self.toastMessage = message
                self.showToast = true
            }
            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            let newWorkItem = DispatchWorkItem { [weak self] in
                withAnimation(.spring()) {
                    self?.showToast = false
                }
            }
            
            self.workItem = newWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: newWorkItem)
        }
    }
}
