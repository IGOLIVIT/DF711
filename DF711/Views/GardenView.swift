//
//  GardenView.swift
//  FitFuelQuest
//
//  Created by IGOR on 08/09/2025.
//

import SwiftUI

struct GardenView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @State private var showingPlantShop = false
    @State private var selectedPlantSlot: Int?
    @State private var showingPlantingAlert = false
    
    // Garden grid - 3x4 = 12 slots
    private let gardenRows = 4
    private let gardenCols = 3
    private let slotSize: CGFloat = 80
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Garden info header
                        gardenInfoCard
                        
                        // Garden grid area
                        gardenGridView
                        
                        // Actions
                        gardenActionsView
                        
                        // Instructions
                        instructionsView
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Garden")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPlantShop) {
                PlantShopView(gameViewModel: gameViewModel)
            }
            .alert("Plant a Seed", isPresented: $showingPlantingAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Plant (10 pts)") {
                    plantSeedInSlot()
                }
            } message: {
                Text("Do you want to plant a new seed in this slot?\nCost: 10 points")
            }
        }
    }
    
    private var gardenInfoCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Garden")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Grow plants by completing fitness challenges")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(activePlantCount)/12")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#3cc45b"))
                    
                    Text("Plants")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            HStack(spacing: 16) {
                InfoBadge(icon: "💰", text: "\(gameViewModel.userPoints) points")
                InfoBadge(icon: "🏆", text: "Level \(gameViewModel.gardenLevel)")
                InfoBadge(icon: "💪", text: "\(gameViewModel.challengesCompleted) workouts")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var gardenGridView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Garden Plot (Tap empty slots to plant)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ForEach(0..<gardenRows, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<gardenCols, id: \.self) { col in
                            let slotIndex = row * gardenCols + col
                            GardenSlot(
                                slotIndex: slotIndex,
                                plant: plantForSlot(slotIndex),
                                slotSize: slotSize,
                                canPlant: gameViewModel.userPoints >= 10
                            ) {
                                selectSlot(slotIndex)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#3cc45b").opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "#3cc45b").opacity(0.3), lineWidth: 2)
                    )
            )
        }
    }
    
    private var gardenActionsView: some View {
        HStack(spacing: 12) {
            ActionButton(
                title: "Water All",
                icon: "💧",
                subtitle: "+5 pts",
                color: Color.blue
            ) {
                waterAllPlants()
            }
            
            ActionButton(
                title: "Buy Seeds",
                icon: "🏪",
                subtitle: "Shop",
                color: Color(hex: "#fcc418")
            ) {
                showingPlantShop = true
            }
        }
    }
    
    private var instructionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Grow Your Garden")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                InstructionRow(
                    step: "1",
                    icon: "💪",
                    text: "Complete fitness challenges to earn points"
                )
                
                InstructionRow(
                    step: "2", 
                    icon: "🌱",
                    text: "Tap empty garden slots to plant seeds (10 pts)"
                )
                
                InstructionRow(
                    step: "3",
                    icon: "💧", 
                    text: "Water your plants regularly for bonus points"
                )
                
                InstructionRow(
                    step: "4",
                    icon: "🏪",
                    text: "Buy special seeds from the shop"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Computed Properties
    private var activePlantCount: Int {
        return gameViewModel.gardenPlants.filter { !$0.emoji.isEmpty }.count
    }
    
    // MARK: - Helper Functions
    private func plantForSlot(_ slotIndex: Int) -> GardenPlant? {
        guard slotIndex < gameViewModel.gardenPlants.count else { return nil }
        let plant = gameViewModel.gardenPlants[slotIndex]
        return plant.emoji.isEmpty ? nil : plant
    }
    
    private func selectSlot(_ slotIndex: Int) {
        if plantForSlot(slotIndex) == nil && gameViewModel.userPoints >= 10 {
            selectedPlantSlot = slotIndex
            showingPlantingAlert = true
        }
    }
    
    private func plantSeedInSlot() {
        guard let slotIndex = selectedPlantSlot, gameViewModel.userPoints >= 10 else { return }
        
        gameViewModel.userPoints -= 10
        
        let plantEmojis = ["🌱", "🌿", "🌾", "🌻", "🌹", "🌺", "🌸", "🌼"]
        let randomPlant = plantEmojis.randomElement() ?? "🌱"
        
        let newPlant = GardenPlant(
            emoji: randomPlant,
            name: plantName(for: randomPlant),
            level: 1,
            position: CGPoint.zero // Not used in grid layout
        )
        
        // Ensure we have enough slots in the array
        while gameViewModel.gardenPlants.count <= slotIndex {
            gameViewModel.gardenPlants.append(GardenPlant(
                emoji: "",
                name: "Empty",
                level: 0,
                position: CGPoint.zero
            ))
        }
        
        gameViewModel.gardenPlants[slotIndex] = newPlant
        gameViewModel.saveProgress()
        selectedPlantSlot = nil
    }
    
    private func waterAllPlants() {
        // Add points for watering
        gameViewModel.userPoints += 5
        gameViewModel.saveProgress()
    }
    
    private func plantName(for emoji: String) -> String {
        switch emoji {
        case "🌱": return "Sprout"
        case "🌿": return "Herb"
        case "🌾": return "Wheat"
        case "🌻": return "Sunflower"
        case "🌹": return "Rose"
        case "🌺": return "Hibiscus"
        case "🌸": return "Cherry"
        case "🌼": return "Daisy"
        default: return "Plant"
        }
    }
}

// MARK: - Supporting Views

struct GardenSlot: View {
    let slotIndex: Int
    let plant: GardenPlant?
    let slotSize: CGFloat
    let canPlant: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(plant != nil ? Color(hex: "#3cc45b").opacity(0.2) : Color.white.opacity(0.1))
                    .frame(width: slotSize, height: slotSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                plant != nil ? Color(hex: "#3cc45b").opacity(0.6) : Color.white.opacity(0.3),
                                lineWidth: 2
                            )
                    )
                
                if let plant = plant, !plant.emoji.isEmpty {
                    Text(plant.emoji)
                        .font(.system(size: 32))
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: canPlant ? "plus.circle.fill" : "plus.circle")
                            .font(.system(size: 20))
                            .foregroundColor(canPlant ? Color(hex: "#3cc45b") : .white.opacity(0.3))
                        
                        Text("10 pts")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(canPlant ? .white.opacity(0.8) : .white.opacity(0.3))
                    }
                }
            }
        }
        .disabled(plant != nil || !canPlant)
    }
}

struct InfoBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 14))
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 28))
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.6), lineWidth: 2)
                    )
            )
        }
    }
}

struct InstructionRow: View {
    let step: String
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(step)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(Color(hex: "#fcc418"))
                )
            
            Text(icon)
                .font(.system(size: 20))
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(2)
            
            Spacer()
        }
    }
}

struct PlantShopView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("🏪 Plant Shop")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        Text("Your Points: \(gameViewModel.userPoints)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#fcc418"))
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 16) {
                            ShopItem(emoji: "🌱", name: "Basic Seed", price: 10, gameViewModel: gameViewModel)
                            ShopItem(emoji: "🌻", name: "Sunflower", price: 25, gameViewModel: gameViewModel)
                            ShopItem(emoji: "🌹", name: "Rose", price: 50, gameViewModel: gameViewModel)
                            ShopItem(emoji: "🌺", name: "Hibiscus", price: 35, gameViewModel: gameViewModel)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct ShopItem: View {
    let emoji: String
    let name: String
    let price: Int
    @ObservedObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 40))
            
            Text(name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text("\(price) pts")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#fcc418"))
            
            Button("Buy") {
                buyPlant()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(canAfford ? Color(hex: "#3cc45b") : Color.gray)
            )
            .foregroundColor(.white)
            .disabled(!canAfford)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var canAfford: Bool {
        gameViewModel.userPoints >= price
    }
    
    private func buyPlant() {
        if canAfford {
            gameViewModel.userPoints -= price
            
            // Find first empty slot
            for i in 0..<12 {
                while gameViewModel.gardenPlants.count <= i {
                    gameViewModel.gardenPlants.append(GardenPlant(
                        emoji: "",
                        name: "Empty",
                        level: 0,
                        position: CGPoint.zero
                    ))
                }
                
                if gameViewModel.gardenPlants[i].emoji.isEmpty {
                    gameViewModel.gardenPlants[i] = GardenPlant(
                        emoji: emoji,
                        name: name,
                        level: 1,
                        position: CGPoint.zero
                    )
                    gameViewModel.saveProgress()
                    break
                }
            }
        }
    }
}


#Preview {
    GardenView(gameViewModel: GameViewModel())
}