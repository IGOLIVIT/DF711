//
//  OnboardingView.swift
//  FitFuelQuest
//
//  Created by IGOR on 08/09/2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var currentPage = 0
    
    private let onboardingPages = [
        OnboardingPage(
            title: "Welcome!",
            description: "Your ultimate fitness and wellness adventure starts here!",
            imageName: "🌟",
            backgroundColor: Color(hex: "#3e4464")
        ),
        OnboardingPage(
            title: "Dodge the Burgers!",
            description: "Play our fun arcade game where you dodge falling burgers to stay healthy. Don't let your weight exceed the limit!",
            imageName: "🏃‍♂️",
            backgroundColor: Color(hex: "#fcc418")
        ),
        OnboardingPage(
            title: "Complete Fitness Challenges",
            description: "Take on daily fitness challenges with built-in timers. Earn points and improve your health with simple exercises.",
            imageName: "💪",
            backgroundColor: Color(hex: "#3cc45b")
        ),
        OnboardingPage(
            title: "Grow Your Virtual Garden",
            description: "Use points from fitness activities to plant and grow beautiful plants in your personal garden.",
            imageName: "🌱",
            backgroundColor: Color(hex: "#3e4464")
        ),
        OnboardingPage(
            title: "Ready to Start?",
            description: "Begin your fitness journey with fun games, real workouts, and a growing garden!",
            imageName: "🚀",
            backgroundColor: Color(hex: "#3cc45b")
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    onboardingPages[currentPage].backgroundColor,
                    onboardingPages[currentPage].backgroundColor.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top section with content
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Large emoji/icon
                    Text(onboardingPages[currentPage].imageName)
                        .font(.system(size: 120))
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                    
                    // Title
                    Text(onboardingPages[currentPage].title)
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                    
                    // Description
                    Text(onboardingPages[currentPage].description)
                        .font(.system(size: 18, weight: .regular, design: .default))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .lineSpacing(4)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                    
                    Spacer()
                }
                
                // Bottom section with navigation
                VStack(spacing: 25) {
                    // Page indicators
                    HStack(spacing: 12) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 10, height: 10)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    
                    // Navigation buttons
                    HStack(spacing: 20) {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage -= 1
                                }
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.white.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if currentPage < onboardingPages.count - 1 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                }
                            } else {
                                // Complete onboarding
                                gameViewModel.hasCompletedOnboarding = true
                            }
                        }) {
                            HStack {
                                Text(currentPage < onboardingPages.count - 1 ? "Next" : "Start Adventure")
                                if currentPage < onboardingPages.count - 1 {
                                    Image(systemName: "chevron.right")
                                } else {
                                    Image(systemName: "arrow.right.circle.fill")
                                }
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(currentPage < onboardingPages.count - 1 ? Color(hex: "#3e4464") : .white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(currentPage < onboardingPages.count - 1 ? Color.white : Color(hex: "#3cc45b"))
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 50)
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width > threshold && currentPage > 0 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage -= 1
                        }
                    } else if value.translation.width < -threshold && currentPage < onboardingPages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    }
                }
        )
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    OnboardingView()
}
