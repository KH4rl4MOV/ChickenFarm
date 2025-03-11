import SwiftUI

enum ChickenType {
    case standard
    case lessFood
    case doubleEggs
    case tripleEggs
    case goldenEggs
}

struct Chicken: Identifiable {
    let id = UUID()
    var name: String
    var type: ChickenType
    var age: Int
    var health: Int
    var productivity: Int
}


