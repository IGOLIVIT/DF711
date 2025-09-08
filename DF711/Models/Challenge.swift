//
//  Challenge.swift
//  FitFuelQuest
//
//  Created by IGOR on 08/09/2025.
//

import Foundation

struct Challenge: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let type: ChallengeType
    let difficulty: Difficulty
    let duration: Int // in minutes
    let targetValue: Int // steps, reps, minutes, etc.
    let unit: String
    let points: Int
    let isCompleted: Bool
    let isUnlocked: Bool
    let requiredLevel: Int
    let instructions: [String]
    
    enum ChallengeType: String, CaseIterable, Codable {
        case cardio = "Cardio"
        case strength = "Strength"
        case flexibility = "Flexibility"
        case mindfulness = "Mindfulness"
        case daily = "Daily Activity"
    }
    
    enum Difficulty: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
}

extension Challenge {
    static let sampleChallenges = [
        Challenge(
            name: "Morning Energizer",
            description: "Start your day with a quick cardio boost",
            type: .cardio,
            difficulty: .beginner,
            duration: 10,
            targetValue: 50,
            unit: "jumping jacks",
            points: 10,
            isCompleted: false,
            isUnlocked: true,
            requiredLevel: 1,
            instructions: [
                "Stand with feet together, arms at sides",
                "Jump while spreading legs shoulder-width apart",
                "Simultaneously raise arms overhead",
                "Jump back to starting position",
                "Repeat for target count"
            ]
        ),
        Challenge(
            name: "Core Crusher",
            description: "Strengthen your core with this focused workout",
            type: .strength,
            difficulty: .intermediate,
            duration: 15,
            targetValue: 30,
            unit: "crunches",
            points: 20,
            isCompleted: false,
            isUnlocked: false,
            requiredLevel: 5,
            instructions: [
                "Lie on your back, knees bent",
                "Place hands behind head lightly",
                "Engage core and lift shoulders off ground",
                "Lower back down with control",
                "Repeat for target count"
            ]
        ),
        Challenge(
            name: "Zen Moment",
            description: "Take a mindful break to center yourself",
            type: .mindfulness,
            difficulty: .beginner,
            duration: 5,
            targetValue: 5,
            unit: "minutes",
            points: 15,
            isCompleted: false,
            isUnlocked: true,
            requiredLevel: 1,
            instructions: [
                "Find a quiet, comfortable place to sit",
                "Close your eyes and focus on your breath",
                "Notice thoughts without judgment",
                "Return attention to breathing when mind wanders",
                "Continue for the full duration"
            ]
        )
    ]
}
