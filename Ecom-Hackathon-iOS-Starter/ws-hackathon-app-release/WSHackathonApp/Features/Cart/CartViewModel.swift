import Foundation
import Combine

@MainActor
final class CartViewModel: ObservableObject {

    @Published private(set) var items: [CartItem] = []
    @Published var isGift: Bool = false
    @Published var giftMessage: String = ""
    @Published var includesGiftWrap: Bool = false

    @Published var hesitationCardState: HesitationCardState = .hidden

    enum HesitationCardState: Equatable {
        case hidden
        case itemBased(CartItem)
        case timeBased

        static func == (lhs: HesitationCardState, rhs: HesitationCardState) -> Bool {
            switch (lhs, rhs) {
            case (.hidden, .hidden): return true
            case (.timeBased, .timeBased): return true
            case (.itemBased(let l), .itemBased(let r)): return l.id == r.id
            default: return false
            }
        }
    }

    private var cartTimerTask: Task<Void, Never>?
    private var hasShownTimeBasedCardThisSession = false

    private var cancellable: AnyCancellable?
    private var repository: CartRepository?

    func bind(repository: CartRepository) {
        self.repository = repository

        cancellable = repository.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedItems in
                guard let self = self else { return }
                self.items = updatedItems
            }
    }

    var isEmptyCart: Bool { items.isEmpty }

    var baseTotal: Double { repository?.totalPrice ?? 0 }
    var giftWrapPrice: Double { includesGiftWrap ? 2.00 : 0.00 }
    var finalTotal: Double { baseTotal + giftWrapPrice }
    var totalPriceText: String { String(format: "$%.2f", finalTotal) }
    var baseTotalText: String { String(format: "$%.2f", baseTotal) }

    func removeItem(_ item: CartItem) {
        if item.quantity <= 1 {
            triggerItemBasedCard(for: item)
        }
        repository?.remove(productId: item.id)
    }

    func add(_ item: CartItem) {
        repository?.increaseQuantity(productId: item.id)
    }

    func addBundleItems(_ bundleItems: [BundleItem]) {
        for item in bundleItems {
            repository?.addProduct(id: item.id, title: item.name, price: item.originalPrice, path: item.imageName)
        }
    }

    func addSingleBundleItem(_ item: BundleItem) {
        repository?.addProduct(id: item.id, title: item.name, price: item.originalPrice, path: item.imageName)
    }

    func clearCart() { repository?.clearAll() }

    // MARK: - Hesitation Card

    func startCartTimer() {
        cartTimerTask?.cancel()
        cartTimerTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 60_000_000_000)
            await MainActor.run {
                self?.triggerTimeBasedCard()
            }
        }
    }

    func cancelCartTimer() {
        cartTimerTask?.cancel()
        cartTimerTask = nil
    }

    func didTapCheckout() {
        cancelCartTimer()
        dismissHesitationCard()
    }

    func resetSession() {
        dismissHesitationCard()
        cancelCartTimer()
        hasShownTimeBasedCardThisSession = false
    }

    func dismissHesitationCard() {
        hesitationCardState = .hidden
    }

    private func triggerItemBasedCard(for item: CartItem) {
        guard hesitationCardState != .itemBased(item) else { return }
        hesitationCardState = .itemBased(item)
    }

    private func triggerTimeBasedCard() {
        guard hesitationCardState == .hidden, !hasShownTimeBasedCardThisSession else { return }
        hasShownTimeBasedCardThisSession = true
        hesitationCardState = .timeBased
    }
}
