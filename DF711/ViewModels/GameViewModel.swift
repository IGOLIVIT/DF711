//
//  GameViewModel.swift
//  FitFuelQuest
//
//  Created by IGOR on 08/09/2025.
//

import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var userLevel: Int = 1
    @Published var userPoints: Int = 0
    @Published var recipesUnlocked: Int = 1
    @Published var challengesCompleted: Int = 0
    @Published var gardenLevel: Int = 1
    @Published var gardenPlants: [GardenPlant] = []
    @Published var dailyStreak: Int = 0
    @Published var lastActiveDate: Date = Date()
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("userLevel") private var storedUserLevel: Int = 1
    @AppStorage("userPoints") private var storedUserPoints: Int = 0
    @AppStorage("recipesUnlocked") private var storedRecipesUnlocked: Int = 1
    @AppStorage("challengesCompleted") private var storedChallengesCompleted: Int = 0
    @AppStorage("gardenLevel") private var storedGardenLevel: Int = 1
    @AppStorage("dailyStreak") private var storedDailyStreak: Int = 0
    
    init() {
        // Load saved data
        userLevel = storedUserLevel
        userPoints = storedUserPoints
        recipesUnlocked = storedRecipesUnlocked
        challengesCompleted = storedChallengesCompleted
        gardenLevel = storedGardenLevel
        dailyStreak = storedDailyStreak
        
        initializeGarden()
        checkDailyStreak()
    }
    
    func completeChallenge(_ challenge: Challenge) {
        userPoints += challenge.points
        challengesCompleted += 1
        
        // Check for level up
        let newLevel = calculateLevel(from: userPoints)
        if newLevel > userLevel {
            userLevel = newLevel
            unlockNewContent()
        }
        
        // Add plant to garden
        addPlantToGarden()
        updateDailyStreak()
        saveProgress()
    }
    
    func unlockRecipe() {
        recipesUnlocked += 1
        saveProgress()
    }
    
    private func calculateLevel(from points: Int) -> Int {
        return max(1, points / 100 + 1)
    }
    
    private func unlockNewContent() {
        // Unlock new recipes based on level
        let newRecipesToUnlock = userLevel - recipesUnlocked
        if newRecipesToUnlock > 0 {
            recipesUnlocked += newRecipesToUnlock
        }
    }
    
    private func addPlantToGarden() {
        let plantTypes = ["🌱", "🌿", "🌾", "🌻", "🌹", "🌺", "🌸", "🌼"]
        let randomPlant = plantTypes.randomElement() ?? "🌱"
        
        let newPlant = GardenPlant(
            emoji: randomPlant,
            name: "Plant \(gardenPlants.count + 1)",
            level: 1,
            position: CGPoint(
                x: Double.random(in: 50...300),
                y: Double.random(in: 100...400)
            )
        )
        
        gardenPlants.append(newPlant)
        
        // Level up garden every 5 plants
        if gardenPlants.count % 5 == 0 {
            gardenLevel += 1
        }
    }
    
    private func initializeGarden() {
        if gardenPlants.isEmpty {
            // Add starter plant
            let starterPlant = GardenPlant(
                emoji: "🌱",
                name: "Starter Sprout",
                level: 1,
                position: CGPoint(x: 175, y: 250)
            )
            gardenPlants.append(starterPlant)
        }
    }
    
    private func checkDailyStreak() {
        let calendar = Calendar.current
        if calendar.isDateInToday(lastActiveDate) {
            // Already active today, maintain streak
            return
        } else if calendar.isDateInYesterday(lastActiveDate) {
            // Continue streak
            dailyStreak += 1
        } else {
            // Reset streak
            dailyStreak = 1
        }
        lastActiveDate = Date()
    }
    
    private func updateDailyStreak() {
        checkDailyStreak()
        storedDailyStreak = dailyStreak
    }
    
    func saveProgress() {
        storedUserLevel = userLevel
        storedUserPoints = userPoints
        storedRecipesUnlocked = recipesUnlocked
        storedChallengesCompleted = challengesCompleted
        storedGardenLevel = gardenLevel
    }
    
    func resetProgress() {
        userLevel = 1
        userPoints = 0
        recipesUnlocked = 1
        challengesCompleted = 0
        gardenLevel = 1
        gardenPlants.removeAll()
        dailyStreak = 0
        hasCompletedOnboarding = false
        
        initializeGarden()
        saveProgress()
    }
}

struct GardenPlant: Identifiable, Codable {
    var id = UUID()
    let emoji: String
    let name: String
    let level: Int
    let position: CGPoint
}
