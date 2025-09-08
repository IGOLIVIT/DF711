//
//  BurgerGameViewModel.swift
//  FitFuelQuest
//
//  Created by IGOR on 08/09/2025.
//

import Foundation
import SwiftUI

class BurgerGameViewModel: ObservableObject {
    @Published var player: Player
    @Published var burgers: [Burger] = []
    @Published var currentLevel: GameLevel
    @Published var isGameActive = false
    @Published var isPaused = false
    @Published var timeRemaining: TimeInterval = 60.0
    @Published var gameResult: GameResult = .none
    @Published var screenSize: CGSize = CGSize(width: 375, height: 667)
    
    @AppStorage("highestLevel") var highestLevel: Int = 1
    @AppStorage("totalGamesPlayed") var totalGamesPlayed: Int = 0
    
    private var gameTimer: Timer?
    private var burgerSpawnTimer: Timer?
    private var gameUpdateTimer: Timer?
    
    enum GameResult {
        case none
        case won
        case lost
    }
    
    init() {
        self.currentLevel = GameLevel(number: 1)
        self.player = Player(screenWidth: 375, screenHeight: 667)
        self.timeRemaining = currentLevel.duration
    }
    
    func setScreenSize(_ size: CGSize) {
        screenSize = size
        player = Player(screenWidth: size.width, screenHeight: size.height)
    }
    
    func startGame() {
        resetGame()
        isGameActive = true
        gameResult = .none
        timeRemaining = currentLevel.duration
        
        startGameTimer()
        startBurgerSpawning()
        startGameUpdateLoop()
    }
    
    func stopGame() {
        isGameActive = false
        isPaused = false
        stopAllTimers()
    }
    
    func pauseGame() {
        isPaused = true
        stopAllTimers()
    }
    
    func resumeGame() {
        isPaused = false
        if isGameActive {
            startGameTimer()
            startBurgerSpawning()
            startGameUpdateLoop()
        }
    }
    
    func restartGame() {
        resetGame()
        startGame()
    }
    
    func nextLevel() {
        if gameResult == .won {
            let nextLevelNumber = currentLevel.number + 1
            currentLevel = GameLevel(number: nextLevelNumber)
            
            if nextLevelNumber > highestLevel {
                highestLevel = nextLevelNumber
            }
        }
        
        resetGame()
    }
    
    func restartCurrentLevel() {
        resetGame()
    }
    
    func resetProgress() {
        highestLevel = 1
        totalGamesPlayed = 0
        currentLevel = GameLevel(number: 1)
        resetGame()
    }
    
    private func resetGame() {
        stopAllTimers()
        player = Player(screenWidth: screenSize.width, screenHeight: screenSize.height)
        burgers.removeAll()
        timeRemaining = currentLevel.duration
        gameResult = .none
        isGameActive = false
        isPaused = false
    }
    
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 0.1
            
            if self.timeRemaining <= 0 {
                self.endGame(won: true)
            }
        }
    }
    
    private func startBurgerSpawning() {
        burgerSpawnTimer = Timer.scheduledTimer(withTimeInterval: currentLevel.burgerSpawnRate, repeats: true) { [weak self] _ in
            guard let self = self, self.isGameActive else { return }
            
            let newBurger = Burger(screenWidth: self.screenSize.width, level: self.currentLevel.number)
            self.burgers.append(newBurger)
        }
    }
    
    private func startGameUpdateLoop() {
        gameUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isGameActive else { return }
            
            self.updateGame()
        }
    }
    
    private func updateGame() {
        // Обновляем позиции бургеров
        for i in burgers.indices {
            burgers[i].position.y += burgers[i].velocity / 60.0
        }
        
        // Удаляем бургеры, которые вышли за экран
        burgers.removeAll { $0.position.y > screenSize.height + 50 }
        
        // Проверяем столкновения
        checkCollisions()
        
        // Проверяем условие проигрыша
        if player.weight >= currentLevel.maxWeight {
            endGame(won: false)
        }
    }
    
    private func checkCollisions() {
        for (index, burger) in burgers.enumerated() {
            let distance = sqrt(
                pow(player.position.x - burger.position.x, 2) +
                pow(player.position.y - burger.position.y, 2)
            )
            
            if distance < (player.size + burger.size) / 2 {
                // Столкновение!
                player.addWeight(burger.weight)
                burgers.remove(at: index)
                
                // Добавляем визуальный эффект (можно расширить)
                break
            }
        }
    }
    
    private func endGame(won: Bool) {
        stopAllTimers()
        isGameActive = false
        gameResult = won ? .won : .lost
        totalGamesPlayed += 1
    }
    
    func getPointsForLevel() -> Int {
        // Points based on level difficulty
        return currentLevel.number * 10
    }
    
    private func stopAllTimers() {
        gameTimer?.invalidate()
        gameTimer = nil
        
        burgerSpawnTimer?.invalidate()
        burgerSpawnTimer = nil
        
        gameUpdateTimer?.invalidate()
        gameUpdateTimer = nil
    }
    
    func movePlayer(to position: CGPoint) {
        guard isGameActive && !isPaused else { return }
        player.move(to: position, screenBounds: CGRect(origin: .zero, size: screenSize))
    }
    
    deinit {
        stopAllTimers()
    }
}
