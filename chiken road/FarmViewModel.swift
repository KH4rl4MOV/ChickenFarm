import Foundation
import Combine

struct DeadChickenAlert: Identifiable {
    let id = UUID()
    let name: String
    let chickenId: UUID
}

class FarmViewModel: ObservableObject {
    @Published var chickens: [Chicken] = []
    @Published var eggsCollected: Int = 0
    @Published var goldenEggsCollected: Int = 0
    @Published var money: Int = 100
    @Published var deadChickenAlert: DeadChickenAlert? = nil
    @Published var maxChickens: Int = 5
    @Published var upgradeCost: Int = 200
    @Published var foodUpgradeCost: Int = 100
    @Published var foodEfficiency: Int = 1
    @Published var eggValueUpgradeCost: Int = 150
    @Published var eggValueMultiplier: Int = 1
    @Published var showUpgradesMenu: Bool = false
    @Published var showNotEnoughMoneyAlert: Bool = false
    
    private var chickenCost: Int = 50
    private var foodCost: Int = 25
    private var cancellables = Set<AnyCancellable>()

    var currentChickenCost: Int {
        return chickenCost
    }

    init() {
        startHealthDecreaseTimer()
        startAgingTimer()
        startRandomEventTimer()
    }

    func createFirstChicken(name: String) {
        let firstChicken = Chicken(name: name, type: .standard, age: 0, health: 100, productivity: 1)
        chickens.append(firstChicken)
    }

    func buyChicken(name: String) -> Bool {
        guard chickens.count < maxChickens else { return false }
        
        let random = Int.random(in: 1...100)
        let newChicken: Chicken

        if random <= 5 {
            newChicken = Chicken(name: name, type: .goldenEggs, age: 0, health: 100, productivity: 1)
        } else if random <= 15 {
            newChicken = Chicken(name: name, type: .tripleEggs, age: 0, health: 100, productivity: 3)
        } else if random <= 30 {
            newChicken = Chicken(name: name, type: .doubleEggs, age: 0, health: 100, productivity: 2)
        } else if random <= 45 {
            newChicken = Chicken(name: name, type: .lessFood, age: 0, health: 100, productivity: 1)
        } else {
            newChicken = Chicken(name: name, type: .standard, age: 0, health: 100, productivity: 1)
        }

        if money >= chickenCost {
            money -= chickenCost
            chickens.append(newChicken)
            chickenCost *= 2
            return true
        } else {
            showNotEnoughMoneyAlert = true
            return false
        }
    }

    func sellChicken(chickenId: UUID) {
        if let index = chickens.firstIndex(where: { $0.id == chickenId }) {
            let chicken = chickens[index]
            money += chickenCost / 4
            chickens.remove(at: index)
        }
    }

    func feedChickens() {
        let totalFoodNeeded = chickens.count
        let totalCost = totalFoodNeeded * foodCost / foodEfficiency

        if money >= totalCost {
            money -= totalCost
            for i in 0..<chickens.count {
                chickens[i].health = min(100, chickens[i].health + 10 * foodEfficiency)
            }
        } else {
            showNotEnoughMoneyAlert = true
        }
    }

    func collectEggs() {
        for chicken in chickens {
            if chicken.type == .goldenEggs {
                goldenEggsCollected += chicken.productivity
            } else {
                eggsCollected += chicken.productivity
            }
        }
    }

    func sellEggs() {
        money += eggsCollected * eggValueMultiplier + goldenEggsCollected * 3 * eggValueMultiplier
        eggsCollected = 0
        goldenEggsCollected = 0
    }

    func buyMaxChickensUpgrade() {
        if money >= upgradeCost {
            money -= upgradeCost
            maxChickens += 5
            upgradeCost *= 2
        } else {
            showNotEnoughMoneyAlert = true
        }
    }

    func buyFoodEfficiencyUpgrade() {
        if money >= foodUpgradeCost {
            money -= foodUpgradeCost
            foodEfficiency += 1
            foodUpgradeCost *= 2
        } else {
            showNotEnoughMoneyAlert = true
        }
    }

    func buyEggValueUpgrade() {
        if money >= eggValueUpgradeCost {
            money -= eggValueUpgradeCost
            eggValueMultiplier += 1
            eggValueUpgradeCost *= 2
        } else {
            showNotEnoughMoneyAlert = true
        }
    }

    private func startHealthDecreaseTimer() {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.decreaseHealth()
            }
            .store(in: &cancellables)
    }

    private func startAgingTimer() {
        Timer.publish(every: 5 * 60, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.ageChickens()
            }
            .store(in: &cancellables)
    }

    private func startRandomEventTimer() {
        Timer.publish(every: 10 * 60, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.randomEvent()
            }
            .store(in: &cancellables)
    }

    private func decreaseHealth() {
        for i in 0..<chickens.count {
            var updatedChicken = chickens[i]
            updatedChicken.health = max(0, chickens[i].health - 1)
            if updatedChicken.health == 0 {
                deadChickenAlert = DeadChickenAlert(name: chickens[i].name, chickenId: chickens[i].id)
            }
            if let index = chickens.firstIndex(where: { $0.id == chickens[i].id }) {
                chickens[index] = updatedChicken
            }
        }
    }

    private func ageChickens() {
        for i in 0..<chickens.count {
            var updatedChicken = chickens[i]
            updatedChicken.age += 1
            if updatedChicken.age >= 5 {
                deadChickenAlert = DeadChickenAlert(name: chickens[i].name, chickenId: chickens[i].id)
            }
            if let index = chickens.firstIndex(where: { $0.id == chickens[i].id }) {
                chickens[index] = updatedChicken
            }
        }
    }

    private func randomEvent() {
        let event = Int.random(in: 1...10)
        if event == 1 {
            // Эпидемия
            for i in 0..<chickens.count {
                chickens[i].health -= 20
            }
        } else if event == 2 {
            // Буря
            eggsCollected = max(0, eggsCollected - 10)
        } else if event == 3 {
            // Счастливый день: куры несут больше яиц
            for i in 0..<chickens.count {
                chickens[i].productivity += 1
            }
        }
    }

    func confirmChickenDeath(chickenId: UUID) {
        chickens.removeAll { $0.id == chickenId }
        deadChickenAlert = nil
    }
}
