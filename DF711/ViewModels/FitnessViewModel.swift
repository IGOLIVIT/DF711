//
//  FitnessViewModel.swift
//  FitFuelQuest
//
//  Created by IGOR on 08/09/2025.
//

import Foundation

class FitnessViewModel: ObservableObject {
    @Published var challenges: [Challenge] = []
    @Published var availableChallenges: [Challenge] = []
    @Published var completedChallenges: [Challenge] = []
    @Published var currentChallenge: Challenge?
    @Published var selectedDifficulty: Challenge.Difficulty = .beginner
    @Published var selectedType: Challenge.ChallengeType = .cardio
    @Published var isPerformingChallenge: Bool = false
    @Published var challengeProgress: Double = 0.0
    @Published var timeRemaining: Int = 0
    
    private let challengeService = ChallengeService()
    private var challengeTimer: Timer?
    
    init() {
        loadChallenges()
    }
    
    func loadChallenges() {
        challenges = challengeService.getAllChallenges()
        updateChallengeLists()
    }
    
    func startChallenge(_ challenge: Challenge) {
        currentChallenge = challenge
        isPerformingChallenge = true
        challengeProgress = 0.0
        timeRemaining = challenge.duration * 60 // Convert to seconds
        
        startTimer()
    }
    
    func completeChallenge() {
        guard let challenge = currentChallenge else { return }
        
        stopTimer()
        
        // Mark challenge as completed
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            var updatedChallenge = challenge
            // Note: In a real app, you'd update the backend here
            challenges[index] = updatedChallenge
        }
        
        updateChallengeLists()
        resetChallengeState()
    }
    
    func cancelChallenge() {
        stopTimer()
        resetChallengeState()
    }
    
    func getChallengesByType(_ type: Challenge.ChallengeType) -> [Challenge] {
        return availableChallenges.filter { $0.type == type }
    }
    
    func getChallengesByDifficulty(_ difficulty: Challenge.Difficulty) -> [Challenge] {
        return availableChallenges.filter { $0.difficulty == difficulty }
    }
    
    func getDailyChallenges() -> [Challenge] {
        return availableChallenges.filter { $0.type == .daily }
    }
    
    func getQuickChallenges(maxDuration: Int = 10) -> [Challenge] {
        return availableChallenges.filter { $0.duration <= maxDuration }
    }
    
    func canUnlockChallenge(_ challenge: Challenge, userLevel: Int) -> Bool {
        return userLevel >= challenge.requiredLevel
    }
    
    func getNextChallengeToUnlock(userLevel: Int) -> Challenge? {
        let lockedChallenges = challenges.filter { !$0.isUnlocked }
        return lockedChallenges
            .filter { canUnlockChallenge($0, userLevel: userLevel) }
            .sorted { $0.requiredLevel < $1.requiredLevel }
            .first
    }
    
    func getChallengeProgress(userLevel: Int) -> (completed: Int, available: Int, total: Int) {
        let availableForLevel = challenges.filter { $0.requiredLevel <= userLevel }
        let completed = completedChallenges.count
        return (completed, availableForLevel.count, challenges.count)
    }
    
    func getTotalPointsEarned() -> Int {
        return completedChallenges.reduce(0) { $0 + $1.points }
    }
    
    func getWeeklyProgress() -> [Int] {
        // Return mock data for weekly challenge completion
        // In a real app, this would track actual completion dates
        return [3, 5, 2, 4, 6, 3, 4] // Challenges completed each day of the week
    }
    
    func getStreakCount() -> Int {
        // Mock streak count - in real app would calculate based on completion dates
        return 7
    }
    
    func getFavoriteExerciseType() -> Challenge.ChallengeType {
        let typeCount = Dictionary(grouping: completedChallenges) { $0.type }
            .mapValues { $0.count }
        
        return typeCount.max(by: { $0.value < $1.value })?.key ?? .cardio
    }
    
    private func updateChallengeLists() {
        availableChallenges = challenges.filter { $0.isUnlocked && !$0.isCompleted }
        completedChallenges = challenges.filter { $0.isCompleted }
    }
    
    private func startTimer() {
        challengeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                self.challengeProgress = 1.0 - (Double(self.timeRemaining) / Double((self.currentChallenge?.duration ?? 1) * 60))
            } else {
                self.completeChallenge()
            }
        }
    }
    
    private func stopTimer() {
        challengeTimer?.invalidate()
        challengeTimer = nil
    }
    
    private func resetChallengeState() {
        currentChallenge = nil
        isPerformingChallenge = false
        challengeProgress = 0.0
        timeRemaining = 0
    }
    
    deinit {
        stopTimer()
    }
}
