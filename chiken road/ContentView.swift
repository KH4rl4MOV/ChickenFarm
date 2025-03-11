import SwiftUI

struct FarmView: View {
    @ObservedObject var viewModel = FarmViewModel()
    @State private var newChickenName = ""
    @State private var showCreateChickenAlert = false
    @State private var showBuyChickenSheet = false
    @State private var buyChickenName = ""

    var body: some View {
        ZStack {
            // Фон для основной части
            Image("main") // Задний фон "main"
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Chicken Farm")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .foregroundColor(.orange)

                if viewModel.chickens.isEmpty {
                    // Экран создания первой курицы
                    ZStack {
                        Image("create_chiken") // Задний фон для создания курочек
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                            .opacity(0.8)

                        VStack {
                            Spacer() // Добавляем Spacer, чтобы поднять элементы вверх

                            Text("Create your first chicken!")
                                .font(.headline)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(10)

                            TextField("Enter chicken name", text: $newChickenName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(10)

                            Button(action: {
                                viewModel.createFirstChicken(name: newChickenName)
                                newChickenName = ""
                            }) {
                                Text("Create Chicken")
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.bottom, 20)

                            Spacer() // Добавляем Spacer, чтобы опустить элементы вниз (если нужно)
                        }
                        .padding()
                    }
                } else {
                    // Основной интерфейс с курицами
                    List {
                        ForEach(viewModel.chickens) { chicken in
                            HStack {
                                Image(chickenImageName(for: chicken.type))
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text(chicken.name)
                                    .font(.headline)
                                Spacer()
                                Text("Age: \(chicken.age)")
                                Text("Health: \(chicken.health)")
                                Button(action: {
                                    viewModel.sellChicken(chickenId: chicken.id)
                                }) {
                                    Text("Sell")
                                        .padding(5)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .listStyle(PlainListStyle())

                    HStack {
                        Button(action: {
                            viewModel.feedChickens()
                        }) {
                            Text("Feed Chickens")
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }

                        Button(action: {
                            withAnimation {
                                viewModel.collectEggs()
                            }
                        }) {
                            Text("Collect Eggs")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .scaleEffect(viewModel.eggsCollected > 0 ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: viewModel.eggsCollected)
                        }

                        Button(action: {
                            viewModel.sellEggs()
                        }) {
                            Text("Sell Eggs")
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 10)

                    HStack {
                        Text("Eggs: \(viewModel.eggsCollected)")
                            .font(.headline)
                            .padding(.horizontal, 10)

                        Text("Golden Eggs: \(viewModel.goldenEggsCollected)")
                            .font(.headline)
                            .padding(.horizontal, 10)

                        HStack {
                            Image("coin") // Заменяем символ монетки на изображение
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("\(viewModel.money)")
                                .font(.headline)
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding(.vertical, 10)

                    Button(action: {
                        viewModel.showUpgradesMenu = true
                    }) {
                        Text("Buy Upgrades")
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $viewModel.showUpgradesMenu) {
                        UpgradesMenuView(viewModel: viewModel)
                    }
                    .padding(.vertical, 10)

                    Button(action: {
                        showBuyChickenSheet = true
                    }) {
                        Text("Buy Chicken")
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $showBuyChickenSheet) {
                        BuyChickenView(isPresented: $showBuyChickenSheet, chickenName: $buyChickenName) { name in
                            let success = viewModel.buyChicken(name: name)
                            if !success {
                                viewModel.showNotEnoughMoneyAlert = true
                            } else {
                                buyChickenName = ""
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .alert(item: $viewModel.deadChickenAlert) { alert in
            Alert(
                title: Text("Chicken Died"),
                message: Text("Your chicken \(alert.name) has died."),
                primaryButton: .default(Text("OK")) {
                    viewModel.confirmChickenDeath(chickenId: alert.chickenId)
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $viewModel.showNotEnoughMoneyAlert) {
            Alert(
                title: Text("Not Enough Money"),
                message: Text("You don't have enough money to buy this."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct UpgradesMenuView: View {
    @ObservedObject var viewModel: FarmViewModel

    var body: some View {
        ZStack {
            // Фон для меню улучшений
            Image("upgrade") // Задний фон для меню улучшений
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8)

            VStack {
                Text("Upgrades")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)

                Button(action: {
                    viewModel.buyMaxChickensUpgrade()
                }) {
                    HStack {
                        Image("coin") // Заменяем символ монетки на изображение
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Max Chickens (+5) - \(viewModel.upgradeCost)")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.vertical, 10)

                Button(action: {
                    viewModel.buyFoodEfficiencyUpgrade()
                }) {
                    HStack {
                        Image("coin") // Заменяем символ монетки на изображение
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Food Efficiency (Lvl \(viewModel.foodEfficiency)) - \(viewModel.foodUpgradeCost)")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.vertical, 10)

                Button(action: {
                    viewModel.buyEggValueUpgrade()
                }) {
                    HStack {
                        Image("coin") // Заменяем символ монетки на изображение
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Egg Value (x\(viewModel.eggValueMultiplier)) - \(viewModel.eggValueUpgradeCost)")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.vertical, 10)

                Button(action: {
                    viewModel.showUpgradesMenu = false
                }) {
                    Text("Close")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical, 10)
            }
            .padding()
        }
    }
}

struct BuyChickenView: View {
    @Binding var isPresented: Bool
    @Binding var chickenName: String
    var onBuy: (String) -> Void

    var body: some View {
        ZStack {
            // Фон для окна покупки курицы
            Image("create_chiken") // Задний фон для создания курочек
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8)

            VStack {
                Text("Buy Chicken")
                    .font(.headline)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)

                TextField("Enter chicken name", text: $chickenName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)

                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        onBuy(chickenName)
                        isPresented = false
                    }) {
                        Text("Buy")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }
}

func chickenImageName(for type: ChickenType) -> String {
    switch type {
    case .standard:
        return "def"
    case .lessFood:
        return "less"
    case .doubleEggs:
        return "2"
    case .tripleEggs:
        return "3"
    case .goldenEggs:
        return "gold"
    }
}
