//
//  EyeTestsView.swift
//  Congressional App Challenge (DR)
//
//  Created by GitHub Copilot on 9/7/25.
//

import SwiftUI

struct EyeTestsView: View {
    @State private var selectedTest: TestType = .visualAcuity
    @State private var currentTestStep = 0
    @State private var testResults: [String: String] = [:]
    @State private var showingResults = false
    @State private var isTestActive = false
    @EnvironmentObject var themeManager: ThemeManager
    
    enum TestType: String, CaseIterable {
        case visualAcuity = "Visual Acuity"
        case colorBlind = "Color Blindness"
        case astigmatism = "Astigmatism"
        case contrastSensitivity = "Contrast Sensitivity"
        case peripheralVision = "Peripheral Vision"
        case amslerGrid = "Amsler Grid"
        
        var icon: String {
            switch self {
            case .visualAcuity: return "eye.circle.fill"
            case .colorBlind: return "paintpalette.fill"
            case .astigmatism: return "grid.circle.fill"
            case .contrastSensitivity: return "circle.lefthalf.striped.horizontal"
            case .peripheralVision: return "viewfinder.circle.fill"
            case .amslerGrid: return "grid.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .visualAcuity: return .blue
            case .colorBlind: return .orange
            case .astigmatism: return .green
            case .contrastSensitivity: return .indigo
            case .peripheralVision: return .teal
            case .amslerGrid: return .brown
            }
        }
        
        var description: String {
            switch self {
            case .visualAcuity: return "Test sharpness of vision"
            case .colorBlind: return "Detect color vision deficiencies"
            case .astigmatism: return "Check for corneal irregularities"
            case .contrastSensitivity: return "Assess low-light vision"
            case .peripheralVision: return "Evaluate side vision"
            case .amslerGrid: return "Screen for macular issues"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient using selected eye color
                themeManager.selectedEyeColor.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced Header - only show when not in test
                    if !isTestActive {
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
                                
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Eye Vision Tests")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: themeManager.selectedEyeColor.gradientColors),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("Comprehensive vision screening suite")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                    
                    // Test Selection
                    if !isTestActive {
                        ScrollView {
                            VStack(spacing: 30) {
                                // Enhanced Test Grid
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ], spacing: 20) {
                                    ForEach(TestType.allCases, id: \.self) { test in
                                        EnhancedTestCard(
                                            test: test,
                                            isSelected: selectedTest == test,
                                            themeColor: themeManager.selectedEyeColor.primaryColor,
                                            action: {
                                                selectedTest = test
                                                startTest()
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                // Enhanced Results Summary
                                if !testResults.isEmpty {
                                    VStack(alignment: .leading, spacing: 20) {
                                        HStack {
                                            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                                                .foregroundColor(themeManager.selectedEyeColor.primaryColor)
                                            Text("Test Results Summary")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                        }
                                        .padding(.horizontal, 20)
                                        
                                        VStack(spacing: 12) {
                                            ForEach(Array(testResults.keys.sorted()), id: \.self) { key in
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.white)
                                                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                                                    
                                                    HStack {
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text(key)
                                                                .font(.subheadline)
                                                                .fontWeight(.medium)
                                                                .foregroundColor(.primary)
                                                            
                                                            Text(testResults[key] ?? "")
                                                                .font(.caption)
                                                                .foregroundColor(.secondary)
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(.green)
                                                            .font(.title3)
                                                    }
                                                    .padding(16)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                    .padding(.top, 10)
                                }
                                
                                Spacer(minLength: 30)
                            }
                        }
                    } else {
                        // Active Test View with enhanced background and back button
                        VStack(spacing: 0) {
                            // Back Button Header
                            HStack {
                                Button(action: {
                                    endTest()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "chevron.left")
                                            .font(.title2)
                                            .fontWeight(.medium)
                                        Text("Back")
                                            .font(.headline)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(themeManager.selectedEyeColor.primaryColor)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .shadow(color: themeManager.selectedEyeColor.primaryColor.opacity(0.2), radius: 8, x: 0, y: 4)
                                    )
                                }
                                .padding(.leading, 20)
                                
                                Spacer()
                                
                                // Test Title
                                VStack(spacing: 4) {
                                    Text(selectedTest.rawValue)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text(selectedTest.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Placeholder for balance
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 80, height: 44)
                                    .padding(.trailing, 20)
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                            .background(
                                Color(.systemBackground)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                            
                            // Test Content Area
                            ZStack {
                                Color(.systemBackground)
                                    .ignoresSafeArea()
                                
                                currentTestView
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private var currentTestView: some View {
        switch selectedTest {
        case .visualAcuity:
            VisualAcuityTest(
                currentStep: $currentTestStep,
                themeColor: themeManager.selectedEyeColor.primaryColor,
                onComplete: { result in
                    testResults[selectedTest.rawValue] = result
                    endTest()
                }
            )
        case .colorBlind:
            ColorBlindnessTest(
                currentStep: $currentTestStep,
                themeColor: themeManager.selectedEyeColor.primaryColor,
                onComplete: { result in
                    testResults[selectedTest.rawValue] = result
                    endTest()
                }
            )
        case .astigmatism:
            AstigmatismTest(
                currentStep: $currentTestStep,
                themeColor: themeManager.selectedEyeColor.primaryColor,
                onComplete: { result in
                    testResults[selectedTest.rawValue] = result
                    endTest()
                }
            )
        case .contrastSensitivity:
            ContrastSensitivityTest(
                currentStep: $currentTestStep,
                themeColor: themeManager.selectedEyeColor.primaryColor,
                onComplete: { result in
                    testResults[selectedTest.rawValue] = result
                    endTest()
                }
            )
        case .peripheralVision:
            PeripheralVisionTest(
                currentStep: $currentTestStep,
                themeColor: themeManager.selectedEyeColor.primaryColor,
                onComplete: { result in
                    testResults[selectedTest.rawValue] = result
                    endTest()
                }
            )
        case .amslerGrid:
            AmslerGridTest(
                currentStep: $currentTestStep,
                themeColor: themeManager.selectedEyeColor.primaryColor,
                onComplete: { result in
                    testResults[selectedTest.rawValue] = result
                    endTest()
                }
            )
        }
    }
    
    private func startTest() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isTestActive = true
            currentTestStep = 0
        }
    }
    
    private func endTest() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isTestActive = false
            currentTestStep = 0
        }
    }
}

// Enhanced Test Card Component
struct EnhancedTestCard: View {
    let test: EyeTestsView.TestType
    let isSelected: Bool
    let themeColor: Color
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
                                    gradient: Gradient(colors: [test.color.opacity(0.3), test.color.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 2 : 0
                            )
                    )
                
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [test.color.opacity(0.8), test.color]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .shadow(color: test.color.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: test.icon)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 4) {
                        Text(test.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text(test.description)
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

// MARK: - Test Button Style
struct TestButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
                    .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Modern Button Style
struct ModernButtonStyle: ButtonStyle {
    let color: Color
    let isLarge: Bool
    
    init(color: Color, isLarge: Bool = false) {
        self.color = color
        self.isLarge = isLarge
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(isLarge ? .headline : .subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, isLarge ? 30 : 20)
            .padding(.vertical, isLarge ? 16 : 12)
            .background(
                RoundedRectangle(cornerRadius: isLarge ? 16 : 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Visual Acuity Test
struct VisualAcuityTest: View {
    @Binding var currentStep: Int
    let themeColor: Color
    let onComplete: (String) -> Void
    
    @State private var correctAnswers = 0
    @State private var showInstructions = true
    
    private let acuityLines = [
        ("E", 60, "20/200"),
        ("F P", 40, "20/100"),
        ("T O Z", 30, "20/70"),
        ("L P E D", 25, "20/50"),
        ("F E D F C Z P", 20, "20/40"),
        ("F P T O Z L P E D", 15, "20/30"),
        ("P E Z O L C F T D", 12, "20/25"),
        ("E D F C Z P L O T Z D", 10, "20/20")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            if showInstructions {
                instructionsView
            } else {
                testView
            }
        }
        .padding()
    }
    
    private var instructionsView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 15) {
                Image(systemName: "eye.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(themeColor)
                
                Text("Visual Acuity Test")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Instructions")
                    .font(.headline)
                    .foregroundColor(themeColor)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                InstructionRow(icon: "1.circle.fill", text: "Hold your device at arm's length")
                InstructionRow(icon: "2.circle.fill", text: "Cover one eye with your hand")
                InstructionRow(icon: "3.circle.fill", text: "Read the letters displayed on each line")
                InstructionRow(icon: "4.circle.fill", text: "Indicate if you can read them clearly")
                InstructionRow(icon: "5.circle.fill", text: "Repeat for the other eye after completion")
            }
            
            Spacer()
            
            Button("Start Test") {
                withAnimation {
                    showInstructions = false
                }
            }
            .buttonStyle(TestButtonStyle(color: themeColor))
        }
    }
    
    private var testView: some View {
        VStack(spacing: 30) {
            // Progress indicator
            VStack(spacing: 10) {
                Text("Visual Acuity Test")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Line \(currentStep + 1) of \(acuityLines.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ProgressView(value: Double(currentStep), total: Double(acuityLines.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: themeColor))
                    .frame(width: 200)
            }
            
            Spacer()
            
            // Letter display
            if currentStep < acuityLines.count {
                VStack(spacing: 20) {
                    Text(acuityLines[currentStep].0)
                        .font(.system(size: CGFloat(acuityLines[currentStep].1), weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
                    Text(acuityLines[currentStep].2)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Response buttons
            VStack(spacing: 15) {
                Text("Can you read these letters clearly?")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 20) {
                    Button("Yes, clearly") {
                        correctAnswers += 1
                        nextStep()
                    }
                    .buttonStyle(TestButtonStyle(color: .green))
                    
                    Button("No, blurry") {
                        nextStep()
                    }
                    .buttonStyle(TestButtonStyle(color: .red))
                }
                
                Button("Skip this line") {
                    nextStep()
                }
                .buttonStyle(TestButtonStyle(color: .gray))
            }
        }
    }
    
    private func nextStep() {
        if currentStep < acuityLines.count - 1 {
            withAnimation {
                currentStep += 1
            }
        } else {
            let vision = calculateVision()
            onComplete(vision)
        }
    }
    
    private func calculateVision() -> String {
        let percentage = (Double(correctAnswers) / Double(acuityLines.count)) * 100.0
        let visionLevel = max(200 - (correctAnswers * 25), 20)
        return "20/\(visionLevel) (\(Int(percentage))% accuracy)"
    }
}

// MARK: - Color Blindness Test
struct ColorBlindnessTest: View {
    @Binding var currentStep: Int
    let themeColor: Color
    let onComplete: (String) -> Void
    
    @State private var correctAnswers = 0
    @State private var showInstructions = true
    @State private var redGreenDefects = 0
    @State private var blueYellowDefects = 0
    @State private var totalDefects = 0
    
    // CORRECTED - Based on YOUR actual images with real numbers and colors
    private let ishiharaPlates: [(imageName: String, correctAnswer: String, alternativeAnswers: [String], description: String, testType: ColorDeficiencyType, colorBlindSees: String)] = [
        (
            imageName: "plate1",
            correctAnswer: "45",
            alternativeAnswers: ["48", "43", "Nothing visible"],
            description: "Control plate - everyone should see 45 (orange/red on green/brown)",
            testType: .control,
            colorBlindSees: "45"
        ),
        (
            imageName: "plate2",
            correctAnswer: "42",
            alternativeAnswers: ["24", "47", "Nothing visible"],
            description: "Pink/orange numbers test (42 on black background)",
            testType: .redGreen,
            colorBlindSees: "Nothing visible"
        ),
        (
            imageName: "plate3",
            correctAnswer: "5",
            alternativeAnswers: ["8", "3", "Nothing visible"],
            description: "Purple number test (5 on blue dots)",
            testType: .blueYellow,
            colorBlindSees: "Nothing visible"
        ),
        (
            imageName: "plate4",
            correctAnswer: "57",
            alternativeAnswers: ["37", "51", "Nothing visible"],
            description: "Light red/pink numbers (57 on brown/black)",
            testType: .redGreen,
            colorBlindSees: "Nothing visible"
        ),
        (
            imageName: "plate5",
            correctAnswer: "6",
            alternativeAnswers: ["9", "8", "Nothing visible"],
            description: "Light orange/red number (6 on dark brown/red)",
            testType: .redGreen,
            colorBlindSees: "Nothing visible"
        ),
        (
            imageName: "plate6",
            correctAnswer: "5",
            alternativeAnswers: ["2", "8", "Nothing visible"],
            description: "Green number test (5 on red/pink with yellow dots)",
            testType: .redGreen,
            colorBlindSees: "Nothing visible"
        ),
        (
            imageName: "plate7",
            correctAnswer: "74",
            alternativeAnswers: ["21", "71", "Nothing visible"],
            description: "Green numbers (74 on light red/orange background)",
            testType: .redGreen,
            colorBlindSees: "21"
        )
    ]
    
    enum ColorDeficiencyType {
        case control, redGreen, blueYellow
    }
    
    private var currentPlateAnswerOptions: [String] {
        if currentStep < ishiharaPlates.count {
            let plate = ishiharaPlates[currentStep]
            var options = [plate.correctAnswer]
            options.append(contentsOf: plate.alternativeAnswers)
            options.append("No number visible")
            options.append("Unclear/Different number")
            return options.shuffled()
        }
        return ["No number visible"]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if showInstructions {
                // Medical-grade instructions
                VStack(spacing: 20) {
                    Text("Ishihara Color Vision Test")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(themeColor)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Instructions:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InstructionRow(icon: "lightbulb.fill", text: "Use bright, natural lighting")
                            InstructionRow(icon: "ruler.fill", text: "Hold device 18-24 inches from eyes")
                            InstructionRow(icon: "clock.fill", text: "Look at each plate for 3-5 seconds")
                            InstructionRow(icon: "eye.fill", text: "Say the first number you see")
                            InstructionRow(icon: "exclamationmark.triangle.fill", text: "Don't guess - trust your first impression")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    VStack(spacing: 8) {
                        Text("⚠️ Medical Disclaimer")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("This is a screening tool only. For professional diagnosis, consult an eye care specialist.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Begin Test") {
                        showInstructions = false
                    }
                    .buttonStyle(ModernButtonStyle(color: themeColor, isLarge: true))
                }
                .padding()
                
            } else if currentStep < ishiharaPlates.count {
                // Current test plate
                VStack(spacing: 20) {
                    // Progress indicator
                    HStack {
                        Text("Plate \(currentStep + 1) of \(ishiharaPlates.count)")
                            .font(.headline)
                            .foregroundColor(themeColor)
                        
                        Spacer()
                        
                        Text("\(Int((Double(currentStep) / Double(ishiharaPlates.count)) * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: Double(currentStep), total: Double(ishiharaPlates.count))
                        .accentColor(themeColor)
                    
                    // Test plate image
                    VStack(spacing: 15) {
                        Text(ishiharaPlates[currentStep].description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Display the actual Ishihara test image
                        if let image = UIImage(named: ishiharaPlates[currentStep].imageName) ??
                                      UIImage(named: "Screenshot 2025-10-12 at 1.54.33 PM") ??
                                      UIImage(named: "Screenshot 2025-10-12 at 1.55.02 PM") {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 300, maxHeight: 300)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(themeColor, lineWidth: 3)
                                )
                                .shadow(color: themeColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        } else {
                            // Fallback - generate a basic Ishihara-style pattern
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 300, height: 300)
                                
                                // Generate simple dot pattern
                                ForEach(0..<200, id: \.self) { i in
                                    Circle()
                                        .fill(Color.red.opacity(Double.random(in: 0.3...0.8)))
                                        .frame(width: CGFloat.random(in: 8...16), height: CGFloat.random(in: 8...16))
                                        .position(
                                            x: CGFloat.random(in: 50...250),
                                            y: CGFloat.random(in: 50...250)
                                        )
                                }
                                
                                // Display the number in contrasting color
                                Text(ishiharaPlates[currentStep].correctAnswer)
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(.green.opacity(0.7))
                            }
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(themeColor, lineWidth: 3)
                            )
                            .shadow(color: themeColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        Text("What number do you see?")
                            .font(.headline)
                            .foregroundColor(themeColor)
                    }
                    
                    // Answer options
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(currentPlateAnswerOptions, id: \.self) { option in
                            Button(option) {
                                checkAnswer(selectedAnswer: option)
                            }
                            .buttonStyle(AnswerButtonStyle(isSelected: false))
                        }
                    }
                }
                .padding()
                
            } else {
                // Results screen
                ColorBlindnessResultsView(
                    correctAnswers: correctAnswers,
                    totalQuestions: ishiharaPlates.count,
                    redGreenDefects: redGreenDefects,
                    blueYellowDefects: blueYellowDefects,
                    themeColor: themeColor,
                    onComplete: {
                        let diagnosis = generateDiagnosis()
                        onComplete(diagnosis)
                    }
                )
            }
        }
    }
    
    private func checkAnswer(selectedAnswer: String) {
        let currentPlate = ishiharaPlates[currentStep]
        
        if selectedAnswer == currentPlate.correctAnswer {
            correctAnswers += 1
        } else {
            // Track type of deficiency
            switch currentPlate.testType {
            case .redGreen:
                redGreenDefects += 1
            case .blueYellow:
                blueYellowDefects += 1
            case .control:
                totalDefects += 1
            }
        }
        
        currentStep += 1
    }
    
    private func generateDiagnosis() -> String {
        let accuracy = Double(correctAnswers) / Double(ishiharaPlates.count) * 100
        
        if correctAnswers == ishiharaPlates.count {
            return "Normal Color Vision - Perfect score (\(Int(accuracy))%)"
        } else if redGreenDefects >= 3 {
            return "Red-Green Color Vision Deficiency detected - \(correctAnswers)/\(ishiharaPlates.count) correct (\(Int(accuracy))%). Recommend consulting an eye care professional."
        } else if redGreenDefects >= 2 {
            return "Mild Red-Green Color Vision Difficulty - \(correctAnswers)/\(ishiharaPlates.count) correct (\(Int(accuracy))%). Consider professional evaluation."
        } else if blueYellowDefects >= 2 {
            return "Blue-Yellow Color Vision Deficiency detected - \(correctAnswers)/\(ishiharaPlates.count) correct (\(Int(accuracy))%). Recommend professional evaluation."
        } else {
            return "Normal Color Vision with minor variations - \(correctAnswers)/\(ishiharaPlates.count) correct (\(Int(accuracy))%)"
        }
    }
}

struct ColorBlindnessResultsView: View {
    let correctAnswers: Int
    let totalQuestions: Int
    let redGreenDefects: Int
    let blueYellowDefects: Int
    let themeColor: Color
    let onComplete: () -> Void
    
    private var accuracy: Double {
        Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    private var diagnosisColor: Color {
        if correctAnswers == totalQuestions { return .green }
        else if redGreenDefects >= 3 || blueYellowDefects >= 2 { return .red }
        else if redGreenDefects >= 2 { return .orange }
        else { return .blue }
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            VStack(spacing: 15) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(diagnosisColor)
                
                Text("Color Vision Test Complete")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(themeColor)
            }
            
            // Results summary
            VStack(spacing: 20) {
                // Accuracy circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: accuracy / 100)
                        .stroke(diagnosisColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.5), value: accuracy)
                    
                    VStack {
                        Text("\(Int(accuracy))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(diagnosisColor)
                        
                        Text("Accuracy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Detailed results
                VStack(spacing: 15) {
                    ResultRow(label: "Correct Answers", value: "\(correctAnswers)/\(totalQuestions)", color: .green)
                    ResultRow(label: "Red-Green Issues", value: "\(redGreenDefects)", color: redGreenDefects > 0 ? .red : .green)
                    ResultRow(label: "Blue-Yellow Issues", value: "\(blueYellowDefects)", color: blueYellowDefects > 0 ? .red : .green)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Diagnosis
                VStack(spacing: 10) {
                    Text("Diagnosis:")
                        .font(.headline)
                        .foregroundColor(themeColor)
                    
                    Text(generateDetailedDiagnosis())
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(diagnosisColor.opacity(0.1))
                        .foregroundColor(diagnosisColor)
                        .cornerRadius(8)
                }
                
                // Medical recommendation
                if redGreenDefects >= 2 || blueYellowDefects >= 1 {
                    VStack(spacing: 8) {
                        Text("⚕️ Recommendation")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("Schedule an appointment with an optometrist or ophthalmologist for comprehensive color vision testing and professional diagnosis.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Button("Continue") {
                onComplete()
            }
            .buttonStyle(ModernButtonStyle(color: themeColor, isLarge: true))
        }
        .padding()
    }
    
    private func generateDetailedDiagnosis() -> String {
        if correctAnswers == totalQuestions {
            return "Normal Color Vision - You correctly identified all color plates. Your color vision appears normal."
        } else if redGreenDefects >= 3 {
            return "Red-Green Color Vision Deficiency (Protanopia/Deuteranopia) - You may have difficulty distinguishing between red and green colors."
        } else if redGreenDefects >= 2 {
            return "Mild Red-Green Color Vision Difficulty - You show some challenges with red-green color discrimination."
        } else if blueYellowDefects >= 2 {
            return "Blue-Yellow Color Vision Deficiency (Tritanopia) - You may have difficulty distinguishing between blue and yellow colors."
        } else {
            return "Normal Color Vision with Minor Variations - Your color vision is within normal range with slight variations."
        }
    }
}

struct ResultRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct AnswerButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isSelected ? Color.blue.opacity(0.3) :
                        configuration.isPressed ? Color.gray.opacity(0.3) :
                        Color.gray.opacity(0.1)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? Color.blue :
                        Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Astigmatism Test
struct AstigmatismTest: View {
    @Binding var currentStep: Int
    let themeColor: Color
    let onComplete: (String) -> Void
    
    @State private var responses: [Int] = []
    @State private var showInstructions = true
    
    private let angles = [0, 30, 60, 90, 120, 150]
    
    var body: some View {
        VStack(spacing: 20) {
            if showInstructions {
                instructionsView
            } else {
                testView
            }
        }
        .padding()
    }
    
    private var instructionsView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 15) {
                Image(systemName: "grid.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(themeColor)
                
                Text("Astigmatism Test")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Instructions")
                    .font(.headline)
                    .foregroundColor(themeColor)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                InstructionRow(icon: "1.circle.fill", text: "Look at the radiating line patterns")
                InstructionRow(icon: "2.circle.fill", text: "Some lines may appear darker or clearer")
                InstructionRow(icon: "3.circle.fill", text: "Rate the clarity of each pattern")
                InstructionRow(icon: "4.circle.fill", text: "Cover one eye at a time")
            }
            
            Spacer()
            
            Button("Start Test") {
                withAnimation {
                    showInstructions = false
                }
            }
            .buttonStyle(TestButtonStyle(color: themeColor))
        }
    }
    
    private var testView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Astigmatism Test")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Pattern \(currentStep + 1) of \(angles.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ProgressView(value: Double(currentStep), total: Double(angles.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: themeColor))
                    .frame(width: 200)
            }
            
            Spacer()
            
            if currentStep < angles.count {
                VStack(spacing: 20) {
                    ZStack {
                        Canvas { context, size in
                            let center = CGPoint(x: size.width / 2, y: size.height / 2)
                            let radius = min(size.width, size.height) / 2.5
                            
                            for i in 0..<12 {
                                let angle = Double(i) * 30 * .pi / 180
                                let startPoint = CGPoint(
                                    x: center.x + CGFloat(cos(angle)) * radius * 0.3,
                                    y: center.y + CGFloat(sin(angle)) * radius * 0.3
                                )
                                let endPoint = CGPoint(
                                    x: center.x + CGFloat(cos(angle)) * radius,
                                    y: center.y + CGFloat(sin(angle)) * radius
                                )
                                
                                var path = Path()
                                path.move(to: startPoint)
                                path.addLine(to: endPoint)
                                
                                let opacity = (i == angles[currentStep] / 30) ? 1.0 : 0.3
                                context.stroke(path, with: .color(.black.opacity(opacity)), lineWidth: 2)
                            }
                        }
                        .frame(width: 200, height: 200)
                    }
                    
                    Text("Focus on the line at \(angles[currentStep])° angle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Text("How clear does this line appear?")
                    .font(.headline)
                
                HStack(spacing: 15) {
                    ForEach(1...5, id: \.self) { rating in
                        Button("\(rating)") {
                            recordResponse(rating)
                        }
                        .buttonStyle(TestButtonStyle(color: themeColor))
                    }
                }
                
                Text("1 = Very Blurry, 5 = Very Clear")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func recordResponse(_ rating: Int) {
        responses.append(rating)
        
        if currentStep < angles.count - 1 {
            withAnimation {
                currentStep += 1
            }
        } else {
            let result = calculateAstigmatismResult()
            onComplete(result)
        }
    }
    
    private func calculateAstigmatismResult() -> String {
        let average = Double(responses.reduce(0, +)) / Double(responses.count)
        let variance = responses.map { Double($0) - average }.map { $0 * $0 }.reduce(0, +) / Double(responses.count)
        
        if variance < 0.5 {
            return "No significant astigmatism detected (variance: \(String(format: "%.2f", variance)))"
        } else if variance < 1.5 {
            return "Mild astigmatism possible (variance: \(String(format: "%.2f", variance)))"
        } else {
            return "Astigmatism detected - recommend professional examination (variance: \(String(format: "%.2f", variance)))"
        }
    }
}

// MARK: - Contrast Sensitivity Test
struct ContrastSensitivityTest: View {
    @Binding var currentStep: Int
    let themeColor: Color
    let onComplete: (String) -> Void
    
    @State private var correctAnswers = 0
    @State private var showInstructions = true
    
    private let contrastLevels = [0.9, 0.7, 0.5, 0.3, 0.2, 0.1, 0.05]
    
    var body: some View {
        VStack(spacing: 20) {
            if showInstructions {
                instructionsView
            } else {
                testView
            }
        }
        .padding()
    }
    
    private var instructionsView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 15) {
                Image(systemName: "circle.lefthalf.striped.horizontal")
                    .font(.system(size: 60))
                    .foregroundColor(themeColor)
                
                Text("Contrast Sensitivity Test")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Instructions")
                    .font(.headline)
                    .foregroundColor(themeColor)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                InstructionRow(icon: "1.circle.fill", text: "Look for faint circles on the screen")
                InstructionRow(icon: "2.circle.fill", text: "Circles will get progressively fainter")
                InstructionRow(icon: "3.circle.fill", text: "Tap 'Yes' if you can see the circle")
                InstructionRow(icon: "4.circle.fill", text: "Tap 'No' if you cannot see it")
            }
            
            Spacer()
            
            Button("Start Test") {
                withAnimation {
                    showInstructions = false
                }
            }
            .buttonStyle(TestButtonStyle(color: themeColor))
        }
    }
    
    private var testView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Contrast Sensitivity Test")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Level \(currentStep + 1) of \(contrastLevels.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ProgressView(value: Double(currentStep), total: Double(contrastLevels.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: themeColor))
                    .frame(width: 200)
            }
            
            Spacer()
            
            if currentStep < contrastLevels.count {
                VStack(spacing: 20) {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 300, height: 300)
                        
                        Circle()
                            .fill(Color.black.opacity(contrastLevels[currentStep]))
                            .frame(width: 100, height: 100)
                    }
                    
                    Text("Contrast Level: \(Int(contrastLevels[currentStep] * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Text("Can you see the circle?")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    Button("Yes") {
                        correctAnswers += 1
                        nextStep()
                    }
                    .buttonStyle(TestButtonStyle(color: .green))
                    
                    Button("No") {
                        nextStep()
                    }
                    .buttonStyle(TestButtonStyle(color: .red))
                }
            }
        }
    }
    
    private func nextStep() {
        if currentStep < contrastLevels.count - 1 {
            withAnimation {
                currentStep += 1
            }
        } else {
            let result = calculateContrastResult()
            onComplete(result)
        }
    }
    
    private func calculateContrastResult() -> String {
        let percentage = (Double(correctAnswers) / Double(contrastLevels.count)) * 100.0
        
        if percentage >= 80 {
            return "Excellent contrast sensitivity (\(Int(percentage))%)"
        } else if percentage >= 60 {
            return "Good contrast sensitivity (\(Int(percentage))%)"
        } else if percentage >= 40 {
            return "Reduced contrast sensitivity (\(Int(percentage))%) - Consider professional evaluation"
        } else {
            return "Poor contrast sensitivity (\(Int(percentage))%) - Professional examination recommended"
        }
    }
}

// MARK: - Peripheral Vision Test
struct PeripheralVisionTest: View {
    @Binding var currentStep: Int
    let themeColor: Color
    let onComplete: (String) -> Void
    
    @State private var showInstructions = true
    @State private var detectedPositions: Set<Int> = []
    @State private var currentPosition = 0
    
    private let testPositions = [(45, 45), (45, -45), (-45, 45), (-45, -45), (90, 0), (-90, 0), (0, 90), (0, -90)]
    
    var body: some View {
        VStack(spacing: 20) {
            if showInstructions {
                instructionsView
            } else {
                testView
            }
        }
        .padding()
    }
    
    private var instructionsView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 15) {
                Image(systemName: "viewfinder.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(themeColor)
                
                Text("Peripheral Vision Test")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Instructions")
                    .font(.headline)
                    .foregroundColor(themeColor)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                InstructionRow(icon: "1.circle.fill", text: "Keep your eyes on the center dot")
                InstructionRow(icon: "2.circle.fill", text: "Don't move your eyes from center")
                InstructionRow(icon: "3.circle.fill", text: "Tap when you see dots appear at the edges")
                InstructionRow(icon: "4.circle.fill", text: "Only use your peripheral vision")
            }
            
            Spacer()
            
            Button("Start Test") {
                withAnimation {
                    showInstructions = false
                }
            }
            .buttonStyle(TestButtonStyle(color: themeColor))
        }
    }
    
    private var testView: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.1)
                
                // Center fixation point
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Peripheral test dots
                if currentPosition < testPositions.count {
                    let position = testPositions[currentPosition]
                    Circle()
                        .fill(themeColor)
                        .frame(width: 20, height: 20)
                        .position(
                            x: geometry.size.width / 2 + CGFloat(position.0) * 2,
                            y: geometry.size.height / 2 + CGFloat(position.1) * 2
                        )
                        .onTapGesture {
                            detectedPositions.insert(currentPosition)
                            nextPosition()
                        }
                }
                
                // Instructions overlay
                VStack {
                    Text("Keep looking at the red dot")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                    
                    Spacer()
                    
                    Text("Position \(currentPosition + 1) of \(testPositions.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .onTapGesture {
                // Auto advance if no detection after tap
                nextPosition()
            }
        }
    }
    
    private func nextPosition() {
        if currentPosition < testPositions.count - 1 {
            withAnimation {
                currentPosition += 1
            }
        } else {
            let result = calculatePeripheralResult()
            onComplete(result)
        }
    }
    
    private func calculatePeripheralResult() -> String {
        let detected = detectedPositions.count
        let total = testPositions.count
        let percentage = (Double(detected) / Double(total)) * 100.0
        
        if percentage >= 75 {
            return "Normal peripheral vision (\(detected)/\(total) detected)"
        } else if percentage >= 50 {
            return "Mild peripheral vision loss (\(detected)/\(total) detected)"
        } else {
            return "Significant peripheral vision loss (\(detected)/\(total) detected) - Seek professional evaluation"
        }
    }
}

// MARK: - Amsler Grid Test
struct AmslerGridTest: View {
    @Binding var currentStep: Int
    let themeColor: Color
    let onComplete: (String) -> Void
    
    @State private var showInstructions = true
    @State private var hasDistortions = false
    @State private var hasMissingAreas = false
    
    var body: some View {
        VStack(spacing: 20) {
            if showInstructions {
                instructionsView
            } else {
                testView
            }
        }
        .padding()
    }
    
    private var instructionsView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 15) {
                Image(systemName: "grid.circle")
                    .font(.system(size: 60))
                    .foregroundColor(themeColor)
                
                Text("Amsler Grid Test")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Instructions")
                    .font(.headline)
                    .foregroundColor(themeColor)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                InstructionRow(icon: "1.circle.fill", text: "Cover one eye and focus on the center dot")
                InstructionRow(icon: "2.circle.fill", text: "Keep looking at the center dot")
                InstructionRow(icon: "3.circle.fill", text: "Notice if any lines appear wavy or missing")
                InstructionRow(icon: "4.circle.fill", text: "Report any distortions you see")
            }
            
            Spacer()
            
            Button("Start Test") {
                withAnimation {
                    showInstructions = false
                }
            }
            .buttonStyle(TestButtonStyle(color: themeColor))
        }
    }
    
    private var testView: some View {
        VStack(spacing: 30) {
            Text("Amsler Grid Test")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 20) {
                ZStack {
                    // Grid background
                    Canvas { context, size in
                        let gridSize = min(size.width, size.height) * 0.8
                        let cellSize = gridSize / 20
                        let startX = (size.width - gridSize) / 2
                        let startY = (size.height - gridSize) / 2
                        
                        // Draw grid lines
                        for i in 0...20 {
                            let x = startX + CGFloat(i) * cellSize
                            let y = startY + CGFloat(i) * cellSize
                            
                            // Vertical lines
                            var verticalPath = Path()
                            verticalPath.move(to: CGPoint(x: x, y: startY))
                            verticalPath.addLine(to: CGPoint(x: x, y: startY + gridSize))
                            context.stroke(verticalPath, with: .color(.black), lineWidth: 1)
                            
                            // Horizontal lines
                            var horizontalPath = Path()
                            horizontalPath.move(to: CGPoint(x: startX, y: y))
                            horizontalPath.addLine(to: CGPoint(x: startX + gridSize, y: y))
                            context.stroke(horizontalPath, with: .color(.black), lineWidth: 1)
                        }
                        
                        // Center dot
                        let centerX = size.width / 2
                        let centerY = size.height / 2
                        context.fill(
                            Path(ellipseIn: CGRect(x: centerX - 3, y: centerY - 3, width: 6, height: 6)),
                            with: .color(.red)
                        )
                    }
                    .frame(width: 300, height: 300)
                    .background(Color.white)
                    .border(Color.black, width: 2)
                }
                
                Text("Keep your eyes on the red center dot")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Text("Do you notice any of the following?")
                    .font(.headline)
                
                VStack(spacing: 10) {
                    Button("Wavy or bent lines") {
                        hasDistortions = true
                        completeTest()
                    }
                    .buttonStyle(TestButtonStyle(color: .orange))
                    
                    Button("Missing or dark areas") {
                        hasMissingAreas = true
                        completeTest()
                    }
                    .buttonStyle(TestButtonStyle(color: .red))
                    
                    Button("Grid looks normal") {
                        completeTest()
                    }
                    .buttonStyle(TestButtonStyle(color: .green))
                }
            }
        }
    }
    
    private func completeTest() {
        let result = calculateAmslerResult()
        onComplete(result)
    }
    
    private func calculateAmslerResult() -> String {
        if hasDistortions || hasMissingAreas {
            var issues: [String] = []
            if hasDistortions { issues.append("line distortions") }
            if hasMissingAreas { issues.append("missing areas") }
            return "Potential macular issues detected (\(issues.joined(separator: ", "))) - Seek immediate professional evaluation"
        } else {
            return "Normal Amsler grid test - No obvious macular distortions detected"
        }
    }
}

// MARK: - Instruction Row Helper
struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    EyeTestsView()
        .environmentObject(ThemeManager())
}
