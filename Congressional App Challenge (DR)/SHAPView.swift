//
//  SHAPView.swift
//  Congressional App Challenge (DR)
//
//  Created by Ronit B on 8/11/25.
//

import SwiftUI
import PhotosUI

struct SHAPView: View {
    @StateObject private var predictor = SHAPPredictor()
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Optimized background
                AppBackgroundGradient.standard(themeColor: .purple)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Reusable header component
                        AppHeaderView(
                            title: "SHAP Analysis",
                            subtitle: "Explainable AI for transparent diagnostics",
                            iconName: "brain.head.profile",
                            themeColor: .purple
                        )
                        
                        // SHAP-specific image display
                        SHAPImageDisplayView(
                            selectedImage: selectedImage,
                            explanationImage: predictor.explanationImage,
                            isAnalyzing: predictor.isAnalyzing
                        )
                        .padding(.horizontal)
                        
                        // Reusable action buttons
                        ActionButtonsView(
                            onCameraAction: { showingCamera = true },
                            onGalleryAction: { showingImagePicker = true }
                        )
                        
                        // SHAP analyze button
                        if selectedImage != nil {
                            SHAPAnalyzeButton(
                                isAnalyzing: predictor.isAnalyzing,
                                action: {
                                    if let image = selectedImage {
                                        predictor.generateSHAP(image: image)
                                    }
                                }
                            )
                            .padding(.horizontal)
                        }
                        
                        // SHAP Results Section
                        SHAPResultsSection(
                            predictionText: predictor.predictionText,
                            shapImage: predictor.shapImage,
                            isAnalyzing: predictor.isAnalyzing
                        )
                        .padding(.horizontal)
                        
                        // SHAP Info Section
                        SHAPInfoSection()
                            .padding(.horizontal)
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker(selectedImage: $selectedImage)
        }
    }
}

// MARK: - SHAP-Specific Components
struct SHAPImageDisplayView: View {
    let selectedImage: UIImage?
    let explanationImage: UIImage?
    let isAnalyzing: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Visual Explanation")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if let explanationImage = explanationImage {
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                        
                        Image(uiImage: explanationImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 280)
                            .cornerRadius(16)
                            .padding(8)
                    }
                    .frame(maxHeight: 300)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.purple)
                        Text("SHAP explanation generated successfully")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else if let selectedImage = selectedImage {
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                        
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 280)
                            .cornerRadius(16)
                            .padding(8)
                    }
                    .frame(maxHeight: 300)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Ready for SHAP analysis")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                ImagePlaceholderView(subtitle: "See which parts influenced the AI's decision")
            }
        }
    }
}

struct SHAPAnalyzeButton: View {
    let isAnalyzing: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isAnalyzing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "brain.head.profile")
                        .font(.title3)
                }
                
                Text(isAnalyzing ? "Generating SHAP..." : "Generate SHAP Analysis")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isAnalyzing ?
                        LinearGradient(gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.8)]), startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: isAnalyzing ? Color.gray.opacity(0.3) : Color.purple.opacity(0.3), radius: 15, x: 0, y: 8)
            )
        }
        .disabled(isAnalyzing)
    }
}

struct SHAPResultsSection: View {
    let predictionText: String
    let shapImage: UIImage?
    let isAnalyzing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "eye.circle.fill")
                    .foregroundColor(.purple)
                Text("SHAP Visualization")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 16) {
                    if isAnalyzing {
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Generating SHAP visualization...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(40)
                    } else if let shapImage = shapImage {
                        VStack(spacing: 12) {
                            Image(uiImage: shapImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                            
                            Text("Red areas contributed to positive prediction")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        Text(predictionText.isEmpty ? "Upload and analyze an image to see SHAP visualization" : predictionText)
                            .font(.body)
                            .foregroundColor(predictionText.isEmpty ? .secondary : .primary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(20)
            }
        }
    }
}

struct SHAPInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.purple)
                Text("About SHAP Analysis")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.purple.opacity(0.05)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("SHAP (SHapley Additive exPlanations) shows which parts of the image contributed most to the AI's decision.")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    InfoBulletPoint(text: "Red areas indicate regions that increase the likelihood of diabetic retinopathy")
                    InfoBulletPoint(text: "Blue areas show regions that decrease the likelihood")
                    InfoBulletPoint(text: "This helps doctors understand and trust AI decisions")
                }
                .padding(16)
            }
        }
    }
}

#Preview {
    SHAPView()
        .environmentObject(ThemeManager())
}
