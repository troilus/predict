#!/bin/bash

# ORBIT iOS App Build Script
# This script builds the iOS app for different targets

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project configuration
PROJECT="ORBIT.xcodeproj"
SCHEME="ORBIT"
CONFIGURATION_DEBUG="Debug"
CONFIGURATION_RELEASE="Release"
SDK_SIMULATOR="iphonesimulator"
SDK_IOS="iphoneos"
DESTINATION_SIMULATOR="platform=iOS Simulator,name=iPhone 15,OS=latest"

# Build directories
BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/ORBIT.xcarchive"
IPA_EXPORT_PATH="$BUILD_DIR/IPA"

# Functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if Xcode is installed
check_xcode() {
    print_info "Checking Xcode installation..."

    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode is not installed"
        exit 1
    fi

    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    print_success "Xcode found: $XCODE_VERSION"
}

# Clean build directory
clean_build() {
    print_info "Cleaning build directory..."

    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"

    print_success "Build directory cleaned"
}

# Build for simulator
build_simulator() {
    print_info "Building for iOS Simulator..."

    xcodebuild clean build \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION_DEBUG" \
        -sdk "$SDK_SIMULATOR" \
        -destination "$DESTINATION_SIMULATOR" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        | xcpretty || exit ${PIPESTATUS[0]}

    print_success "Simulator build completed"
}

# Archive for iOS
archive_app() {
    print_info "Archiving app for iOS (unsigned)..."

    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION_RELEASE" \
        -archivePath "$ARCHIVE_PATH" \
        -sdk "$SDK_IOS" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        DEVELOPMENT_TEAM="" \
        | xcpretty || exit ${PIPESTATUS[0]}

    print_success "Archive created at: $ARCHIVE_PATH"
}

# Export IPA
export_ipa() {
    print_info "Exporting IPA..."

    if [ ! -f "exportOptions.plist" ]; then
        print_error "exportOptions.plist not found"
        print_info "Please create exportOptions.plist with your code signing configuration"
        exit 1
    fi

    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$IPA_EXPORT_PATH" \
        -exportOptionsPlist exportOptions.plist \
        | xcpretty || exit ${PIPESTATUS[0]}

    IPA_PATH=$(find "$IPA_EXPORT_PATH" -name "*.ipa" | head -n 1)
    print_success "IPA exported to: $IPA_PATH"
}

# Run tests
run_tests() {
    print_info "Running tests..."

    xcodebuild test \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION_SIMULATOR" \
        | xcpretty || exit ${PIPESTATUS[0]}

    print_success "Tests completed"
}

# Show help
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  simulator    Build for iOS Simulator"
    echo "  archive      Archive app for iOS"
    echo "  ipa          Archive and export IPA"
    echo "  test         Run tests"
    echo "  clean        Clean build directory"
    echo "  all          Build simulator, archive, and export IPA"
    echo "  help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 simulator"
    echo "  $0 ipa"
    echo "  $0 all"
}

# Main script
main() {
    COMMAND=${1:-help}

    case $COMMAND in
        simulator)
            check_xcode
            build_simulator
            ;;
        archive)
            check_xcode
            clean_build
            archive_app
            ;;
        ipa)
            check_xcode
            clean_build
            archive_app
            export_ipa
            ;;
        test)
            check_xcode
            run_tests
            ;;
        clean)
            clean_build
            ;;
        all)
            check_xcode
            clean_build
            build_simulator
            archive_app
            export_ipa
            ;;
        help)
            show_help
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"