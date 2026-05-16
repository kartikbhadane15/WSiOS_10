import Foundation
import Combine

@MainActor
final class CartViewModel: ObservableObject {

    @Published private(set) var items: [CartItem] = []
    @Published var isGift: Bool = false
    @Published var giftMessage: String = ""
    @Published var includesGiftWrap: Bool = false
    @Published var hesitationDetector = HesitationDetector()
    @Published var isShowingCollaborativeCart = false
    @Published var isShowingJoinDialog = false
    @Published var roomCodeToJoin = ""
    @Published var errorMessage: String? = nil

    @Published var hesitationCardState: HesitationCardState = .hidden

    enum HesitationCardState: Equatable {
        case hidden
        case itemBased(CartItem)
        case timeBased
    }

    private var hasShownTimeBasedCardThisSession = false

    private var cancellables = Set<AnyCancellable>()
    private var repository: CartRepository?

    func bind(repository: CartRepository) {
        self.repository = repository

        // Subscribe to hesitation detector
        hesitationDetector.$isHesitating
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHesitating in
                if isHesitating {
                    self?.triggerTimeBasedCard()
                }
            }
            .store(in: &cancellables)

        repository.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedItems in
                guard let self = self else { return }
                self.items = updatedItems
            }
            .store(in: &cancellables)
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
        let newQty = repository?.items.first(where: { $0.id == item.id })?.quantity ?? 0
        hesitationDetector.recordQuantityChange(for: item.id, quantity: newQty)
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
        hesitationDetector.startCartTimer()
    }

    func cancelCartTimer() {
        hesitationDetector.cancelCartTimer()
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
