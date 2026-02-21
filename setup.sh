#!/bin/bash
# TaalAvontuur - Setup Script
# This script generates the Xcode project using XcodeGen

set -e

echo "🦄 TaalAvontuur - Setup"
echo "========================"
echo ""

# Check for XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo "XcodeGen is not installed. Installing via Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew is not installed."
        echo "   Install it from https://brew.sh and then run:"
        echo "   brew install xcodegen"
        exit 1
    fi
    brew install xcodegen
fi

echo "✅ XcodeGen found"
echo ""
echo "Generating Xcode project..."
xcodegen generate

echo ""
echo "✅ Xcode project generated!"
echo ""
echo "Next steps:"
echo "  1. Open TaalAvontuur.xcodeproj in Xcode"
echo "  2. Select your Development Team in Signing & Capabilities"
echo "  3. Connect your iPhone and select it as the run target"
echo "  4. Press ⌘R to build and run"
echo ""
echo "🦄 Veel plezier met TaalAvontuur!"
