#!/bin/bash

# TrueTalk TestFlight Build Script
echo "🚀 Starting TrueTalk TestFlight build process..."

# Check if we're in the right directory
if [ ! -f "TrueTalk.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Please run this script from the TrueTalk project root directory"
    exit 1
fi

# Check if Xcode command line tools are available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode command line tools not found. Please install Xcode."
    exit 1
fi

echo "📱 Building for TestFlight..."

# Clean the build
echo "🧹 Cleaning previous builds..."
xcodebuild clean -project TrueTalk.xcodeproj -scheme TrueTalk

# Build for archive
echo "🏗️ Building archive..."
xcodebuild archive \
    -project TrueTalk.xcodeproj \
    -scheme TrueTalk \
    -configuration Release \
    -archivePath build/TrueTalk.xcarchive \
    -destination generic/platform=iOS

if [ $? -eq 0 ]; then
    echo "✅ Archive created successfully!"
    echo "📦 Archive location: build/TrueTalk.xcarchive"
    echo ""
    echo "📋 Next steps:"
    echo "1. Open Xcode"
    echo "2. Go to Window → Organizer"
    echo "3. Select your archive"
    echo "4. Click 'Distribute App'"
    echo "5. Choose 'App Store Connect'"
    echo "6. Follow the upload process"
    echo ""
    echo "🔗 Or use the following command to upload directly:"
    echo "xcodebuild -exportArchive -archivePath build/TrueTalk.xcarchive -exportPath build/export -exportOptionsPlist exportOptions.plist"
else
    echo "❌ Build failed! Please check the error messages above."
    exit 1
fi 