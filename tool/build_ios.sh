#!/usr/bin/env bash
# Builds a signed App Store .ipa of Teacher on a Mac. Nothing is uploaded.
#
#   tool/build_ios.sh                 analyze, test, archive, export, verify
#   tool/build_ios.sh --skip-checks   skip analyze and tests
#   tool/build_ios.sh --no-firebase   allow a build without
#                                     ios/Runner/GoogleService-Info.plist
#
# Signing: Xcode's automatic signing for the DEVELOPMENT_TEAM in the Xcode
# project (Apple team CW68Z23WQ4, the Arrowlock team). Xcode creates the
# certificate and profile itself (-allowProvisioningUpdates); the script reads
# no certificate, profile or password. Sign in to that Apple ID in
# Xcode > Settings > Accounts first. Full guide: docs/release-ios.md.
set -euo pipefail
cd "$(dirname "$0")/.."

skip_checks=0
allow_no_firebase=0
for arg in "$@"; do
	case "$arg" in
		--skip-checks) skip_checks=1 ;;
		--no-firebase) allow_no_firebase=1 ;;
		*) echo "unknown option: $arg" >&2; exit 2 ;;
	esac
done

fail() { echo "error: $*" >&2; exit 1; }

[ "$(uname)" = "Darwin" ] || fail "iOS builds need macOS with Xcode"
command -v xcodebuild >/dev/null || fail "xcodebuild not found (install Xcode, then: sudo xcode-select -s /Applications/Xcode.app)"
command -v flutter >/dev/null || fail "flutter not found on PATH"

BUNDLE_ID=dev.imrn.teacher
version_line=$(grep -E '^version:' pubspec.yaml | awk '{print $2}')
build_name=${version_line%%+*}
build_number=${version_line##*+}
team=$(grep -m1 -E 'DEVELOPMENT_TEAM = ' ios/Runner.xcodeproj/project.pbxproj | sed -E 's/.*= ([A-Z0-9]+);/\1/')
[[ "$team" =~ ^[A-Z0-9]{10}$ ]] || fail "no DEVELOPMENT_TEAM in ios/Runner.xcodeproj"

if [ ! -f ios/Runner/GoogleService-Info.plist ]; then
	[ $allow_no_firebase -eq 1 ] || fail "ios/Runner/GoogleService-Info.plist is missing (docs/release-ios.md §2), or pass --no-firebase"
	echo "warning: building without GoogleService-Info.plist: no Crashlytics in this build"
fi

out=build/ios-release
archive=$out/Teacher.xcarchive
ipa=build/teacher-$build_name-b$build_number.ipa
mkdir -p "$out/logs"

echo "Teacher $build_name ($build_number), team $team"
xcodebuild -version | head -1

if [ $skip_checks -eq 0 ]; then
	echo "Analyzing and testing ..."
	flutter pub get >/dev/null
	flutter analyze --no-fatal-infos
	flutter test
fi

echo "Preparing the Xcode project (release config) ..."
flutter build ios --release --config-only

echo "Archiving (a few minutes) ..."
rm -rf "$archive"
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release \
	-destination "generic/platform=iOS" -archivePath "$archive" \
	-derivedDataPath "$out/DerivedData" \
	DEVELOPMENT_TEAM="$team" CODE_SIGN_STYLE=Automatic \
	-allowProvisioningUpdates archive > "$out/logs/archive.log" 2>&1 \
	|| { grep -E "error:" "$out/logs/archive.log" | sort -u | head -20 >&2; fail "archive failed (log: $out/logs/archive.log)"; }

echo "Exporting the .ipa ..."
options=$out/logs/export-options.plist
cat > "$options" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>app-store-connect</string>
	<key>destination</key>
	<string>export</string>
	<key>teamID</key>
	<string>$team</string>
	<key>signingStyle</key>
	<string>automatic</string>
	<key>uploadSymbols</key>
	<true/>
</dict>
</plist>
PLIST
rm -rf "$out/ipa"
xcodebuild -exportArchive -archivePath "$archive" -exportOptionsPlist "$options" \
	-exportPath "$out/ipa" -allowProvisioningUpdates > "$out/logs/export.log" 2>&1 \
	|| { grep -E "error:" "$out/logs/export.log" | sort -u | head -20 >&2; fail ".ipa export failed (log: $out/logs/export.log)"; }
shopt -s nullglob; made=("$out"/ipa/*.ipa); shopt -u nullglob
[ ${#made[@]} -eq 1 ] || fail "expected one .ipa in $out/ipa, found ${#made[@]}"
mv -f "${made[0]}" "$ipa"

echo "Verifying the archived app ..."
app="$archive/Products/Applications/Runner.app"
plist="$app/Info.plist"
pb() { /usr/libexec/PlistBuddy -c "Print :$1" "$plist" 2>/dev/null || true; }
[ "$(pb CFBundleIdentifier)" = "$BUNDLE_ID" ] || fail "bundle id is $(pb CFBundleIdentifier), expected $BUNDLE_ID"
[ "$(pb CFBundleShortVersionString)" = "$build_name" ] || fail "version is $(pb CFBundleShortVersionString), expected $build_name"
[ "$(pb CFBundleVersion)" = "$build_number" ] || fail "build is $(pb CFBundleVersion), expected $build_number"
[ "$(pb CFBundleDisplayName)" = "Teacher" ] || fail "display name is $(pb CFBundleDisplayName)"
[ "$(pb ITSAppUsesNonExemptEncryption)" = "false" ] || fail "ITSAppUsesNonExemptEncryption must be false"
[ -f "$app/PrivacyInfo.xcprivacy" ] || fail "PrivacyInfo.xcprivacy missing from the app"
if [ -f ios/Runner/GoogleService-Info.plist ]; then
	[ -f "$app/GoogleService-Info.plist" ] || fail "GoogleService-Info.plist was not copied into the app"
	gsp_bundle=$(/usr/libexec/PlistBuddy -c "Print :BUNDLE_ID" "$app/GoogleService-Info.plist")
	[ "$gsp_bundle" = "$BUNDLE_ID" ] || fail "GoogleService-Info.plist is for $gsp_bundle, not $BUNDLE_ID"
fi
signed_team=$(codesign -dv "$app" 2>&1 | sed -n 's/^TeamIdentifier=//p')
[ "$signed_team" = "$team" ] || fail "app signed by team '$signed_team', expected $team"

# Crashlytics symbols (best effort; Crashlytics still works without them,
# stack traces of native frames are just not symbolicated).
if [ -f ios/Runner/GoogleService-Info.plist ]; then
	up=$(find "$out/DerivedData/SourcePackages" -path '*firebase-ios-sdk/Crashlytics/upload-symbols' -type f 2>/dev/null | head -1)
	if [ -n "$up" ]; then
		echo "Uploading dSYMs to Crashlytics ..."
		"$up" -gsp ios/Runner/GoogleService-Info.plist -p ios "$archive/dSYMs" > "$out/logs/crashlytics-symbols.log" 2>&1 \
			|| echo "warning: dSYM upload failed (log: $out/logs/crashlytics-symbols.log)"
	else
		echo "warning: Crashlytics upload-symbols not found; dSYMs not uploaded"
	fi
fi

echo
echo "OK  $ipa"
echo "    $(du -h "$ipa" | cut -f1), sha256 $(shasum -a 256 "$ipa" | cut -d' ' -f1)"
echo "Upload it with Transporter or Xcode > Organizer (docs/release-ios.md §5)."
