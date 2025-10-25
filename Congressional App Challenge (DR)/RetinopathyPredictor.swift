//
//  RetinopathyPredictor.swift
//  Congressional App Challenge (DR)
//
//  Created by Ronit B on 7/25/25.
//

import CoreML
import Vision
import UIKit

class RetinopathyPredictor: ObservableObject {
    @Published var predictionText: String = "Take or select a photo to analyze"
    @Published var confidence: Double = 0.0
    @Published var isAnalyzing: Bool = false
    
    private let model: VNCoreMLModel?
    
    init() {
        // Initialize predictor
        // The model class name is auto-generated as "RetinopathyProbability"
        if let model = try? RetinopathyProbability(configuration: MLModelConfiguration()).model,
           let visionModel = try? VNCoreMLModel(for: model) {
            self.model = visionModel
            print("✅ RetinopathyProbability model loaded successfully")
        } else {
            self.model = nil
            print("❌ Error: Could not load RetinopathyProbability model")
        }
    }
    
    func predict(image: UIImage) {
        // Safe model check instead of force unwrapping
        guard let model = model else {
            predictionText = "AI model is not available. Please restart the app."
            return
        }
        
        guard let ciImage = CIImage(image: image) else {
            predictionText = "Error: Could not process image"
            return
        }
        
        isAnalyzing = true
        predictionText = "Analyzing retinal image..."
        confidence = 0.0
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isAnalyzing = false
                
                if let error = error {
                    self.predictionText = "Analysis failed: \(error.localizedDescription)"
                    return
                }
                
                guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                      let firstResult = results.first,
                      let multiArray = firstResult.featureValue.multiArrayValue,
                      multiArray.count > 0 else {
                    self.predictionText = "Could not interpret analysis results"
                    return
                }
                
                // Safely get and validate the probability
                let probabilityValue = Double(truncating: multiArray[0])
                self.confidence = max(0.0, min(1.0, probabilityValue)) // Clamp between 0 and 1
                
                // Provide detailed, helpful results
                let percentage = self.confidence * 100
                
                if self.confidence > 0.7 {
                    self.predictionText = "High likelihood of diabetic retinopathy detected (\(String(format: "%.1f", percentage))%)\n\nRecommendation: Consult an ophthalmologist immediately."
                } else if self.confidence > 0.5 {
                    self.predictionText = "Moderate signs detected (\(String(format: "%.1f", percentage))%)\n\nRecommendation: Schedule an eye exam soon."
                } else if self.confidence > 0.3 {
                    self.predictionText = "Mild signs detected (\(String(format: "%.1f", percentage))%)\n\nRecommendation: Monitor and maintain regular checkups."
                } else {
                    self.predictionText = "No significant signs detected (\(String(format: "%.1f", percentage))%)\n\nRecommendation: Continue regular monitoring."
                }
            }
        }
        
        // Safe request handling with error catching
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                    self.predictionText = "Processing failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
