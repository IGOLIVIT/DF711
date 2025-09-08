//
//  ContentView.swift
//  FitFuelQuest
//
//  Created by IGOR on 08/09/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if !gameViewModel.hasCompletedOnboarding {
                OnboardingView()
                    .environmentObject(gameViewModel)
            } else {
                mainAppView
            }
        }
    }
    
    private var mainAppView: some View {
        ZStack {
            // Background
            Color(hex: "#3e4464")
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Burger Game Tab
                BurgerGameView(mainGameViewModel: gameViewModel)
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "gamecontroller.fill" : "gamecontroller")
                        Text("Game")
                    }
                    .tag(0)
                
                // Fitness Challenge Tab
                FitnessChallengeView(gameViewModel: gameViewModel)
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "figure.strengthtraining.traditional" : "figure.walk")
                        Text("Fitness")
                    }
                    .tag(1)
                
                // Garden Tab
                GardenView(gameViewModel: gameViewModel)
                    .tabItem {
                        Image(systemName: selectedTab == 2 ? "leaf.fill" : "leaf")
                        Text("Garden")
                    }
                    .tag(2)
                
                // Profile Tab
                ProfileView(gameViewModel: gameViewModel)
                    .tabItem {
                        Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                        Text("Settings")
                    }
                    .tag(3)
            }
            .accentColor(Color(hex: "#fcc418"))
            .onAppear {
                // Customize tab bar appearance
                let appearance = UITabBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = UIColor(Color(hex: "#3e4464").opacity(0.9))
                
                // Normal state
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.white.opacity(0.6))
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor(Color.white.opacity(0.6))
                ]
                
                // Selected state
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "#fcc418"))
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor(Color(hex: "#fcc418"))
                ]
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

struct ProfileView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @StateObject private var burgerGameViewModel = BurgerGameViewModel()
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Stats overview
                        statsOverviewView
                        
                        // Settings
                        settingsView
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    
    private var statsOverviewView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Stats")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    icon: "🎮",
                    title: "Highest Level",
                    value: "\(burgerGameViewModel.highestLevel)",
                    color: Color(hex: "#fcc418")
                )
                
                StatCard(
                    icon: "🏃‍♂️",
                    title: "Games Played",
                    value: "\(burgerGameViewModel.totalGamesPlayed)",
                    color: Color(hex: "#3cc45b")
                )
                
                StatCard(
                    icon: "💪",
                    title: "Fitness Points",
                    value: "\(gameViewModel.userPoints)",
                    color: Color.orange
                )
                
                StatCard(
                    icon: "🌱",
                    title: "Plants Grown",
                    value: "\(gameViewModel.gardenPlants.count)",
                    color: Color(hex: "#3cc45b")
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
    
    
    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                Button(action: {
                    showingResetAlert = true
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.red)
                        
                        Text("Reset All Progress")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
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
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                gameViewModel.resetProgress()
                burgerGameViewModel.resetProgress()
            }
        } message: {
            Text("Are you sure you want to reset all progress? This action cannot be undone.")
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 24))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
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


#Preview {
    ContentView()
}
