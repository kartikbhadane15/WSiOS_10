import Foundation
import Combine

@MainActor
class HesitationDetector: ObservableObject {

    @Published var isHesitating: Bool = false

    private var quantityHistory: [String: [Int]] = [:]
    private var cartTimer: Timer?
    private var tabSwitchHistory: [String] = []

    func trigger() {
        guard !isHesitating else { return }
        isHesitating = true
    }

    func recordQuantityChange(for itemID: String, quantity: Int) {
        quantityHistory[itemID, default: []].append(quantity)
        let history = quantityHistory[itemID]!
        if history.count >= 3 {
            let changes = zip(history, history.dropFirst())
                .filter { $0.0 != $0.1 }.count
            if changes >= 2 { trigger() }
        }
    }

    func startCartTimer() {
        cartTimer?.invalidate()
        cartTimer = Timer.scheduledTimer(
            withTimeInterval: 60, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.trigger() }
        }
    }

    func cancelCartTimer() {
        cartTimer?.invalidate()
    }

    func recordTabSwitch(to tab: String) {
        tabSwitchHistory.append(tab)
        let pairs = zip(tabSwitchHistory, tabSwitchHistory.dropFirst())
        let cartHomeTrips = pairs.filter { pair in
            (pair.0 == "cart" && pair.1 == "home") ||
            (pair.0 == "home" && pair.1 == "cart")
        }.count
        if cartHomeTrips >= 3 { trigger() }
    }
}
