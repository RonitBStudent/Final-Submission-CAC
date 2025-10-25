//
//  SettingsView.swift
//  Congressional App Challenge (DR)
//
//  Created by GitHub Copilot on 9/27/25.
//

import SwiftUI

// Eye Color Theme Manager
class ThemeManager: ObservableObject {
    @Published var selectedEyeColor: EyeColor = .brown
    
    enum EyeColor: String, CaseIterable {
        case brown = "Brown"
        case blue = "Blue"
        case green = "Green"
        case hazel = "Hazel"
        case gray = "Gray"
        case amber = "Amber"
        
        var primaryColor: Color {
            switch self {
            case .brown: return Color.brown
            case .blue: return Color.blue
            case .green: return Color.green
            case .hazel: return Color.orange
            case .gray: return Color.gray
            case .amber: return Color.yellow
            }
        }
        
        var accentColor: Color {
            switch self {
            case .brown: return Color.brown.opacity(0.8)
            case .blue: return Color.blue.opacity(0.8)
            case .green: return Color.green.opacity(0.8)
            case .hazel: return Color.orange.opacity(0.8)
            case .gray: return Color.gray.opacity(0.8)
            case .amber: return Color.yellow.opacity(0.8)
            }
        }
        
        var gradientColors: [Color] {
            switch self {
            case .brown: return [Color.brown.opacity(0.8), Color.brown]
            case .blue: return [Color.blue.opacity(0.8), Color.blue]
            case .green: return [Color.green.opacity(0.8), Color.green]
            case .hazel: return [Color.orange.opacity(0.8), Color.orange]
            case .gray: return [Color.gray.opacity(0.8), Color.gray]
            case .amber: return [Color.yellow.opacity(0.8), Color.yellow]
            }
        }
        
        var backgroundGradient: LinearGradient {
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), primaryColor.opacity(0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        var icon: String {
            switch self {
            case .brown: return "eye.fill"
            case .blue: return "eye.circle.fill"
            case .green: return "eye.trianglebadge.exclamationmark.fill"
            case .hazel: return "eye.square.fill"
            case .gray: return "eye.slash.fill"
            case .amber: return "eye"
            }
        }
        
        var description: String {
            switch self {
            case .brown: return "Warm and earthy tones"
            case .blue: return "Cool and calming blues"
            case .green: return "Fresh and natural greens"
            case .hazel: return "Rich amber and orange hues"
            case .gray: return "Sophisticated gray tones"
            case .amber: return "Golden and vibrant yellows"
            }
        }
    }
    
    init() {
        // Load saved eye color preference
        if let savedColorRaw = UserDefaults.standard.string(forKey: "selectedEyeColor"),
           let savedColor = EyeColor(rawValue: savedColorRaw) {
            self.selectedEyeColor = savedColor
        }
    }
    
    func updateEyeColor(_ color: EyeColor) {
        selectedEyeColor = color
        UserDefaults.standard.set(color.rawValue, forKey: "selectedEyeColor")
    }
}

struct SettingsView: View {
    @StateObject private var themeManager = ThemeManager()
    @State private var showingColorPicker = false
    @State private var selectedColorForPreview: ThemeManager.EyeColor = .brown
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient based on selected eye color
                themeManager.selectedEyeColor.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Enhanced Header
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
                                
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("App Settings")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: themeManager.selectedEyeColor.gradientColors),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("Customize your eye health experience")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Current Theme Preview
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: "paintpalette.fill")
                                    .foregroundColor(themeManager.selectedEyeColor.primaryColor)
                                Text("Current Theme")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                                
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
                                            .frame(width: 80, height: 80)
                                            .shadow(color: themeManager.selectedEyeColor.primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                                        
                                        Image(systemName: themeManager.selectedEyeColor.icon)
                                            .font(.system(size: 30, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(spacing: 5) {
                                        Text(themeManager.selectedEyeColor.rawValue + " Eyes")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        Text(themeManager.selectedEyeColor.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .padding(20)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Eye Color Selection
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "eye.circle.fill")
                                    .foregroundColor(themeManager.selectedEyeColor.primaryColor)
                                Text("Choose Your Eye Color")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            
                            Text("Select your eye color to personalize the app theme")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 20) {
                                ForEach(ThemeManager.EyeColor.allCases, id: \.self) { eyeColor in
                                    EyeColorCard(
                                        eyeColor: eyeColor,
                                        isSelected: themeManager.selectedEyeColor == eyeColor,
                                        action: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                themeManager.updateEyeColor(eyeColor)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // App Information
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(themeManager.selectedEyeColor.primaryColor)
                                Text("About Personalization")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [themeManager.selectedEyeColor.primaryColor.opacity(0.1), themeManager.selectedEyeColor.primaryColor.opacity(0.05)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(themeManager.selectedEyeColor.primaryColor.opacity(0.2), lineWidth: 1)
                                    )
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Your eye color theme personalizes the visual experience throughout the app while maintaining medical accuracy and professionalism.")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Text("• Theme colors adapt to your selection")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("• Medical functionality remains unchanged")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("• Settings are automatically saved")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("• Change anytime from this settings page")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(themeManager)
    }
}

// Eye Color Selection Card
struct EyeColorCard: View {
    let eyeColor: ThemeManager.EyeColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: eyeColor.gradientColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 3 : 0
                            )
                    )
                
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: eyeColor.gradientColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .shadow(color: eyeColor.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: eyeColor.icon)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                        
                        // Selection indicator
                        if isSelected {
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 20, height: 20)
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(eyeColor.primaryColor)
                                        )
                                        .offset(x: 20, y: -20)
                                )
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text(eyeColor.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(eyeColor.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
                .padding(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    SettingsView()
}
