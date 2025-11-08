#!/bin/bash
# Script to get SHA-256 fingerprint for Android App Links
# Usage: 
#   For debug keystore: ./get_sha256.sh
#   For release keystore: ./get_sha256.sh -k path/to/keystore.jks -a your-alias -p your-password

KEYSTORE="${HOME}/.android/debug.keystore"
ALIAS="androiddebugkey"
STOREPASS="android"
KEYPASS="android"

while [[ $# -gt 0 ]]; do
  case $1 in
    -k|--keystore)
      KEYSTORE="$2"
      shift 2
      ;;
    -a|--alias)
      ALIAS="$2"
      shift 2
      ;;
    -p|--password)
      STOREPASS="$2"
      KEYPASS="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [-k keystore] [-a alias] [-p password]"
      exit 1
      ;;
  esac
done

echo "Getting SHA-256 fingerprint from keystore: $KEYSTORE"

if [ ! -f "$KEYSTORE" ]; then
    echo "Error: Keystore file not found at $KEYSTORE"
    echo "For release builds, specify the keystore path:"
    echo "  $0 -k path/to/keystore.jks -a your-alias -p your-password"
    exit 1
fi

FINGERPRINT=$(keytool -list -v -keystore "$KEYSTORE" -alias "$ALIAS" -storepass "$STOREPASS" -keypass "$KEYPASS" 2>/dev/null | grep -A 1 "SHA256:" | head -1 | sed 's/^[[:space:]]*SHA256: //')

if [ -n "$FINGERPRINT" ]; then
    echo ""
    echo "SHA-256 Fingerprint:"
    echo "$FINGERPRINT"
    echo ""
    echo "Update this in: public/.well-known/assetlinks.json"
else
    echo "Error: Could not extract SHA-256 fingerprint"
    exit 1
fi

