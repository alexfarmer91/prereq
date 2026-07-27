#!/usr/bin/env bash
# Run the Flutter web app against the deployed Railway backend instead of
# localhost. That backend runs with SKIP_AUTH=false, so real Google sign-in
# is required — DEV_AUTH_BYPASS won't work here.
#
# GOOGLE_CLIENT_ID below is a placeholder — fill in the real Google Cloud
# "Web application" OAuth Client ID once created, and register this exact
# origin (http://localhost:8765) as an Authorized JavaScript origin for it.
# The port is pinned deliberately: Google OAuth requires pre-registering
# exact origins, but `flutter run -d chrome` picks a random port by default.
set -euo pipefail

API_BASE_URL="https://prereq-production-7bb8.up.railway.app"
GOOGLE_CLIENT_ID="49383558409-ndm35kqgn1pnrv94ebnp19430mcdurnn.apps.googleusercontent.com"
WEB_PORT="8765"

cd "$(dirname "$0")"
exec flutter run -d chrome \
  --web-port="$WEB_PORT" \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID"
