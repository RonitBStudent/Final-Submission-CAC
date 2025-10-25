//
//  EyeHealthView.swift
//  Congressional App Challenge (DR)
//
//  Created by GitHub Copilot on 9/27/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct EyeHealthView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedCategory: HealthCategory = .dailyTips
    @State private var completedTips: Set<Int> = []
    @State private var showingQuiz = false
    @State private var currentQuizQuestion = 0
    @State private var quizScore = 0
    @State private var showingQuizResults = false
    @State private var blinkCount = 0
    @State private var isBlinkExerciseActive = false
    @State private var exerciseTimer: Timer?
    @State private var exerciseTimeRemaining = 60
    @State private var showingNutritionDetail = false
    @State private var selectedNutrient: NutrientInfo?
    
    // Interactive features
    @State private var totalPointsEarned = 0
    @State private var showingAchievement = false
    @State private var latestAchievement = ""
    @State private var pulseAnimation = false
    @State private var rotationAnimation = 0.0
    @State private var scaleAnimation = 1.0
    
    enum HealthCategory: String, CaseIterable {
        case dailyTips = "Daily Tips"
        case exercises = "Exercises"
        case nutrition = "Nutrition"
        case habits = "Healthy Habits"
        case prevention = "Prevention"
        case findDoctors = "Find Eye Doctors"
        case quiz = "Knowledge Quiz"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient using selected eye color
                themeManager.selectedEyeColor.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced Header with Animations
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: themeManager.selectedEyeColor.gradientColors),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: themeManager.selectedEyeColor.primaryColor.opacity(0.3), radius: 15, x: 0, y: 8)
                                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulseAnimation)
                            
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(rotationAnimation))
                                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: rotationAnimation)
                        }
                        .onAppear {
                            pulseAnimation = true
                            rotationAnimation = 5.0
                        }
                        
                        VStack(spacing: 8) {
                            Text("Eye Health & Tips")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: themeManager.selectedEyeColor.gradientColors),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .scaleEffect(scaleAnimation)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: scaleAnimation)
                            
                            Text("Your complete guide to healthy vision")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Category Selection
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(HealthCategory.allCases, id: \.self) { category in
                                CategoryChip(
                                    category: category,
                                    isSelected: selectedCategory == category,
                                    themeColor: themeManager.selectedEyeColor.primaryColor
                                ) {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        selectedCategory = category
                                        triggerHapticFeedback()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                    
                    // Content Area
                    ScrollView {
                        VStack(spacing: 20) {
                            switch selectedCategory {
                            case .dailyTips:
                                DailyTipsSection(
                                    completedTips: $completedTips,
                                    themeColor: themeManager.selectedEyeColor.primaryColor,
                                    onTipCompleted: handleTipCompletion
                                )
                            case .exercises:
                                ExercisesSection(
                                    blinkCount: $blinkCount,
                                    isActive: $isBlinkExerciseActive,
                                    exerciseTimer: $exerciseTimer,
                                    timeRemaining: $exerciseTimeRemaining,
                                    themeColor: themeManager.selectedEyeColor.primaryColor
                                )
                            case .nutrition:
                                NutritionSection(
                                    showingDetail: $showingNutritionDetail,
                                    selectedNutrient: $selectedNutrient,
                                    themeColor: themeManager.selectedEyeColor.primaryColor
                                )
                            case .habits:
                                HealthyHabitsSection(themeColor: themeManager.selectedEyeColor.primaryColor)
                            case .prevention:
                                PreventionSection(themeColor: themeManager.selectedEyeColor.primaryColor)
                            case .findDoctors:
                                FindEyeDoctorsSection(themeColor: themeManager.selectedEyeColor.primaryColor)
                            case .quiz:
                                QuizSection(
                                    showingQuiz: $showingQuiz,
                                    currentQuestion: $currentQuizQuestion,
                                    score: $quizScore,
                                    showingResults: $showingQuizResults,
                                    themeColor: themeManager.selectedEyeColor.primaryColor
                                )
                            }
                            
                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingNutritionDetail) {
            if let nutrient = selectedNutrient {
                NutrientDetailView(nutrient: nutrient, themeColor: themeManager.selectedEyeColor.primaryColor)
            }
        }
        .fullScreenCover(isPresented: $showingQuiz) {
            QuizView(
                currentQuestion: $currentQuizQuestion,
                score: $quizScore,
                showingResults: $showingQuizResults,
                showingQuiz: $showingQuiz,
                themeColor: themeManager.selectedEyeColor.primaryColor
            )
        }
        .onAppear {
            scaleAnimation = 1.1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scaleAnimation = 1.0
            }
        }
    }
    
    private func handleTipCompletion() {
        totalPointsEarned += 10
        triggerHapticFeedback()
        checkForAchievements()
    }
    
    private func checkForAchievements() {
        if completedTips.count == 5 && latestAchievement != "Tip Master!" {
            latestAchievement = "Tip Master!"
            showingAchievement = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                showingAchievement = false
            }
        }
    }
    
    private func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: EyeHealthView.HealthCategory
    let isSelected: Bool
    let themeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconForCategory(category))
                    .font(.system(size: 14, weight: .medium))
                
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : themeColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? themeColor : Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private func iconForCategory(_ category: EyeHealthView.HealthCategory) -> String {
        switch category {
        case .dailyTips: return "lightbulb.fill"
        case .exercises: return "figure.flexibility"
        case .nutrition: return "leaf.fill"
        case .habits: return "checkmark.circle.fill"
        case .prevention: return "shield.fill"
        case .findDoctors: return "magnifyingglass.circle.fill"
        case .quiz: return "questionmark.circle.fill"
        }
    }
}

// MARK: - Daily Tips Section
struct DailyTipsSection: View {
    @Binding var completedTips: Set<Int>
    let themeColor: Color
    let onTipCompleted: () -> Void
    
    private let tips = [
        ("20-20-20 Rule", "Every 20 minutes, look at something 20 feet away for 20 seconds", "eye.fill"),
        ("Blink More Often", "Consciously blink more frequently when using screens", "eye.circle.fill"),
        ("Proper Lighting", "Ensure adequate lighting when reading or working", "lightbulb.fill"),
        ("Screen Distance", "Keep your screen 20-26 inches away from your eyes", "display"),
        ("Stay Hydrated", "Drink plenty of water to keep your eyes moist", "drop.fill"),
        ("Clean Hands", "Always wash your hands before touching your eyes", "hand.wash.fill"),
        ("Regular Breaks", "Take frequent breaks from close-up work", "clock.fill"),
        ("Eye Protection", "Wear sunglasses and safety glasses appropriately", "sunglasses.fill")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(themeColor)
                Text("Daily Eye Care Tips")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                    InteractiveTipCard(
                        tip: tip,
                        index: index,
                        isCompleted: completedTips.contains(index),
                        themeColor: themeColor
                    ) {
                        withAnimation(.spring()) {
                            if completedTips.contains(index) {
                                completedTips.remove(index)
                            } else {
                                completedTips.insert(index)
                                onTipCompleted()
                            }
                        }
                    }
                }
            }
            
            // Progress Summary
            if !completedTips.isEmpty {
                ProgressCard(
                    completed: completedTips.count,
                    total: tips.count,
                    themeColor: themeColor
                )
            }
        }
    }
}

// MARK: - Interactive Tip Card
struct InteractiveTipCard: View {
    let tip: (String, String, String)
    let index: Int
    let isCompleted: Bool
    let themeColor: Color
    let action: () -> Void
    
    @State private var bounceAnimation = false
    
    var body: some View {
        Button(action: {
            action()
            if !isCompleted {
                bounceAnimation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    bounceAnimation = false
                }
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(themeColor.opacity(0.1))
                        .frame(width: 50, height: 50)
                        .scaleEffect(bounceAnimation ? 1.3 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: bounceAnimation)
                    
                    Image(systemName: tip.2)
                        .font(.system(size: 22))
                        .foregroundColor(themeColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(tip.0)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(tip.1)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompleted ? .green : .gray)
                    .scaleEffect(isCompleted ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: isCompleted)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCompleted ? themeColor.opacity(0.3) : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isCompleted ? 1.02 : 1.0)
            .animation(.spring(response: 0.3), value: isCompleted)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Progress Card
struct ProgressCard: View {
    let completed: Int
    let total: Int
    let themeColor: Color
    
    @State private var animateProgress = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis.circle")
                    .foregroundColor(themeColor)
                Text("Today's Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(completed)/\(total)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [themeColor.opacity(0.7), themeColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: animateProgress ? CGFloat(completed) / CGFloat(total) * 280 : 0, height: 8)
                    .animation(.easeInOut(duration: 1.0), value: animateProgress)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateProgress = true
            }
        }
    }
}

// MARK: - Simple placeholder sections for now
struct ExercisesSection: View {
    @Binding var blinkCount: Int
    @Binding var isActive: Bool
    @Binding var exerciseTimer: Timer?
    @Binding var timeRemaining: Int
    let themeColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "figure.flexibility")
                    .foregroundColor(themeColor)
                Text("Eye Exercises")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("Interactive exercises coming soon!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(12)
        }
    }
}

struct NutritionSection: View {
    @Binding var showingDetail: Bool
    @Binding var selectedNutrient: NutrientInfo?
    let themeColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(themeColor)
                Text("Eye-Healthy Nutrition")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("Nutrition guide coming soon!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(12)
        }
    }
}

struct HealthyHabitsSection: View {
    let themeColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(themeColor)
                Text("Healthy Habits")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("Healthy habits guide coming soon!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(12)
        }
    }
}

struct PreventionSection: View {
    let themeColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "shield.fill")
                    .foregroundColor(themeColor)
                Text("Prevention Tips")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("Prevention guide coming soon!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(12)
        }
    }
}

struct QuizSection: View {
    @Binding var showingQuiz: Bool
    @Binding var currentQuestion: Int
    @Binding var score: Int
    @Binding var showingResults: Bool
    let themeColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(themeColor)
                Text("Knowledge Quiz")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("Interactive quiz coming soon!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(12)
        }
    }
}

// MARK: - Find Eye Doctors Section
struct FindEyeDoctorsSection: View {
    let themeColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "magnifyingglass.circle.fill")
                    .foregroundColor(themeColor)
                Text("Find Eye Doctors")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("Locate nearby ophthalmologists and eye care professionals")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Simplified approach - direct buttons instead of complex map
            VStack(spacing: 16) {
                // Quick search buttons
                HStack(spacing: 12) {
                    SearchButton(
                        title: "Ophthalmologists",
                        icon: "eye.fill",
                        themeColor: themeColor,
                        searchTerm: "ophthalmologist near me"
                    )
                    
                    SearchButton(
                        title: "Eye Doctors",
                        icon: "stethoscope",
                        themeColor: themeColor,
                        searchTerm: "eye doctor near me"
                    )
                }
                
                HStack(spacing: 12) {
                    SearchButton(
                        title: "Optometrists",
                        icon: "eyeglasses",
                        themeColor: themeColor,
                        searchTerm: "optometrist near me"
                    )
                    
                    SearchButton(
                        title: "Retina Specialists",
                        icon: "circle.circle.fill",
                        themeColor: themeColor,
                        searchTerm: "retina specialist near me"
                    )
                }
                
                // Main Maps button
                Button(action: openGeneralMaps) {
                    HStack {
                        Image(systemName: "map.fill")
                            .font(.title3)
                        Text("Open Maps - Find Eye Care")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [themeColor, themeColor.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            
            // Information section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(themeColor)
                    Text("What to Look For")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    InfoPoint(text: "Board-certified ophthalmologists for comprehensive eye exams")
                    InfoPoint(text: "Retina specialists for diabetic retinopathy treatment")
                    InfoPoint(text: "Optometrists for routine vision care and screenings")
                    InfoPoint(text: "Emergency eye care facilities for urgent symptoms")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func openGeneralMaps() {
        let searchQuery = "eye doctor near me"
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "eye+doctor"
        
        // Try Apple Maps first
        if let appleURL = URL(string: "maps://?q=\(encodedQuery)"),
           UIApplication.shared.canOpenURL(appleURL) {
            UIApplication.shared.open(appleURL)
        }
        // Fallback to Google Maps web
        else if let webURL = URL(string: "https://www.google.com/maps/search/\(encodedQuery)") {
            UIApplication.shared.open(webURL)
        }
    }
}

// MARK: - Search Button Component
struct SearchButton: View {
    let title: String
    let icon: String
    let themeColor: Color
    let searchTerm: String
    
    var body: some View {
        Button(action: {
            openSearch(term: searchTerm)
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(themeColor.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(themeColor)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func openSearch(term: String) {
        let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? term.replacingOccurrences(of: " ", with: "+")
        
        // Try Apple Maps first
        if let appleURL = URL(string: "maps://?q=\(encodedTerm)"),
           UIApplication.shared.canOpenURL(appleURL) {
            UIApplication.shared.open(appleURL)
        }
        // Fallback to web search
        else if let webURL = URL(string: "https://www.google.com/maps/search/\(encodedTerm)") {
            UIApplication.shared.open(webURL)
        }
    }
}

// MARK: - Info Point Component
struct InfoPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 14))
                .offset(y: 2)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

// Simple placeholder structs
struct NutrientInfo {
    let name: String
}

struct NutrientDetailView: View {
    let nutrient: NutrientInfo
    let themeColor: Color
    
    var body: some View {
        Text("Detail view for \(nutrient.name)")
    }
}

struct QuizView: View {
    @Binding var currentQuestion: Int
    @Binding var score: Int
    @Binding var showingResults: Bool
    @Binding var showingQuiz: Bool
    let themeColor: Color
    
    var body: some View {
        Text("Quiz view")
    }
}

#Preview {
    EyeHealthView()
        .environmentObject(ThemeManager())
}
