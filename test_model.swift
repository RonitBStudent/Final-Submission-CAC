#!/usr/bin/env swift

import Foundation
import CoreML

// Simple CoreML model tester for command line
class ModelTester {
    static func runGradCAMCompatibilityTest() {
        print("\n🚀 STARTING GRADCAM COMPATIBILITY TEST")
        print("=" + String(repeating: "=", count: 50))
        compileAndTestFundusModel()
        print("=" + String(repeating: "=", count: 50))
        print("🏁 GRADCAM COMPATIBILITY TEST COMPLETE\n")
    }
    
    static func compileAndTestFundusModel() {
        print("\n🔧 COMPILING AND TESTING FUNDUS MODEL")
        print("=" + String(repeating: "=", count: 49))
        
        let modelPath = "./Congressional App Challenge (DR)/FundusModel.mlpackage"
        let sourceURL = URL(fileURLWithPath: modelPath)
        
        // First, compile the model
        print("📦 Compiling FundusModel...")
        
        do {
            let compiledURL = try MLModel.compileModel(at: sourceURL)
            print("✅ Model compiled successfully at: \(compiledURL.path)")
            
            // Now load the compiled model
            let mlModel = try MLModel(contentsOf: compiledURL)
            print("✅ Compiled FundusModel loaded successfully")
            
            // Analyze model structure
            analyzeModelStructure(model: mlModel, modelName: "FundusModel")
            
        } catch {
            print("❌ Failed to compile or load FundusModel: \(error)")
        }
    }
    
    static func analyzeModelStructure(model: MLModel, modelName: String) {
        print("\n📊 ANALYZING \(modelName.uppercased())")
        print("-" + String(repeating: "-", count: 30))
        
        // Check inputs
        print("\n📥 INPUTS:")
        for (inputName, inputDescription) in model.modelDescription.inputDescriptionsByName {
            print("   • \(inputName)")
            if let imageConstraint = inputDescription.imageConstraint {
                print("     Type: Image (\(imageConstraint.pixelsWide)x\(imageConstraint.pixelsHigh))")
            } else if let multiArrayConstraint = inputDescription.multiArrayConstraint {
                print("     Type: MultiArray, Shape: \(multiArrayConstraint.shape)")
            } else {
                print("     Type: \(inputDescription.type)")
            }
        }
        
        // Check outputs
        print("\n📤 OUTPUTS:")
        let outputNames = Array(model.modelDescription.outputDescriptionsByName.keys)
        for (outputName, outputDescription) in model.modelDescription.outputDescriptionsByName {
            print("   • \(outputName)")
            if let multiArrayConstraint = outputDescription.multiArrayConstraint {
                print("     Type: MultiArray, Shape: \(multiArrayConstraint.shape)")
            } else if outputDescription.dictionaryConstraint != nil {
                print("     Type: Dictionary")
            } else {
                print("     Type: \(outputDescription.type)")
            }
        }
        
        // GradCAM compatibility analysis
        print("\n🔥 GRADCAM COMPATIBILITY:")
        print("   📊 Total outputs: \(outputNames.count)")
        
        if outputNames.count >= 2 {
            print("   ✅ MULTIPLE OUTPUTS DETECTED!")
            
            // Look for feature-like outputs
            let featureOutputs = outputNames.filter { name in
                let lowercased = name.lowercased()
                return lowercased.contains("feature") ||
                       lowercased.contains("activation") ||
                       lowercased.contains("conv") ||
                       lowercased.contains("layer")
            }
            
            // Look for prediction-like outputs
            let predictionOutputs = outputNames.filter { name in
                let lowercased = name.lowercased()
                return lowercased.contains("logit") ||
                       lowercased.contains("probability") ||
                       lowercased.contains("prediction") ||
                       lowercased.contains("output")
            }
            
            print("   📋 All output names: \(outputNames)")
            
            if !featureOutputs.isEmpty && !predictionOutputs.isEmpty {
                print("   🎉 REAL GRADCAM SUPPORTED!")
                print("   🎯 Feature outputs: \(featureOutputs)")
                print("   🎯 Prediction outputs: \(predictionOutputs)")
                
            } else if featureOutputs.isEmpty && predictionOutputs.isEmpty {
                print("   🤔 Multiple outputs but unclear naming")
                print("   💡 Manual testing needed")
                
            } else {
                print("   ⚠️ PARTIAL GRADCAM SUPPORT")
                print("   🎯 Feature outputs: \(featureOutputs.isEmpty ? "None found" : "\(featureOutputs)")")
                print("   🎯 Prediction outputs: \(predictionOutputs.isEmpty ? "None found" : "\(predictionOutputs)")")
            }
            
        } else {
            print("   ❌ SINGLE OUTPUT ONLY")
            print("   💡 Only supports occlusion-based approximation")
            print("   💡 Need to retrain with dual outputs for real GradCAM")
        }
        
        // Additional detailed analysis
        print("\n🔍 DETAILED OUTPUT ANALYSIS:")
        for (outputName, outputDescription) in model.modelDescription.outputDescriptionsByName {
            if let multiArrayConstraint = outputDescription.multiArrayConstraint {
                let shape = multiArrayConstraint.shape.map { $0.intValue }
                print("   📊 \(outputName):")
                print("     Shape: \(shape)")
                print("     Dimensions: \(shape.count)D")
                
                if shape.count == 4 {
                    print("     Format: [Batch, Channels, Height, Width] = [\(shape[0]), \(shape[1]), \(shape[2]), \(shape[3])]")
                    if shape[2] == 7 && shape[3] == 7 {
                        print("     🔥 PERFECT for EfficientNet GradCAM (7x7 spatial)")
                    }
                } else if shape.count == 1 {
                    print("     Format: [Classes] = [\(shape[0])]")
                }
            }
        }
    }
}

// Run the test
ModelTester.runGradCAMCompatibilityTest()
