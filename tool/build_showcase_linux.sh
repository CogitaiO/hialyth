#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_home="$(mktemp -d /tmp/opencode/hialyth-flutter-config.XXXXXX)"
pub_cache="${PUB_CACHE:-${HOME}/.pub-cache}"
trap 'rm -rf "$config_home"' EXIT

cd "$project_root"
export PUB_CACHE="$pub_cache"

HOME="$config_home" \
  XDG_CONFIG_HOME="$config_home/.config" \
  flutter config --build-dir build_showcase

HOME="$config_home" \
  XDG_CONFIG_HOME="$config_home/.config" \
  flutter build linux --release --target lib/main_showcase.dart
