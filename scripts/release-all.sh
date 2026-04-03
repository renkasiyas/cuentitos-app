#!/bin/bash
# ABOUTME: Unified release script with Shorebird Code Push support
# ABOUTME: Builds iOS/Android, uploads to App Store Connect/Play Store, and supports OTA patching

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

# Defaults
MODE="release"
DRY_RUN=false
SKIP_IOS=false
SKIP_ANDROID=false
AUTO_INCREMENT=false
NO_SHOREBIRD=false

# Deployment failure tracking
IOS_DEPLOY_FAILED=false
ANDROID_DEPLOY_FAILED=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-ios)
            SKIP_IOS=true
            shift
            ;;
        --skip-android)
            SKIP_ANDROID=true
            shift
            ;;
        --auto-increment)
            AUTO_INCREMENT=true
            shift
            ;;
        --no-shorebird)
            NO_SHOREBIRD=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [patch] [options]"
            echo ""
            echo "Modes:"
            echo "  (default)          Build + upload to App Store Connect & Play Store"
            echo "  patch              OTA patch via Shorebird (no store upload)"
            echo ""
            echo "Options:"
            echo "  --no-shorebird     Use flutter build instead of shorebird release"
            echo "  --dry-run          Simulate the release without actually building/deploying"
            echo "  --skip-ios         Skip iOS build and deployment"
            echo "  --skip-android     Skip Android build and deployment"
            echo "  --auto-increment   Auto-increment build number after release"
            echo "  -h, --help         Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                           # Build + upload (Shorebird)"
            echo "  $0 patch                     # OTA patch (Shorebird required)"
            echo "  $0 --no-shorebird            # Build + upload (flutter build)"
            echo "  $0 --skip-android            # iOS only"
            echo "  $0 --dry-run                 # Preview without building"
            exit 0
            ;;
        patch)
            MODE="patch"
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Run '$0 --help' for usage information."
            exit 1
            ;;
    esac
done

# Function to print section headers
print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to run command (respects dry run)
run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] Would execute: $*${NC}"
    else
        echo -e "${GREEN}Executing: $*${NC}"
        eval "$@"
    fi
}

# Validate patch + no-shorebird conflict
if [ "$MODE" = "patch" ] && [ "$NO_SHOREBIRD" = true ]; then
    echo -e "${RED}Error: Patch mode requires Shorebird. Cannot use --no-shorebird with patch.${NC}"
    exit 1
fi

# Resolve shorebird binary
SHOREBIRD_BIN=""
if command -v shorebird &> /dev/null; then
    SHOREBIRD_BIN="shorebird"
elif [ -x "$HOME/.shorebird/bin/shorebird" ]; then
    SHOREBIRD_BIN="$HOME/.shorebird/bin/shorebird"
fi

# Shorebird pre-flight check
USE_SHOREBIRD=false
if [ "$NO_SHOREBIRD" = false ]; then
    if [ -n "$SHOREBIRD_BIN" ]; then
        USE_SHOREBIRD=true
    else
        if [ "$MODE" = "patch" ]; then
            echo -e "${RED}Error: Shorebird CLI not found. Patch mode requires Shorebird.${NC}"
            echo -e "${RED}Install it: https://docs.shorebird.dev/getting-started${NC}"
            exit 1
        fi
        echo -e "${YELLOW}Warning: Shorebird CLI not found. Falling back to flutter build.${NC}"
    fi
fi

# Determine labels
if [ "$USE_SHOREBIRD" = true ]; then BUILD_TOOL="Shorebird"; else BUILD_TOOL="Flutter"; fi
if [ "$USE_SHOREBIRD" = true ] && [ "$MODE" != "patch" ]; then PATCHABLE="Yes"; else PATCHABLE="No"; fi

# Change to app directory
cd "$APP_DIR"

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
VERSION_PART=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

if [ -z "$VERSION_PART" ] || [ -z "$BUILD_NUMBER" ]; then
    echo -e "${RED}Error: Could not parse version from pubspec.yaml (got: '${CURRENT_VERSION}')${NC}"
    exit 1
fi

if ! [[ "$BUILD_NUMBER" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: Build number must be numeric, got: '${BUILD_NUMBER}'${NC}"
    exit 1
fi

# Confirmation prompt
if [ "$DRY_RUN" = false ] && [ "$MODE" = "release" ]; then
    echo -e "${YELLOW}You are about to build and upload to App Store Connect & Play Store.${NC}"
    read -p "Are you sure? [y/N]: " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo -e "${RED}Aborted.${NC}"
        exit 1
    fi
fi

if [ "$MODE" = "release" ]; then
    print_header "Cuentitos Release"
else
    print_header "Cuentitos Patch (OTA)"
fi

echo -e "${GREEN}Version:     ${VERSION_PART}+${BUILD_NUMBER}${NC}"
echo -e "${GREEN}Build tool:  ${BUILD_TOOL}${NC}"
echo -e "${GREEN}Patchable:   ${PATCHABLE}${NC}"
echo ""

RELEASE_DATE=$(date +"%Y-%m-%d %H:%M")
RELEASE_NOTES="Build ${VERSION_PART}+${BUILD_NUMBER} - ${RELEASE_DATE}"

# ============================================
# PATCH MODE
# ============================================

if [ "$MODE" = "patch" ]; then
    if [ "$SKIP_IOS" = false ]; then
        print_header "Patching iOS via Shorebird"
        run_cmd "$SHOREBIRD_BIN patch ios --release-version ${VERSION_PART}+${BUILD_NUMBER}"
    fi

    if [ "$SKIP_ANDROID" = false ]; then
        print_header "Patching Android via Shorebird"
        run_cmd "$SHOREBIRD_BIN patch android --release-version ${VERSION_PART}+${BUILD_NUMBER}"
    fi

    print_header "Patch Complete!"
    echo -e "${GREEN}Patches delivered OTA. No app store submission required.${NC}"

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}This was a DRY RUN. No actual patches were pushed.${NC}"
    fi
    exit 0
fi

# ============================================
# iOS BUILD AND DEPLOY
# ============================================

if [ "$SKIP_IOS" = false ]; then
    print_header "Building iOS"

    if [ "$USE_SHOREBIRD" = true ]; then
        run_cmd "$SHOREBIRD_BIN release ios -- --build-name=$VERSION_PART --build-number=$BUILD_NUMBER"
    else
        run_cmd "flutter build ipa --release --build-name=$VERSION_PART --build-number=$BUILD_NUMBER"
    fi

    if [ "$DRY_RUN" = false ]; then
        echo -e "${YELLOW}Uploading iOS to App Store Connect...${NC}"
        export CHANGELOG="$RELEASE_NOTES"
        if ! (cd "$APP_DIR/ios" && bundle exec fastlane ios release); then
            IOS_DEPLOY_FAILED=true
            echo -e "${RED}ERROR: iOS upload to App Store Connect FAILED.${NC}"
        fi
    fi
fi

# ============================================
# ANDROID BUILD AND DEPLOY
# ============================================

if [ "$SKIP_ANDROID" = false ]; then
    print_header "Building Android"

    if [ "$USE_SHOREBIRD" = true ]; then
        run_cmd "$SHOREBIRD_BIN release android --artifact aab -- --build-name=$VERSION_PART --build-number=$BUILD_NUMBER"
    else
        run_cmd "flutter build appbundle --release --build-name=$VERSION_PART --build-number=$BUILD_NUMBER"
    fi

    if [ "$DRY_RUN" = false ]; then
        KEY_PATH="$APP_DIR/android/play-store-key.json"
        if [ -z "$PLAY_STORE_JSON_KEY_PATH" ] || [ ! -f "$PLAY_STORE_JSON_KEY_PATH" ]; then
            if [ -f "$KEY_PATH" ]; then
                export PLAY_STORE_JSON_KEY_PATH="$KEY_PATH"
            fi
        fi

        echo -e "${YELLOW}Uploading Android to Play Store...${NC}"
        if ! (cd "$APP_DIR/android" && bundle exec fastlane android release); then
            ANDROID_DEPLOY_FAILED=true
            echo -e "${RED}ERROR: Android upload to Play Store FAILED.${NC}"
        fi
    fi
fi

# ============================================
# AUTO-INCREMENT BUILD NUMBER
# ============================================

if [ "$AUTO_INCREMENT" = true ] && [ "$DRY_RUN" = false ]; then
    if [ "$IOS_DEPLOY_FAILED" = true ] || [ "$ANDROID_DEPLOY_FAILED" = true ]; then
        echo -e "${YELLOW}Skipping auto-increment due to deployment failures.${NC}"
    else
        print_header "Auto-incrementing build number"
        NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
        NEW_VERSION="${VERSION_PART}+${NEW_BUILD_NUMBER}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
        else
            sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
        fi
        echo -e "${GREEN}Version bumped to $NEW_VERSION${NC}"
    fi
fi

# ============================================
# SUMMARY
# ============================================

if [ "$IOS_DEPLOY_FAILED" = true ] || [ "$ANDROID_DEPLOY_FAILED" = true ]; then
    print_header "Release INCOMPLETE - Upload Failures"
    [ "$IOS_DEPLOY_FAILED" = true ] && echo -e "${RED}  iOS:     UPLOAD FAILED${NC}"
    [ "$ANDROID_DEPLOY_FAILED" = true ] && echo -e "${RED}  Android: UPLOAD FAILED${NC}"
    exit 1
else
    print_header "Release Complete!"
    echo -e "${GREEN}Version:     ${VERSION_PART}+${BUILD_NUMBER}${NC}"
    echo -e "${GREEN}Build tool:  ${BUILD_TOOL}${NC}"
    echo -e "${GREEN}Patchable:   ${PATCHABLE}${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. App Store Connect: https://appstoreconnect.apple.com"
    echo -e "  2. Play Console:      https://play.google.com/console"
fi

if [ "$DRY_RUN" = true ]; then
    echo ""
    echo -e "${YELLOW}This was a DRY RUN. No actual builds or uploads were made.${NC}"
fi
