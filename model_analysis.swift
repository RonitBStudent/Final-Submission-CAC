wimport CoreML

// Quick model analysis script
print("🔍 ANALYZING MODELS FOR GRADCAM COMPATIBILITY")
print("=" + String(repeating: "=", count: 50))

// Test FundusModel
do {
    print("\n📊 FUNDUS MODEL:")
    let fundusModel = try FundusModel(configuration: MLModelConfiguration()).model
    
    print("   📥 Inputs:")
    for (name, desc) in fundusModel.modelDescription.inputDescriptionsByName {
        if let imageConstraint = desc.imageConstraint {
            print("     • \(name): Image (\(imageConstraint.pixelsWide)x\(imageConstraint.pixelsHigh))")
        }
    }
    
    print("   📤 Outputs:")
    var hasFeatureMaps = false
    for (name, desc) in fundusModel.modelDescription.outputDescriptionsByName {
        if let constraint = desc.multiArrayConstraint {
            let shape = constraint.shape.map { $0.intValue }
            print("     • \(name): \(shape)")
            
            // Check for 4D tensors with spatial dimensions (height > 1, width > 1)
            if shape.count == 4 && shape[2] > 1 && shape[3] > 1 {
                hasFeatureMaps = true
                print("       🎯 FEATURE MAP! (Good for GradCAM)")
            }
        }
    }
    
    print("   🔥 GRADCAM SUPPORT: \(hasFeatureMaps ? "✅ TRUE GRADCAM" : "❌ OCCLUSION ONLY")")
    
} catch {
    print("   ❌ Failed to load FundusModel: \(error)")
}

// Test RetinopathyProbability
do {
    print("\n📊 RETINOPATHY MODEL:")
    let retinopathyModel = try RetinopathyProbability(configuration: MLModelConfiguration()).model
    
    print("   📥 Inputs:")
    for (name, desc) in retinopathyModel.modelDescription.inputDescriptionsByName {
        if let imageConstraint = desc.imageConstraint {
            print("     • \(name): Image (\(imageConstraint.pixelsWide)x\(imageConstraint.pixelsHigh))")
        }
    }
    
    print("   📤 Outputs:")
    var hasFeatureMaps = false
    for (name, desc) in retinopathyModel.modelDescription.outputDescriptionsByName {
        if let constraint = desc.multiArrayConstraint {
            let shape = constraint.shape.map { $0.intValue }
            print("     • \(name): \(shape)")
            
            // Check for 4D tensors with spatial dimensions
            if shape.count == 4 && shape[2] > 1 && shape[3] > 1 {
                hasFeatureMaps = true
                print("       🎯 FEATURE MAP! (Good for GradCAM)")
            }
        }
    }
    
    print("   🔥 GRADCAM SUPPORT: \(hasFeatureMaps ? "✅ TRUE GRADCAM" : "❌ OCCLUSION ONLY")")
    
} catch {
    print("   ❌ Failed to load RetinopathyProbability: \(error)")
}

print("\n" + String(repeating: "=", count: 50))
