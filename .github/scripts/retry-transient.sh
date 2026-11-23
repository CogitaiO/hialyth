#!/usr/bin/env bash
# Run a command and retry it when dependency downloads fail transiently.
#
# Maven Central occasionally answers GitHub-hosted runners with HTTP 429
# (Too Many Requests) or times out while Gradle resolves the Android
# toolchain. Retrying the whole Flutter build is expensive but reliable;
# genuine compile errors are not retried.
set -uo pipefail

attempts="${RETRY_ATTEMPTS:-3}"
delay="${RETRY_DELAY_SECONDS:-60}"
log="$(mktemp)"
trap 'rm -f "$log"' EXIT

# Failures worth retrying: rate limits, dropped connections, DNS/TLS blips,
# proxy errors. Keep this list narrow so broken builds fail fast.
transient_pattern='429 Too Many Requests|Could not (GET|HEAD|resolve)|Connection (reset|refused|timed out)|Read timed out|Temporary failure in name resolution|Bad Gateway|Service Unavailable|Gateway Time-?out|SSL (handshake|connection)'

for ((attempt = 1; attempt <= attempts; attempt++)); do
  if "$@" 2>&1 | tee "$log"; then
    exit 0
  fi
  status="${PIPESTATUS[0]}"

  if ((attempt >= attempts)); then
    echo "::error::Command failed after ${attempt} attempts: $*"
    exit "$status"
  fi

  if ! grep -Eqi "$transient_pattern" "$log"; then
    echo "::error::Command failed with a non-transient error; not retrying."
    exit "$status"
  fi

  echo "::warning::Attempt ${attempt}/${attempts} hit a transient network error (exit ${status}); retrying in ${delay}s."
  sleep "$delay"
  delay=$((delay * 2))
done
