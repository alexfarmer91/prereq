#!/usr/bin/env bash
# Run the Flutter web app against the deployed Railway backend instead of
# localhost. That backend runs with SKIP_AUTH=false, so real Google sign-in
# is required — DEV_AUTH_BYPASS won't work here.
#
# The origin http://localhost:8765 is registered as an Authorized JavaScript
# origin for GOOGLE_CLIENT_ID. The port is pinned deliberately: Google OAuth
# requires pre-registering exact origins, but flutter picks a random port by
# default.
#
# Uses `-d web-server` (not `-d chrome`): open http://localhost:8765 in your
# own browser, where your Google session lives. `-d chrome` spawns a blank
# throwaway Chrome profile whose empty cookie jar stalls Google sign-in, and
# its debug server can't be reached from other browsers.
# Hot reload still works from this terminal: r = reload, R = restart.
set -euo pipefail

API_BASE_URL="https://prereq-production-7bb8.up.railway.app"
GOOGLE_CLIENT_ID="49383558409-ndm35kqgn1pnrv94ebnp19430mcdurnn.apps.googleusercontent.com"
WEB_PORT="8765"

cd "$(dirname "$0")"
echo "App will be served at http://localhost:${WEB_PORT} — open it in your browser."
exec flutter run -d web-server \
  --web-port="$WEB_PORT" \
  --web-hostname=localhost \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID"
