#!/bin/bash

# iOS Python Bundle Setup Script
# This script helps bundle Python with your iOS app for on-device execution

echo "🐍 Setting up Python bundle for iOS app..."

# Create directories for Python bundle
BUNDLE_DIR="./python_bundle"
SITE_PACKAGES="$BUNDLE_DIR/lib/python3.11/site-packages"

mkdir -p "$BUNDLE_DIR/bin"
mkdir -p "$SITE_PACKAGES"

echo "📦 Installing Python packages to bundle..."

# Install required packages to bundle directory
pip3 install --target "$SITE_PACKAGES" torch==2.0.1 --index-url https://download.pytorch.org/whl/cpu
pip3 install --target "$SITE_PACKAGES" torchvision==0.15.2 --index-url https://download.pytorch.org/whl/cpu
pip3 install --target "$SITE_PACKAGES" numpy==1.24.3
pip3 install --target "$SITE_PACKAGES" opencv-python-headless==4.8.0.74
pip3 install --target "$SITE_PACKAGES" Pillow==10.0.0
pip3 install --target "$SITE_PACKAGES" albumentations==1.3.1

echo "📁 Copying necessary files..."

# Copy your Python script
cp gradcam_processor.py "$BUNDLE_DIR/"

# Copy your model file
cp "Congressional App Challenge (DR)/HuggingFace/best_model_auc_0.9937.pth" "$BUNDLE_DIR/"

echo "📝 Creating bundle info file..."

# Create a bundle info file
cat > "$BUNDLE_DIR/bundle_info.json" << EOF
{
    "version": "1.0",
    "python_version": "3.11",
    "created": "$(date)",
    "packages": [
        "torch",
        "torchvision", 
        "numpy",
        "opencv-python-headless",
        "Pillow",
        "albumentations"
    ],
    "scripts": [
        "gradcam_processor.py"
    ],
    "models": [
        "best_model_auc_0.9937.pth"
    ]
}
EOF

echo "✅ Python bundle created at: $BUNDLE_DIR"
echo ""
echo "📋 Next steps:"
echo "1. Add the python_bundle folder to your Xcode project"
echo "2. Make sure it's included in the app bundle (Copy Bundle Resources)"
echo "3. Update your GradCAMPredictor to use PythonGradCAMBridge"
echo ""
echo "🎯 Your app will now run TRUE GradCAM analysis on-device!"
