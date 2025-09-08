//
//  ChallengeService.swift
//  FitFuelQuest
//
//  Created by IGOR on 08/09/2025.
//

import Foundation

class ChallengeService {
    private let challenges: [Challenge]
    
    init() {
        self.challenges = ChallengeService.loadChallengesFromJSON()
    }
    
    func getAllChallenges() -> [Challenge] {
        return challenges
    }
    
    func getChallengeById(_ id: UUID) -> Challenge? {
        return challenges.first { $0.id == id }
    }
    
    func getChallengesByType(_ type: Challenge.ChallengeType) -> [Challenge] {
        return challenges.filter { $0.type == type }
    }
    
    func getChallengesByDifficulty(_ difficulty: Challenge.Difficulty) -> [Challenge] {
        return challenges.filter { $0.difficulty == difficulty }
    }
    
    func getUnlockedChallenges() -> [Challenge] {
        return challenges.filter { $0.isUnlocked }
    }
    
    func getChallengesForLevel(_ level: Int) -> [Challenge] {
        return challenges.filter { $0.requiredLevel <= level }
    }
    
    func getDailyChallenges() -> [Challenge] {
        return challenges.filter { $0.type == .daily }
    }
    
    func getQuickChallenges(maxDuration: Int = 15) -> [Challenge] {
        return challenges.filter { $0.duration <= maxDuration }
    }
    
    private static func loadChallengesFromJSON() -> [Challenge] {
        // First try to load from JSON file, fallback to sample data
        if let url = Bundle.main.url(forResource: "Challenges", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let challenges = try? JSONDecoder().decode([Challenge].self, from: data) {
            return challenges
        }
        
        // Fallback to expanded sample data
        return [
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
                    "Repeat for target count",
                    "Keep a steady rhythm and breathe normally"
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
                    "Lie on your back, knees bent at 90 degrees",
                    "Place hands behind head lightly",
                    "Engage core and lift shoulders off ground",
                    "Focus on using abs, not neck muscles",
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
                    "Continue for the full duration",
                    "End with three deep breaths"
                ]
            ),
            Challenge(
                name: "Power Walk",
                description: "Get your heart pumping with a brisk walk",
                type: .cardio,
                difficulty: .beginner,
                duration: 20,
                targetValue: 2000,
                unit: "steps",
                points: 25,
                isCompleted: false,
                isUnlocked: true,
                requiredLevel: 1,
                instructions: [
                    "Start with a 2-minute warm-up walk",
                    "Increase pace to brisk walking",
                    "Maintain good posture throughout",
                    "Swing arms naturally",
                    "Keep a pace where you can still talk",
                    "Cool down with slow walking for 2 minutes"
                ]
            ),
            Challenge(
                name: "Flexibility Flow",
                description: "Improve flexibility with gentle stretching",
                type: .flexibility,
                difficulty: .beginner,
                duration: 12,
                targetValue: 8,
                unit: "stretches",
                points: 18,
                isCompleted: false,
                isUnlocked: true,
                requiredLevel: 2,
                instructions: [
                    "Start with gentle neck rolls",
                    "Stretch arms across chest and overhead",
                    "Do forward fold for hamstrings",
                    "Perform hip circles and leg swings",
                    "Hold each stretch for 30 seconds",
                    "Breathe deeply throughout"
                ]
            ),
            Challenge(
                name: "Strength Builder",
                description: "Build functional strength with bodyweight exercises",
                type: .strength,
                difficulty: .intermediate,
                duration: 18,
                targetValue: 20,
                unit: "push-ups",
                points: 30,
                isCompleted: false,
                isUnlocked: false,
                requiredLevel: 4,
                instructions: [
                    "Start in plank position, hands under shoulders",
                    "Lower body until chest nearly touches ground",
                    "Push back up to starting position",
                    "Keep body in straight line throughout",
                    "Modify on knees if needed",
                    "Rest 30 seconds between sets of 5"
                ]
            ),
            Challenge(
                name: "Hydration Hero",
                description: "Stay hydrated throughout the day",
                type: .daily,
                difficulty: .beginner,
                duration: 1440, // All day
                targetValue: 8,
                unit: "glasses of water",
                points: 12,
                isCompleted: false,
                isUnlocked: true,
                requiredLevel: 1,
                instructions: [
                    "Start with a glass of water upon waking",
                    "Drink water before each meal",
                    "Keep a water bottle with you",
                    "Set reminders to drink regularly",
                    "Monitor urine color for hydration level",
                    "Aim for 8 glasses throughout the day"
                ]
            ),
            Challenge(
                name: "Stair Climber",
                description: "Use stairs for a quick cardio workout",
                type: .cardio,
                difficulty: .intermediate,
                duration: 8,
                targetValue: 5,
                unit: "flights of stairs",
                points: 22,
                isCompleted: false,
                isUnlocked: false,
                requiredLevel: 3,
                instructions: [
                    "Find a staircase with at least 10 steps",
                    "Warm up with slow stair climbing",
                    "Climb at moderate pace for 2 minutes",
                    "Take stairs two at a time if comfortable",
                    "Use handrail for balance only",
                    "Cool down with slow descent"
                ]
            ),
            Challenge(
                name: "Balance Master",
                description: "Improve balance and stability",
                type: .flexibility,
                difficulty: .intermediate,
                duration: 10,
                targetValue: 60,
                unit: "seconds per leg",
                points: 20,
                isCompleted: false,
                isUnlocked: false,
                requiredLevel: 3,
                instructions: [
                    "Stand on one foot near a wall for safety",
                    "Keep standing leg slightly bent",
                    "Focus eyes on fixed point ahead",
                    "Hold position for target time",
                    "Switch legs and repeat",
                    "Progress to eyes closed when ready"
                ]
            ),
            Challenge(
                name: "Gratitude Practice",
                description: "Cultivate positivity with gratitude reflection",
                type: .mindfulness,
                difficulty: .beginner,
                duration: 8,
                targetValue: 3,
                unit: "things to be grateful for",
                points: 16,
                isCompleted: false,
                isUnlocked: true,
                requiredLevel: 1,
                instructions: [
                    "Find a quiet moment in your day",
                    "Think of three specific things you're grateful for",
                    "Reflect on why each one matters to you",
                    "Feel the positive emotions they bring",
                    "Consider writing them down",
                    "Carry this feeling with you"
                ]
            ),
            Challenge(
                name: "HIIT Blast",
                description: "High-intensity interval training for maximum impact",
                type: .cardio,
                difficulty: .advanced,
                duration: 16,
                targetValue: 4,
                unit: "rounds",
                points: 40,
                isCompleted: false,
                isUnlocked: false,
                requiredLevel: 8,
                instructions: [
                    "Warm up with light movement for 2 minutes",
                    "Do 30 seconds high-intensity exercise",
                    "Rest for 30 seconds",
                    "Repeat for 4 rounds total",
                    "Exercises: burpees, mountain climbers, jump squats",
                    "Cool down with stretching"
                ]
            ),
            Challenge(
                name: "Plank Power",
                description: "Build core strength with plank holds",
                type: .strength,
                difficulty: .advanced,
                duration: 12,
                targetValue: 120,
                unit: "seconds total",
                points: 35,
                isCompleted: false,
                isUnlocked: false,
                requiredLevel: 7,
                instructions: [
                    "Start in forearm plank position",
                    "Keep body in straight line from head to heels",
                    "Engage core and breathe normally",
                    "Hold for as long as possible",
                    "Rest and repeat until target time reached",
                    "Focus on form over duration"
                ]
            )
        ]
    }
}
