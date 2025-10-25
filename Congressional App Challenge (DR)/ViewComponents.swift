//
//  ViewComponents.swift
//  Congressional App Challenge (DR)
//
//  Created by GitHub Copilot on 9/27/25.
//

import SwiftUI

// MARK: - Reusable Header Component
struct AppHeaderView: View {
    let title: String
    let subtitle: String
    let iconName: String
    let themeColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [themeColor.opacity(0.8), themeColor]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)
                    .shadow(color: themeColor.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: iconName)
                    .font(.system(size: 42, weight: .light))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [themeColor.opacity(0.9), themeColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}

// MARK: - Enhanced Image Display Component
struct ImageDisplayView: View {
    let selectedImage: UIImage?
    let placeholderTitle: String
    let placeholderSubtitle: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(placeholderTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)
            
            if let selectedImage = selectedImage {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.12), radius: 25, x: 0, y: 12)
                        
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(20)
                            .padding(12)
                    }
                    .frame(maxHeight: 324)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                        Text("Image loaded successfully")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                ImagePlaceholderView(subtitle: placeholderSubtitle)
            }
        }
    }
}

// MARK: - Enhanced Image Placeholder Component
struct ImagePlaceholderView: View {
    let subtitle: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.15)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 2.5, dash: [12, 8])
                )
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.gray.opacity(0.08))
                )
                .frame(height: 280)
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: "photo.circle")
                        .font(.system(size: 45))
                        .foregroundColor(.gray.opacity(0.7))
                }
                
                VStack(spacing: 8) {
                    Text("Upload Fundus Image")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Enhanced Action Buttons Component
struct ActionButtonsView: View {
    let onCameraAction: () -> Void
    let onGalleryAction: () -> Void
    
    var body: some View {
        HStack(spacing: 30) {
            ActionButton(
                title: "Camera",
                iconName: "camera.fill",
                color: .blue,
                action: onCameraAction
            )
            
            ActionButton(
                title: "Gallery", 
                iconName: "photo.on.rectangle",
                color: .green,
                action: onGalleryAction
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Enhanced Individual Action Button
struct ActionButton: View {
    let title: String
    let iconName: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.9), color]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Enhanced Analyze Button Component
struct AnalyzeButtonView: View {
    let isAnalyzing: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if !isAnalyzing {
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                action()
            }
        }) {
            HStack(spacing: 15) {
                if isAnalyzing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.1)
                } else {
                    Image(systemName: "eye.circle.fill")
                        .font(.title2)
                }
                
                Text(isAnalyzing ? "Analyzing Image..." : "Analyze Image")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isAnalyzing ?
                        LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.gray.opacity(0.6)]), startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.9), Color.red]), startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: isAnalyzing ? Color.gray.opacity(0.3) : Color.red.opacity(0.4), radius: 18, x: 0, y: 9)
            )
        }
        .disabled(isAnalyzing)
        .scaleEffect(isAnalyzing ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isAnalyzing)
    }
}

// MARK: - Enhanced Results Section Component
struct ResultsSectionView: View {
    let predictionText: String
    let confidence: Double
    let themeColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 12) {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundColor(themeColor)
                    .font(.title3)
                Text("Analysis Results")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 20)
            
            ResultsCardView(
                predictionText: predictionText,
                confidence: confidence
            )
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Enhanced Results Card Component
struct ResultsCardView: View {
    let predictionText: String
    let confidence: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
            
            VStack(alignment: .leading, spacing: 18) {
                Text(predictionText.isEmpty ? "Upload and analyze an image to see detailed results" : predictionText)
                    .font(.body)
                    .foregroundColor(predictionText.isEmpty ? .secondary : .primary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                
                if confidence > 0 {
                    Divider()
                        .padding(.vertical, 4)
                    
                    ConfidenceLevelView(confidence: confidence)
                }
            }
            .padding(24)
        }
    }
}

// MARK: - Enhanced Confidence Level Component
struct ConfidenceLevelView: View {
    let confidence: Double
    
    @State private var animateBar = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Confidence Level")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(Int(confidence * 100))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(confidence > 0.5 ? .red : .green)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: confidence > 0.5 ? 
                                [Color.red.opacity(0.8), Color.red] : 
                                [Color.green.opacity(0.8), Color.green]
                            ),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: animateBar ? CGFloat(confidence) * 280 : 0, height: 12)
                    .animation(.easeInOut(duration: 1.0), value: animateBar)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateBar = true
            }
        }
    }
}

// MARK: - Enhanced Info Section Component
struct InfoSectionView: View {
    let themeColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(themeColor)
                    .font(.title3)
                Text("About This Analysis")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [themeColor.opacity(0.12), themeColor.opacity(0.06)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(themeColor.opacity(0.25), lineWidth: 1.5)
                    )
                
                InfoContentView()
                    .padding(20)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Enhanced Info Content Component
struct InfoContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("This AI model analyzes fundus images to detect signs of diabetic retinopathy using advanced machine learning algorithms trained on medical data.")
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineSpacing(1)
            
            VStack(alignment: .leading, spacing: 10) {
                InfoBulletPoint(text: "Higher percentages indicate greater likelihood of diabetic retinopathy")
                InfoBulletPoint(text: "Early detection through AI screening can prevent vision loss")
                InfoBulletPoint(text: "This tool assists healthcare professionals but does not replace comprehensive eye exams")
                InfoBulletPoint(text: "Always consult an ophthalmologist for professional diagnosis and treatment")
            }
        }
    }
}

// MARK: - Enhanced Info Bullet Point Component
struct InfoBulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)
                .offset(y: 6)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(1)
            
            Spacer()
        }
    }
}

// MARK: - Enhanced Background Gradient Component
struct AppBackgroundGradient: View {
    let colors: [Color]
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Enhanced Standard App Background
extension AppBackgroundGradient {
    static func standard(themeColor: Color) -> AppBackgroundGradient {
        AppBackgroundGradient(colors: [
            Color(.systemBackground),
            themeColor.opacity(0.08),
            themeColor.opacity(0.03)
        ])
    }
}
