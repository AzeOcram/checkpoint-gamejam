#!/bin/sh
printf '\033c\033]0;%s\a' friends-we-made
base_path="$(dirname "$(realpath "$0")")"
"$base_path/friends-we-made.x86_64" "$@"
