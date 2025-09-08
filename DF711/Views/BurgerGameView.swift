//
//  BurgerGameView.swift
//  FitFuelQuest
//
//  Created by IGOR on 08/09/2025.
//

import SwiftUI

struct BurgerGameView: View {
    @StateObject private var gameViewModel = BurgerGameViewModel()
    @ObservedObject var mainGameViewModel: GameViewModel
    @State private var showingGameOverAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background matching app theme
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                if !gameViewModel.isGameActive && gameViewModel.gameResult == .none {
                    // Стартовый экран
                    startScreen
                } else {
                    // Игровой экран
                    gameScreen
                }
                
                // Pause overlay
                if gameViewModel.isPaused {
                    pauseOverlay
                }
                
                // UI поверх игры
                VStack {
                    gameHUD
                    Spacer()
                }
                .padding()
            }
            .onAppear {
                gameViewModel.setScreenSize(geometry.size)
            }
            .alert("Game Over!", isPresented: $showingGameOverAlert) {
                if gameViewModel.gameResult == .won {
                    Button("Next Level") {
                        // Award points for winning
                        mainGameViewModel.userPoints += gameViewModel.getPointsForLevel()
                        mainGameViewModel.saveProgress()
                        gameViewModel.nextLevel()
                    }
                    Button("Retry Level") {
                        gameViewModel.restartCurrentLevel()
                    }
                } else {
                    Button("Retry") {
                        gameViewModel.restartCurrentLevel()
                    }
                }
            } message: {
                if gameViewModel.gameResult == .won {
                    Text("Congratulations! You completed level \(gameViewModel.currentLevel.number)!\nYour weight: \(gameViewModel.player.weight) kg\nYou earned \(gameViewModel.getPointsForLevel()) points!")
                } else {
                    Text("You gained too much weight!\nYour weight: \(gameViewModel.player.weight) kg\nLimit: \(gameViewModel.currentLevel.maxWeight) kg")
                }
            }
            .onChange(of: gameViewModel.gameResult) { result in
                if result != .none {
                    showingGameOverAlert = true
                }
            }
        }
    }
    
    private var startScreen: some View {
        VStack(spacing: 30) {
            // Заголовок
            VStack(spacing: 10) {
                Text("🏃‍♂️")
                    .font(.system(size: 80))
                
                Text("Burger Dodge")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Dodge the falling burgers!")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Информация об уровне
            VStack(spacing: 15) {
                levelInfoCard
                
                // Кнопка старта
                Button(action: {
                    gameViewModel.startGame()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Game")
                    }
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(hex: "#fcc418"))
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                }
            }
        }
    }
    
    private var levelInfoCard: some View {
        VStack(spacing: 12) {
            Text("Level \(gameViewModel.currentLevel.number)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Max Weight:")
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("\(gameViewModel.currentLevel.maxWeight) kg")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Time:")
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("60 seconds")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Starting Weight:")
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("70 kg")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var gameScreen: some View {
        ZStack {
            // Игровое поле
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            gameViewModel.movePlayer(to: value.location)
                        }
                )
            
            // Бургеры
            ForEach(gameViewModel.burgers) { burger in
                Text("🍔")
                    .font(.system(size: burger.size))
                    .position(burger.position)
                    .animation(.linear(duration: 0.1), value: burger.position)
            }
            
            // Игрок
            Text("🏃‍♂️")
                .font(.system(size: gameViewModel.player.size))
                .position(gameViewModel.player.position)
                .animation(.easeOut(duration: 0.1), value: gameViewModel.player.position)
        }
    }
    
    private var gameHUD: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Level \(gameViewModel.currentLevel.number)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Weight: \(gameViewModel.player.weight) kg")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(gameViewModel.player.weight >= gameViewModel.currentLevel.maxWeight * 8/10 ? .red : .white)
                
                Text("Limit: \(gameViewModel.currentLevel.maxWeight) kg")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Game controls
            HStack(spacing: 12) {
                Button(action: {
                    if gameViewModel.isPaused {
                        gameViewModel.resumeGame()
                    } else {
                        gameViewModel.pauseGame()
                    }
                }) {
                    Image(systemName: gameViewModel.isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                
                Button(action: {
                    gameViewModel.restartGame()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
            }
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("Time")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(String(format: "%.1f", gameViewModel.timeRemaining))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(gameViewModel.timeRemaining <= 10 ? .red : .white)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(gameViewModel.isGameActive ? 1.0 : 0.0)
        )
    }
    
    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("⏸️")
                    .font(.system(size: 80))
                
                Text("Game Paused")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    Button(action: {
                        gameViewModel.resumeGame()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Resume")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(hex: "#3cc45b"))
                        )
                    }
                    
                    Button(action: {
                        gameViewModel.restartGame()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Restart")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(hex: "#fcc418"))
                        )
                    }
                    
                    Button(action: {
                        gameViewModel.stopGame()
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Main Menu")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.gray)
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    BurgerGameView(mainGameViewModel: GameViewModel())
}
