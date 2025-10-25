//
//  SHAPPredictor.swift
//  Congressional App Challenge (DR)
//
//  Created by Ronit B on 8/11/25.
//

import CoreML
import Vision
import UIKit
import Foundation

struct SHAPResult {
    let explanationImage: UIImage?
    let analysisText: String
    let confidence: Double
    let shapValues: [Double]
    let importantRegions: [(region: CGRect, shapValue: Double)]
}

class SHAPPredictor: ObservableObject {
    @Published var predictionText: String = "Take or select a photo for SHAP explanation"
    @Published var confidence: Double = 0.0
    @Published var isAnalyzing: Bool = false
    @Published var explanationImage: UIImage?
    @Published var shapImage: UIImage? // Add this property that SHAPView expects
    
    private let model: VNCoreMLModel?
    
    init() {
        // Initialize with the same model as RetinopathyPredictor
        if let model = try? RetinopathyProbability(configuration: MLModelConfiguration()).model,
           let visionModel = try? VNCoreMLModel(for: model) {
            self.model = visionModel
            print("✅ SHAP: RetinopathyProbability model loaded successfully")
        } else {
            self.model = nil
            print("❌ SHAP Error: Could not load RetinopathyProbability model")
        }
    }
    
    // Add the generateSHAP method that SHAPView is calling
    func generateSHAP(image: UIImage) {
        explainWithSHAP(image: image)
    }
    
    func explainWithSHAP(image: UIImage) {
        guard let model = model else {
            predictionText = "Error: Model not available"
            return
        }
        
        isAnalyzing = true
        predictionText = "Generating SHAP explanation..."
        explanationImage = nil
        shapImage = nil // Reset shapImage as well
        
        DispatchQueue.global(qos: .userInitiated).async {
            autoreleasepool {
                self.performSHAPAnalysis(image: image, model: model) { [weak self] result in
                    DispatchQueue.main.async {
                        self?.isAnalyzing = false
                        self?.confidence = result.confidence
                        self?.predictionText = result.analysisText
                        self?.explanationImage = result.explanationImage
                        self?.shapImage = result.explanationImage // Set shapImage here
                    }
                }
            }
        }
    }
    
    private func performSHAPAnalysis(image: UIImage, model: VNCoreMLModel, completion: @escaping (SHAPResult) -> Void) {
        print("🔍 Starting SHAP analysis...")
        
        // Resize image for processing
        let resizedImage = resizeImageForProcessing(image: image, targetSize: 224)
        
        // Get baseline prediction (expected value)
        guard let baselinePrediction = getBaselinePrediction(using: model) else {
            let result = SHAPResult(
                explanationImage: nil,
                analysisText: "Error: Could not establish baseline",
                confidence: 0.0,
                shapValues: [],
                importantRegions: []
            )
            completion(result)
            return
        }
        
        // Get original prediction
        guard let originalPrediction = getPrediction(for: resizedImage, using: model) else {
            let result = SHAPResult(
                explanationImage: nil,
                analysisText: "Error: Could not get original prediction",
                confidence: 0.0,
                shapValues: [],
                importantRegions: []
            )
            completion(result)
            return
        }
        
        print("📊 Baseline: \(String(format: "%.3f", baselinePrediction)), Original: \(String(format: "%.3f", originalPrediction))")
        
        // Create segments for SHAP analysis
        let segments = createSHAPSegments(image: resizedImage)
        print("📏 Created \(segments.count) segments for SHAP analysis")
        
        // Calculate SHAP values using coalition-based approach
        let shapValues = calculateSHAPValues(
            image: resizedImage,
            segments: segments,
            model: model,
            baseline: baselinePrediction,
            originalPrediction: originalPrediction
        )
        
        // Create SHAP visualization
        let explanationImage = createSHAPVisualization(
            originalImage: image,
            segments: segments,
            shapValues: shapValues,
            originalSize: resizedImage.size
        )
        
        let importantRegions = findImportantSHAPRegions(segments: segments, shapValues: shapValues)
        
        let analysisText = generateSHAPAnalysisText(
            originalPrediction: originalPrediction,
            baselinePrediction: baselinePrediction,
            shapValues: shapValues,
            importantRegions: importantRegions
        )
        
        let result = SHAPResult(
            explanationImage: explanationImage,
            analysisText: analysisText,
            confidence: originalPrediction,
            shapValues: shapValues,
            importantRegions: importantRegions
        )
        
        print("✅ SHAP analysis complete")
        completion(result)
    }
    
    private func getBaselinePrediction(using model: VNCoreMLModel) -> Double? {
        // Create a neutral baseline image (gray)
        let baselineSize = CGSize(width: 224, height: 224)
        UIGraphicsBeginImageContextWithOptions(baselineSize, false, 1.0)
        UIColor(white: 0.5, alpha: 1.0).setFill()
        UIRectFill(CGRect(origin: .zero, size: baselineSize))
        let baselineImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let baseline = baselineImage else { return nil }
        return getPrediction(for: baseline, using: model)
    }
    
    private func createSHAPSegments(image: UIImage) -> [CGRect] {
        let imageSize = image.size
        var segments: [CGRect] = []
        
        // Use optimal segment size for SHAP (slightly larger than LIME for efficiency)
        let segmentSize = 20
        let cols = max(1, Int(imageSize.width) / segmentSize)
        let rows = max(1, Int(imageSize.height) / segmentSize)
        
        // Limit segments for memory efficiency while maintaining detail
        let maxSegments = 80
        let totalSegments = cols * rows
        
        if totalSegments <= maxSegments {
            for row in 0..<rows {
                for col in 0..<cols {
                    let x = CGFloat(col * segmentSize)
                    let y = CGFloat(row * segmentSize)
                    let rect = CGRect(x: x, y: y, width: CGFloat(segmentSize), height: CGFloat(segmentSize))
                    segments.append(rect)
                }
            }
        } else {
            // Strategic sampling for large images
            let stepCol = max(1, cols / 9) // 9x9 grid maximum
            let stepRow = max(1, rows / 9)
            
            for row in stride(from: 0, to: rows, by: stepRow) {
                for col in stride(from: 0, to: cols, by: stepCol) {
                    let x = CGFloat(col * segmentSize)
                    let y = CGFloat(row * segmentSize)
                    let rect = CGRect(x: x, y: y, width: CGFloat(segmentSize), height: CGFloat(segmentSize))
                    segments.append(rect)
                    
                    if segments.count >= maxSegments { break }
                }
                if segments.count >= maxSegments { break }
            }
        }
        
        return segments
    }
    
    private func calculateSHAPValues(image: UIImage, segments: [CGRect], model: VNCoreMLModel, baseline: Double, originalPrediction: Double) -> [Double] {
        var shapValues: [Double] = Array(repeating: 0.0, count: segments.count)
        let numSamples = min(50, segments.count * 2) // Limit samples for performance
        
        print("🧮 Calculating SHAP values with \(numSamples) coalition samples...")
        
        // Sample different coalitions of features (SHAP's core concept)
        for sampleIndex in 0..<numSamples {
            autoreleasepool {
                // Create random coalition (subset of segments)
                let coalitionSize = Int.random(in: 1...segments.count)
                let coalition = Array(segments.indices.shuffled().prefix(coalitionSize))
                
                // Create image with only coalition segments present
                let coalitionImage = createCoalitionImage(image: image, segments: segments, coalition: Set(coalition))
                
                if let coalitionPrediction = getPrediction(for: coalitionImage, using: model) {
                    let contributionPerSegment = (coalitionPrediction - baseline) / Double(coalition.count)
                    
                    // Distribute contribution among coalition members
                    for segmentIndex in coalition {
                        shapValues[segmentIndex] += contributionPerSegment / Double(numSamples)
                    }
                }
                
                if sampleIndex % 10 == 0 {
                    print("Processed \(sampleIndex + 1)/\(numSamples) coalitions")
                }
            }
        }
        
        // Normalize SHAP values so they sum to the difference from baseline
        let currentSum = shapValues.reduce(0, +)
        let targetSum = originalPrediction - baseline
        let normalizationFactor = targetSum / currentSum
        
        if !normalizationFactor.isNaN && !normalizationFactor.isInfinite {
            shapValues = shapValues.map { $0 * normalizationFactor }
        }
        
        return shapValues
    }
    
    private func createCoalitionImage(image: UIImage, segments: [CGRect], coalition: Set<Int>) -> UIImage {
        let size = image.size
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        
        // Start with baseline (gray background)
        UIColor(white: 0.5, alpha: 1.0).setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // Add original image content only for segments in the coalition
        for (index, segment) in segments.enumerated() {
            if coalition.contains(index) {
                // Crop and draw this segment from original image
                if let croppedSegment = cropImageSegment(image: image, rect: segment) {
                    croppedSegment.draw(in: segment)
                }
            }
        }
        
        let coalitionImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return coalitionImage ?? image
    }
    
    private func cropImageSegment(image: UIImage, rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let cropRect = CGRect(
            x: rect.origin.x * image.scale,
            y: rect.origin.y * image.scale,
            width: rect.size.width * image.scale,
            height: rect.size.height * image.scale
        )
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    private func createSHAPVisualization(originalImage: UIImage, segments: [CGRect], shapValues: [Double], originalSize: CGSize) -> UIImage? {
        let targetSize = originalImage.size
        let scaleX = targetSize.width / originalSize.width
        let scaleY = targetSize.height / originalSize.height
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        
        // Draw original image
        originalImage.draw(at: .zero)
        
        // Create SHAP heatmap
        let maxAbsShap = shapValues.map { abs($0) }.max() ?? 1.0
        
        // Sort by absolute SHAP value for better layering
        let sortedIndices = shapValues.indices.sorted { abs(shapValues[$0]) < abs(shapValues[$1]) }
        
        for index in sortedIndices {
            let shapValue = shapValues[index]
            let normalizedShap = shapValue / maxAbsShap
            
            if abs(normalizedShap) > 0.1 { // Only show significant SHAP values
                let segment = segments[index]
                let alpha = CGFloat(abs(normalizedShap) * 0.7)
                
                // SHAP uses red for positive contributions, blue for negative
                let color: UIColor
                if shapValue > 0 {
                    // Positive SHAP value (increases prediction) - Red spectrum
                    let intensity = CGFloat(abs(normalizedShap))
                    color = UIColor(red: 1.0, green: 1.0 - intensity * 0.8, blue: 1.0 - intensity, alpha: alpha)
                } else {
                    // Negative SHAP value (decreases prediction) - Blue spectrum  
                    let intensity = CGFloat(abs(normalizedShap))
                    color = UIColor(red: 1.0 - intensity, green: 1.0 - intensity * 0.8, blue: 1.0, alpha: alpha)
                }
                
                color.setFill()
                
                // Scale segment to match original image size
                let scaledSegment = CGRect(
                    x: segment.origin.x * scaleX,
                    y: segment.origin.y * scaleY,
                    width: segment.size.width * scaleX,
                    height: segment.size.height * scaleY
                )
                
                // Draw with smooth corners
                let path = UIBezierPath(roundedRect: scaledSegment, cornerRadius: 3)
                path.fill()
            }
        }
        
        // Add borders for highest absolute SHAP values
        for index in sortedIndices.suffix(5) { // Top 5 most important
            let shapValue = shapValues[index]
            let normalizedShap = shapValue / maxAbsShap
            
            if abs(normalizedShap) > 0.6 {
                let segment = segments[index]
                
                UIColor.white.setStroke()
                let scaledSegment = CGRect(
                    x: segment.origin.x * scaleX,
                    y: segment.origin.y * scaleY,
                    width: segment.size.width * scaleX,
                    height: segment.size.height * scaleY
                )
                
                let path = UIBezierPath(roundedRect: scaledSegment, cornerRadius: 3)
                path.lineWidth = 2.0
                path.stroke()
            }
        }
        
        let explanationImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return explanationImage
    }
    
    // ...existing utility methods...
    private func resizeImageForProcessing(image: UIImage, targetSize: CGFloat = 224) -> UIImage {
        let size = image.size
        
        if size.width <= targetSize && size.height <= targetSize {
            return image
        }
        
        let ratio = min(targetSize / size.width, targetSize / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    private func getPrediction(for image: UIImage, using model: VNCoreMLModel) -> Double? {
        autoreleasepool {
            guard let ciImage = CIImage(image: image) else { return nil }
            
            let semaphore = DispatchSemaphore(value: 0)
            var result: Double?
            
            let request = VNCoreMLRequest(model: model) { request, error in
                defer { semaphore.signal() }
                
                guard error == nil,
                      let results = request.results as? [VNCoreMLFeatureValueObservation],
                      let firstResult = results.first,
                      let multiArray = firstResult.featureValue.multiArrayValue,
                      multiArray.count > 0 else {
                    return
                }
                
                result = Double(truncating: multiArray[0])
            }
            
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
            try? handler.perform([request])
            
            semaphore.wait()
            return result
        }
    }
    
    private func findImportantSHAPRegions(segments: [CGRect], shapValues: [Double]) -> [(region: CGRect, shapValue: Double)] {
        let threshold = (shapValues.map { abs($0) }.max() ?? 0.0) * 0.3
        
        var importantRegions: [(region: CGRect, shapValue: Double)] = []
        
        for (index, shapValue) in shapValues.enumerated() {
            if abs(shapValue) >= threshold {
                importantRegions.append((region: segments[index], shapValue: shapValue))
            }
        }
        
        // Sort by absolute SHAP value
        return importantRegions.sorted { abs($0.shapValue) > abs($1.shapValue) }
    }
    
    private func generateSHAPAnalysisText(originalPrediction: Double, baselinePrediction: Double, shapValues: [Double], importantRegions: [(region: CGRect, shapValue: Double)]) -> String {
        let percentage = originalPrediction * 100
        let prediction = originalPrediction > 0.5 ? "Diabetic Retinopathy" : "Normal"
        
        let positiveContributions = shapValues.filter { $0 > 0 }.reduce(0, +)
        let negativeContributions = shapValues.filter { $0 < 0 }.reduce(0, +)
        let totalContribution = positiveContributions + negativeContributions
        
        var text = "SHAP Analysis Results:\n"
        text += "Prediction: \(prediction) (\(String(format: "%.1f", percentage))%)\n\n"
        text += "SHAP Explanation:\n"
        text += "• Baseline probability: \(String(format: "%.1f", baselinePrediction * 100))%\n"
        text += "• Total contribution: \(String(format: "%.3f", totalContribution))\n"
        text += "• Positive contributions: \(String(format: "%.3f", positiveContributions))\n"
        text += "• Negative contributions: \(String(format: "%.3f", negativeContributions))\n"
        text += "• Important regions: \(importantRegions.count)\n\n"
        text += "Red areas increase DR probability, blue areas decrease it."
        
        return text
    }
}
