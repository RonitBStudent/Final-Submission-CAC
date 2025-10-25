//
//  ContentView.swift
//  Congressional App Challenge (DR)
//
//  Created by Ronit B on 8/10/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        TabView {
            // Regular Retinopathy Analysis Tab
            RetinopathyAnalysisView()
                .tabItem {
                    Image(systemName: "stethoscope")
                    Text("Analysis")
                }
            
            // SHAP Visualization Tab
            SHAPView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("SHAP")
                }
            
            // Eye Vision Tests Tab
            EyeTestsView()
                .tabItem {
                    Image(systemName: "eye.fill")
                    Text("Eye Tests")
                }
            
            // Eye Health Tab
            EyeHealthView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Eye Health")
                }
            
            // Maps Tab - NEW!
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Find Care")
                }
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .accentColor(themeManager.selectedEyeColor.primaryColor)
        .environmentObject(themeManager)
        .onAppear {
            // Configure tab bar appearance to be solid
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct RetinopathyAnalysisView: View {
    @StateObject private var predictor = RetinopathyPredictor()
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background with better gradients
                AppBackgroundGradient.standard(themeColor: themeManager.selectedEyeColor.primaryColor)
                
                ScrollView {
                    LazyVStack(spacing: 35) {
                        // Enhanced header with better spacing
                        AppHeaderView(
                            title: "Diabetic Retinopathy Detection",
                            subtitle: "AI-powered retinal analysis for early detection and prevention of vision loss",
                            iconName: "stethoscope",
                            themeColor: themeManager.selectedEyeColor.primaryColor
                        )
                        .padding(.top, 15)
                        
                        // Enhanced image display with better padding
                        ImageDisplayView(
                            selectedImage: selectedImage,
                            placeholderTitle: "Fundus Image Analysis",
                            placeholderSubtitle: "Upload a retinal image from camera or gallery for AI analysis"
                        )
                        
                        // Enhanced action buttons with better spacing
                        ActionButtonsView(
                            onCameraAction: {
                                showingCamera = true
                            },
                            onGalleryAction: {
                                showingImagePicker = true
                            }
                        )
                        .padding(.horizontal, 10)
                        
                        // Enhanced analyze button with better padding
                        if selectedImage != nil {
                            AnalyzeButtonView(isAnalyzing: predictor.isAnalyzing) {
                                if let image = selectedImage {
                                    predictor.predict(image: image)
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        
                        // Enhanced results section with better spacing
                        ResultsSectionView(
                            predictionText: predictor.predictionText,
                            confidence: predictor.confidence,
                            themeColor: themeManager.selectedEyeColor.primaryColor
                        )
                        
                        // Enhanced info section with better padding
                        InfoSectionView(themeColor: themeManager.selectedEyeColor.primaryColor)
                        
                        // Bottom safe area padding
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 30)
                    }
                    .padding(.horizontal, 16)
                }
                .refreshable {
                    // Reset state on pull to refresh
                    selectedImage = nil
                    predictor.predictionText = "Take or select a photo to analyze"
                    predictor.confidence = 0.0
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
        .onAppear {
            // Preload model if needed
            if predictor.predictionText == "Take or select a photo to analyze" {
                // Model is ready
            }
        }
    }
}

#Preview {
    ContentView()
}
