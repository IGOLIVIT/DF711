//
//  FitnessChallengeView.swift
//  FitFuelQuest
//
//  Created by IGOR on 08/09/2025.
//

import SwiftUI

struct FitnessChallengeView: View {
    @StateObject private var fitnessViewModel = FitnessViewModel()
    @ObservedObject var gameViewModel: GameViewModel
    @State private var selectedChallenge: Challenge?
    @State private var showingChallengeDetail = false
    @State private var currentExerciseTime: Int = 0
    @State private var isExercising = false
    @State private var exerciseTimer: Timer?
    @State private var showingChallengeAlert = false
    @State private var selectedChallengeForAlert: Challenge?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Daily Progress Card
                        dailyProgressCard
                        
                        // Quick Workouts
                        quickWorkoutsSection
                        
                        // Exercise Timer
                        if isExercising {
                            exerciseTimerView
                        }
                        
                        // Available challenges
                        challengesSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Fitness")
            .navigationBarTitleDisplayMode(.large)
            .alert("Complete Challenge", isPresented: $showingChallengeAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Complete") {
                    if let challenge = selectedChallengeForAlert {
                        gameViewModel.completeChallenge(challenge)
                    }
                }
            } message: {
                if let challenge = selectedChallengeForAlert {
                    Text("Are you sure you want to mark '\(challenge.name)' as completed?\n\nYou will earn \(challenge.points) points.")
                }
            }
        }
    }
    
    private var dailyProgressCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Progress")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(gameViewModel.challengesCompleted)/3")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#fcc418"))
            }
            
            // Progress bar
            ProgressView(value: Double(min(gameViewModel.challengesCompleted, 3)), total: 3.0)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#3cc45b")))
                .scaleEffect(x: 1, y: 3, anchor: .center)
            
            HStack(spacing: 20) {
                ProgressItem(icon: "💪", label: "Strength", completed: gameViewModel.challengesCompleted > 0)
                ProgressItem(icon: "❤️", label: "Cardio", completed: gameViewModel.challengesCompleted > 1)
                ProgressItem(icon: "🧘", label: "Mindfulness", completed: gameViewModel.challengesCompleted > 2)
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
    
    private var quickWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Workouts")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                QuickWorkoutCard(
                    title: "Push-ups",
                    duration: "2 min",
                    icon: "💪",
                    color: Color(hex: "#fcc418")
                ) {
                    startExercise(duration: 120, name: "Push-ups")
                }
                
                QuickWorkoutCard(
                    title: "Jumping Jacks",
                    duration: "3 min",
                    icon: "🏃",
                    color: Color(hex: "#3cc45b")
                ) {
                    startExercise(duration: 180, name: "Jumping Jacks")
                }
                
                QuickWorkoutCard(
                    title: "Plank",
                    duration: "1 min",
                    icon: "🏋️",
                    color: Color.orange
                ) {
                    startExercise(duration: 60, name: "Plank")
                }
                
                QuickWorkoutCard(
                    title: "Stretching",
                    duration: "5 min",
                    icon: "🤸",
                    color: Color.purple
                ) {
                    startExercise(duration: 300, name: "Stretching")
                }
            }
        }
    }
    
    private var exerciseTimerView: some View {
        VStack(spacing: 20) {
            Text("Exercise in Progress")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: 1.0 - Double(currentExerciseTime) / 300.0)
                    .stroke(Color(hex: "#3cc45b"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(currentExerciseTime / 60):\(String(format: "%02d", currentExerciseTime % 60))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("remaining")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            HStack(spacing: 16) {
                Button("Pause") {
                    pauseExercise()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(hex: "#fcc418")))
                .foregroundColor(.white)
                
                Button("Complete") {
                    completeExercise()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(hex: "#3cc45b")))
                .foregroundColor(.white)
                
                Button("Stop") {
                    stopExercise()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.red))
                .foregroundColor(.white)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "#3cc45b"), lineWidth: 2)
                )
        )
    }
    
    private var challengesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Challenges")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            ForEach(fitnessViewModel.availableChallenges.prefix(3)) { challenge in
                ChallengeActionCard(challenge: challenge) {
                    selectedChallengeForAlert = challenge
                    showingChallengeAlert = true
                }
            }
        }
    }
    
    // MARK: - Exercise Functions
    private func startExercise(duration: Int, name: String) {
        currentExerciseTime = duration
        isExercising = true
        
        exerciseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if currentExerciseTime > 0 {
                currentExerciseTime -= 1
            } else {
                completeExercise()
            }
        }
    }
    
    private func pauseExercise() {
        exerciseTimer?.invalidate()
    }
    
    private func completeExercise() {
        exerciseTimer?.invalidate()
        isExercising = false
        gameViewModel.challengesCompleted += 1
        gameViewModel.userPoints += 15
        
        // Save progress
        gameViewModel.saveProgress()
    }
    
    private func stopExercise() {
        exerciseTimer?.invalidate()
        isExercising = false
        currentExerciseTime = 0
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Challenges Completed")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(fitnessViewModel.completedChallenges.count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Points Earned")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(fitnessViewModel.getTotalPointsEarned())")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#fcc418"))
                }
            }
            
            // Weekly progress
            weeklyProgressView
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
    
    private var weeklyProgressView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This Week's Progress")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 4) {
                ForEach(0..<7) { day in
                    let progress = fitnessViewModel.getWeeklyProgress()[day]
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(progress > 0 ? Color(hex: "#3cc45b") : Color.white.opacity(0.3))
                            .frame(width: 20, height: CGFloat(max(4, progress * 8)))
                        
                        Text(dayAbbreviation(for: day))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
    }
    
    private var currentChallengeView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Current Challenge")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Cancel") {
                    fitnessViewModel.cancelChallenge()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.red)
            }
            
            if let challenge = fitnessViewModel.currentChallenge {
                VStack(spacing: 12) {
                    Text(challenge.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Progress circle
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: fitnessViewModel.challengeProgress)
                            .stroke(Color(hex: "#3cc45b"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: fitnessViewModel.challengeProgress)
                        
                        VStack {
                            Text("\(fitnessViewModel.timeRemaining / 60):\(String(format: "%02d", fitnessViewModel.timeRemaining % 60))")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("remaining")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Button("Complete Challenge") {
                        fitnessViewModel.completeChallenge()
                        gameViewModel.completeChallenge(challenge)
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(hex: "#3cc45b"))
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "#3cc45b"), lineWidth: 2)
                )
        )
    }
    
    private var challengeCategoriesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Challenge.ChallengeType.allCases, id: \.self) { type in
                    ChallengeTypeButton(
                        type: type,
                        isSelected: fitnessViewModel.selectedType == type
                    ) {
                        fitnessViewModel.selectedType = type
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var challengesGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 16) {
            ForEach(filteredChallenges) { challenge in
                ChallengeCard(
                    challenge: challenge,
                    gameViewModel: gameViewModel,
                    fitnessViewModel: fitnessViewModel
                ) {
                    selectedChallenge = challenge
                    showingChallengeDetail = true
                }
            }
        }
    }
    
    private var filteredChallenges: [Challenge] {
        return fitnessViewModel.getChallengesByType(fitnessViewModel.selectedType)
    }
    
    private func dayAbbreviation(for day: Int) -> String {
        let days = ["S", "M", "T", "W", "T", "F", "S"]
        return days[day]
    }
}

struct ChallengeTypeButton: View {
    let type: Challenge.ChallengeType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(typeEmoji(for: type))
                    .font(.system(size: 16))
                
                Text(type.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? Color(hex: "#3e4464") : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color(hex: "#fcc418") : Color.white.opacity(0.2))
            )
        }
    }
    
    private func typeEmoji(for type: Challenge.ChallengeType) -> String {
        switch type {
        case .cardio: return "❤️"
        case .strength: return "💪"
        case .flexibility: return "🤸"
        case .mindfulness: return "🧘"
        case .daily: return "📅"
        }
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    let gameViewModel: GameViewModel
    let fitnessViewModel: FitnessViewModel
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Challenge icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(typeColor(for: challenge.type).opacity(0.3))
                        .frame(height: 80)
                    
                    if challenge.isUnlocked {
                        Text(typeEmoji(for: challenge.type))
                            .font(.system(size: 32))
                    } else {
                        VStack {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("Level \(challenge.requiredLevel)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(challenge.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("\(challenge.duration) min")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        ChallengeDifficultyBadge(difficulty: challenge.difficulty)
                    }
                    
                    HStack {
                        Text("\(challenge.points) pts")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "#fcc418"))
                        
                        Spacer()
                        
                        if challenge.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#3cc45b"))
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .opacity(challenge.isUnlocked ? 1.0 : 0.7)
        }
        .disabled(!challenge.isUnlocked || challenge.isCompleted || fitnessViewModel.isPerformingChallenge)
    }
    
    private func typeEmoji(for type: Challenge.ChallengeType) -> String {
        switch type {
        case .cardio: return "🏃"
        case .strength: return "💪"
        case .flexibility: return "🤸"
        case .mindfulness: return "🧘"
        case .daily: return "📋"
        }
    }
    
    private func typeColor(for type: Challenge.ChallengeType) -> Color {
        switch type {
        case .cardio: return .red
        case .strength: return Color(hex: "#fcc418")
        case .flexibility: return .purple
        case .mindfulness: return .blue
        case .daily: return Color(hex: "#3cc45b")
        }
    }
}

struct ChallengeDifficultyBadge: View {
    let difficulty: Challenge.Difficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(difficultyColor)
            )
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .beginner: return Color(hex: "#3cc45b")
        case .intermediate: return Color(hex: "#fcc418")
        case .advanced: return Color.red
        }
    }
}

struct ChallengeDetailView: View {
    let challenge: Challenge
    let gameViewModel: GameViewModel
    let fitnessViewModel: FitnessViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 16) {
                        Text(typeEmoji(for: challenge.type))
                            .font(.system(size: 80))
                        
                        Text(challenge.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(challenge.description)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                    
                    // Challenge stats
                    HStack(spacing: 20) {
                        ChallengeStatItem(icon: "clock", value: "\(challenge.duration) min", label: "Duration")
                        ChallengeStatItem(icon: "target", value: "\(challenge.targetValue)", label: challenge.unit)
                        ChallengeStatItem(icon: "star.fill", value: "\(challenge.points)", label: "Points")
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        ForEach(Array(challenge.instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(
                                        Circle()
                                            .fill(Color(hex: "#fcc418"))
                                    )
                                
                                Text(instruction)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(2)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Start button
                    Button(action: {
                        fitnessViewModel.startChallenge(challenge)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Challenge")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#3cc45b"))
                        )
                    }
                    .disabled(challenge.isCompleted || fitnessViewModel.isPerformingChallenge)
                }
                .padding(20)
            }
            .background(Color(hex: "#3e4464"))
            .navigationTitle("Challenge Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private func typeEmoji(for type: Challenge.ChallengeType) -> String {
        switch type {
        case .cardio: return "🏃"
        case .strength: return "💪"
        case .flexibility: return "🤸"
        case .mindfulness: return "🧘"
        case .daily: return "📋"
        }
    }
}

struct ChallengeStatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#fcc418"))
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProgressItem: View {
    let icon: String
    let label: String
    let completed: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 24))
                .opacity(completed ? 1.0 : 0.3)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(completed ? .white : .white.opacity(0.5))
            
            Circle()
                .fill(completed ? Color(hex: "#3cc45b") : Color.white.opacity(0.3))
                .frame(width: 8, height: 8)
        }
    }
}

struct QuickWorkoutCard: View {
    let title: String
    let duration: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 32))
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(duration)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.5), lineWidth: 1)
                    )
            )
        }
    }
}

struct ChallengeActionCard: View {
    let challenge: Challenge
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Challenge icon and type
                HStack {
                    Text(typeEmoji(for: challenge.type))
                        .font(.system(size: 32))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(challenge.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(challenge.description)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                
                // Challenge details
                HStack(spacing: 20) {
                    DetailBadge(icon: "clock", text: "\(challenge.duration) min")
                    DetailBadge(icon: "star.fill", text: "\(challenge.points) pts")
                    DetailBadge(icon: "target", text: "\(challenge.targetValue) \(challenge.unit)")
                }
                
                // Complete button
                HStack {
                    Spacer()
                    
                    Text("Complete Challenge")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(typeColor(for: challenge.type))
                        )
                    
                    Spacer()
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(typeColor(for: challenge.type).opacity(0.5), lineWidth: 2)
                    )
            )
        }
    }
    
    private func typeEmoji(for type: Challenge.ChallengeType) -> String {
        switch type {
        case .cardio: return "🏃"
        case .strength: return "💪"
        case .flexibility: return "🤸"
        case .mindfulness: return "🧘"
        case .daily: return "📋"
        }
    }
    
    private func typeColor(for type: Challenge.ChallengeType) -> Color {
        switch type {
        case .cardio: return Color.red
        case .strength: return Color(hex: "#fcc418")
        case .flexibility: return Color.purple
        case .mindfulness: return Color.blue
        case .daily: return Color(hex: "#3cc45b")
        }
    }
}

struct DetailBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
        )
    }
}

#Preview {
    FitnessChallengeView(gameViewModel: GameViewModel())
}
