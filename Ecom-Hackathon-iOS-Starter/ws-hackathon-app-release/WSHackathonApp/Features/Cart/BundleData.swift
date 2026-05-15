import Foundation

struct BundleItem: Identifiable {
    let id: String
    let name: String
    let imageName: String
    let originalPrice: Double
    var inStock: Bool = true
}

struct ProductBundle {
    let items: [BundleItem]
    let fallbacks: [BundleItem]
}

let productBundles: [String: ProductBundle] = [
    // Williams Sonoma End-Grain Cutting Board, Acacia
    // Pair with: board oil (care), ceramic bowl (prep/store), olive oil (bread board), lazy susan (serve)
    "2505456": ProductBundle(
        items: [
            BundleItem(id: "6121370", name: "Williams Sonoma Board Oil", imageName: "/img27m.jpg", originalPrice: 10.95),
            BundleItem(id: "6247040", name: "Hold Everything Lidded Ceramic Bowl, Ashwood, 12\"", imageName: "/img64m.jpg", originalPrice: 89.95),
            BundleItem(id: "5001660", name: "Williams Sonoma Organic House Extra Virgin Olive Oil", imageName: "/img4m.jpg", originalPrice: 38.95),
            BundleItem(id: "8227593", name: "Hold Everything Lazy Susan, Small, Walnut Finish, 10\"", imageName: "/img153m.jpg", originalPrice: 59.95)
        ],
        fallbacks: [
            BundleItem(id: "181543", name: "Staub Enameled Cast Iron Traditional Deep Skillet, 8 1/2\", Citron", imageName: "/img5m.jpg", originalPrice: 180.00)
        ]
    ),
    // Williams Sonoma Board Oil
    // Pair with: cutting board (primary use), lazy susan (same wood care), bowl (kitchen companion)
    "6121370": ProductBundle(
        items: [
            BundleItem(id: "2505456", name: "Williams Sonoma End-Grain Cutting Board, Acacia, 15\" X 20\"", imageName: "/img17m.jpg", originalPrice: 129.95),
            BundleItem(id: "8227593", name: "Hold Everything Lazy Susan, Small, Walnut Finish, 10\"", imageName: "/img153m.jpg", originalPrice: 59.95),
            BundleItem(id: "6247040", name: "Hold Everything Lidded Ceramic Bowl, Ashwood, 12\"", imageName: "/img64m.jpg", originalPrice: 89.95)
        ],
        fallbacks: [
            BundleItem(id: "5001660", name: "Williams Sonoma Organic House Extra Virgin Olive Oil", imageName: "/img4m.jpg", originalPrice: 38.95)
        ]
    ),
    // Hold Everything Lidded Ceramic Bowl, Ashwood
    // Pair with: lazy susan (same brand, display piece), cutting board (prep→serve), dutch oven (cook→serve)
    "6247040": ProductBundle(
        items: [
            BundleItem(id: "8227593", name: "Hold Everything Lazy Susan, Small, Walnut Finish, 10\"", imageName: "/img153m.jpg", originalPrice: 59.95),
            BundleItem(id: "2505456", name: "Williams Sonoma End-Grain Cutting Board, Acacia, 15\" X 20\"", imageName: "/img17m.jpg", originalPrice: 129.95),
            BundleItem(id: "2453926", name: "Staub Enameled Cast Iron Round Dutch Oven, 7-Qt., Basil", imageName: "/img83m.jpg", originalPrice: 470.00),
            BundleItem(id: "6121370", name: "Williams Sonoma Board Oil", imageName: "/img27m.jpg", originalPrice: 10.95)
        ],
        fallbacks: [
            BundleItem(id: "181543", name: "Staub Enameled Cast Iron Traditional Deep Skillet, 8 1/2\", Citron", imageName: "/img5m.jpg", originalPrice: 180.00)
        ]
    ),
    // Apilco Tradition Porcelain Cup & Saucer
    // Pair with: coffee maker (brew→drink), martini glasses (entertaining), lazy susan (coffee station)
    "1341411": ProductBundle(
        items: [
            BundleItem(id: "8381456", name: "Cuisinart PerfecTemp Programmable Coffee Maker with Glass Carafe, 14-cup", imageName: "/img122m.jpg", originalPrice: 119.95),
            BundleItem(id: "9670912", name: "Dorset Martini Glasses, Set of 4", imageName: "/img236m.jpg", originalPrice: 179.80),
            BundleItem(id: "8227593", name: "Hold Everything Lazy Susan, Small, Walnut Finish, 10\"", imageName: "/img153m.jpg", originalPrice: 59.95)
        ],
        fallbacks: [
            BundleItem(id: "6247040", name: "Hold Everything Lidded Ceramic Bowl, Ashwood, 12\"", imageName: "/img64m.jpg", originalPrice: 89.95)
        ]
    ),
    // Staub Enameled Cast Iron Round Dutch Oven, 7-Qt., Basil
    // Pair with: deep skillet (same brand/collection/material), cutting board (prep), olive oil (cook), bowl (serve)
    "2453926": ProductBundle(
        items: [
            BundleItem(id: "181543", name: "Staub Enameled Cast Iron Traditional Deep Skillet, 8 1/2\", Citron", imageName: "/img5m.jpg", originalPrice: 180.00),
            BundleItem(id: "2505456", name: "Williams Sonoma End-Grain Cutting Board, Acacia, 15\" X 20\"", imageName: "/img17m.jpg", originalPrice: 129.95),
            BundleItem(id: "5001660", name: "Williams Sonoma Organic House Extra Virgin Olive Oil", imageName: "/img4m.jpg", originalPrice: 38.95),
            BundleItem(id: "6247040", name: "Hold Everything Lidded Ceramic Bowl, Ashwood, 12\"", imageName: "/img64m.jpg", originalPrice: 89.95)
        ],
        fallbacks: [
            BundleItem(id: "6121370", name: "Williams Sonoma Board Oil", imageName: "/img27m.jpg", originalPrice: 10.95)
        ]
    ),
    // Cuisinart PerfecTemp Programmable Coffee Maker
    // Pair with: cup & saucer (drink coffee), martini glasses (entertaining), lazy susan (station organize)
    "8381456": ProductBundle(
        items: [
            BundleItem(id: "1341411", name: "Apilco Tradition Porcelain Cup & Saucer, Each", imageName: "/img95m.jpg", originalPrice: 34.95),
            BundleItem(id: "9670912", name: "Dorset Martini Glasses, Set of 4", imageName: "/img236m.jpg", originalPrice: 179.80),
            BundleItem(id: "8227593", name: "Hold Everything Lazy Susan, Small, Walnut Finish, 10\"", imageName: "/img153m.jpg", originalPrice: 59.95)
        ],
        fallbacks: [
            BundleItem(id: "6247040", name: "Hold Everything Lidded Ceramic Bowl, Ashwood, 12\"", imageName: "/img64m.jpg", originalPrice: 89.95),
            BundleItem(id: "5001660", name: "Williams Sonoma Organic House Extra Virgin Olive Oil", imageName: "/img4m.jpg", originalPrice: 38.95)
        ]
    ),
    // Hold Everything Lazy Susan, Small, Walnut Finish
    // Pair with: lidded bowl (same brand, sits on susan), cutting board (counterpair), martini glasses (bar cart)
    "8227593": ProductBundle(
        items: [
            BundleItem(id: "6247040", name: "Hold Everything Lidded Ceramic Bowl, Ashwood, 12\"", imageName: "/img64m.jpg", originalPrice: 89.95),
            BundleItem(id: "2505456", name: "Williams Sonoma End-Grain Cutting Board, Acacia, 15\" X 20\"", imageName: "/img17m.jpg", originalPrice: 129.95),
            BundleItem(id: "9670912", name: "Dorset Martini Glasses, Set of 4", imageName: "/img236m.jpg", originalPrice: 179.80)
        ],
        fallbacks: [
            BundleItem(id: "5001660", name: "Williams Sonoma Organic House Extra Virgin Olive Oil", imageName: "/img4m.jpg", originalPrice: 38.95),
            BundleItem(id: "6121370", name: "Williams Sonoma Board Oil", imageName: "/img27m.jpg", originalPrice: 10.95)
        ]
    ),
    // Williams Sonoma Organic House Extra Virgin Olive Oil
    // Pair with: cutting board (bread+oil), dutch oven (cook), skillet (fry), bowl (serve)
    "5001660": ProductBundle(
        items: [
            BundleItem(id: "2505456", name: "Williams Sonoma End-Grain Cutting Board, Acacia, 15\" X 20\"", imageName: "/img17m.jpg", originalPrice: 129.95),
            BundleItem(id: "2453926", name: "Staub Enameled Cast Iron Round Dutch Oven, 7-Qt., Basil", imageName: "/img83m.jpg", originalPrice: 470.00),
            BundleItem(id: "181543", name: "Staub Enameled Cast Iron Traditional Deep Skillet, 8 1/2\", Citron", imageName: "/img5m.jpg", originalPrice: 180.00),
            BundleItem(id: "6247040", name: "Hold Everything Lidded Ceramic Bowl, Ashwood, 12\"", imageName: "/img64m.jpg", originalPrice: 89.95)
        ],
        fallbacks: [
            BundleItem(id: "8227593", name: "Hold Everything Lazy Susan, Small, Walnut Finish, 10\"", imageName: "/img153m.jpg", originalPrice: 59.95)
        ]
    ),
    // Dorset Martini Glasses, Set of 4
    // Pair with: cup & saucer (tabletop), coffee maker (hospitality), lazy susan (bar cart), bowl (appetizers)
    "9670912": ProductBundle(
        items: [
            BundleItem(id: "1341411", name: "Apilco Tradition Porcelain Cup & Saucer, Each", imageName: "/img95m.jpg", originalPrice: 34.95),
            BundleItem(id: "8381456", name: "Cuisinart PerfecTemp Programmable Coffee Maker with Glass Carafe, 14-cup", imageName: "/img122m.jpg", originalPrice: 119.95),
            BundleItem(id: "8227593", name: "Hold Everything Lazy Susan, Small, Walnut Finish, 10\"", imageName: "/img153m.jpg", originalPrice: 59.95),
            BundleItem(id: "6247040", name: "Hold Everything Lidded Ceramic Bowl, Ashwood, 12\"", imageName: "/img64m.jpg", originalPrice: 89.95)
        ],
        fallbacks: [
            BundleItem(id: "2505456", name: "Williams Sonoma End-Grain Cutting Board, Acacia, 15\" X 20\"", imageName: "/img17m.jpg", originalPrice: 129.95)
        ]
    ),
    // Staub Enameled Cast Iron Traditional Deep Skillet, 8 1/2", Citron
    // Pair with: dutch oven (same brand/collection), cutting board (prep), olive oil (cook), bowl (serve)
    "181543": ProductBundle(
        items: [
            BundleItem(id: "2453926", name: "Staub Enameled Cast Iron Round Dutch Oven, 7-Qt., Basil", imageName: "/img83m.jpg", originalPrice: 470.00),
            BundleItem(id: "2505456", name: "Williams Sonoma End-Grain Cutting Board, Acacia, 15\" X 20\"", imageName: "/img17m.jpg", originalPrice: 129.95),
            BundleItem(id: "5001660", name: "Williams Sonoma Organic House Extra Virgin Olive Oil", imageName: "/img4m.jpg", originalPrice: 38.95),
            BundleItem(id: "6247040", name: "Hold Everything Lidded Ceramic Bowl, Ashwood, 12\"", imageName: "/img64m.jpg", originalPrice: 89.95)
        ],
        fallbacks: [
            BundleItem(id: "6121370", name: "Williams Sonoma Board Oil", imageName: "/img27m.jpg", originalPrice: 10.95)
        ]
    )
]

func getBundleItems(for productId: String) -> [BundleItem] {
    guard let bundle = productBundles[productId] else { return [] }
    var result: [BundleItem] = []
    var fallbackPool = bundle.fallbacks
    for item in bundle.items {
        if item.inStock {
            result.append(item)
        } else if !fallbackPool.isEmpty {
            let fallback = fallbackPool.removeFirst()
            if fallback.inStock {
                result.append(fallback)
            }
        }
    }
    return result
}

func getMergedBundleItems(for productIds: [String]) -> [BundleItem] {
    var result: [BundleItem] = []
    var seenIds: Set<String> = []
    for productId in productIds {
        let items = getBundleItems(for: productId)
        for item in items {
            if !seenIds.contains(item.id) {
                result.append(item)
                seenIds.insert(item.id)
            }
        }
    }
    return result
}
