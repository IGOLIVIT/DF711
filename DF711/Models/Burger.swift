//
//  Burger.swift
//  FitFuelQuest
//
//  Created by IGOR on 08/09/2025.
//

import Foundation
import SwiftUI

struct Burger: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGFloat
    let weight: Int // вес, который добавляется при столкновении
    let size: CGFloat
    
    init(screenWidth: CGFloat, level: Int) {
        // Случайная позиция по X, начинаем сверху экрана
        self.position = CGPoint(
            x: CGFloat.random(in: 50...(screenWidth - 50)),
            y: -50
        )
        
        // Скорость увеличивается с уровнем
        self.velocity = CGFloat(100 + level * 20)
        
        // Вес бургера от 5 до 15 кг
        self.weight = Int.random(in: 5...15)
        
        // Размер бургера
        self.size = CGFloat.random(in: 30...50)
    }
}

struct Player {
    var position: CGPoint
    var weight: Int = 70 // starting weight 70 kg
    let size: CGFloat = 60
    
    init(screenWidth: CGFloat, screenHeight: CGFloat) {
        self.position = CGPoint(
            x: screenWidth / 2,
            y: screenHeight - 100
        )
    }
    
    mutating func move(to newPosition: CGPoint, screenBounds: CGRect) {
        // Ограничиваем движение границами экрана
        let clampedX = max(size/2, min(screenBounds.width - size/2, newPosition.x))
        let clampedY = max(size/2, min(screenBounds.height - size/2, newPosition.y))
        
        self.position = CGPoint(x: clampedX, y: clampedY)
    }
    
    mutating func addWeight(_ burgerWeight: Int) {
        self.weight += burgerWeight
    }
}

struct GameLevel {
    let number: Int
    let maxWeight: Int
    let duration: TimeInterval = 60.0 // 1 минута
    let burgerSpawnRate: TimeInterval
    
    init(number: Int) {
        self.number = number
        // Максимальный вес уменьшается с каждым уровнем
        self.maxWeight = max(100, 200 - (number - 1) * 20)
        // Частота появления бургеров увеличивается
        self.burgerSpawnRate = max(0.3, 1.0 - Double(number - 1) * 0.1)
    }
}
