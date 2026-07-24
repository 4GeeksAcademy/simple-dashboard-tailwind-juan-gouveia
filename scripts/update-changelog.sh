#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

tmp_file="$(mktemp)"

{
  echo "# Changelog"
  echo
  echo "All notable changes to this project are documented in this file."
  echo
  git log --date=short --pretty=format:'%ad|%h|%s' --reverse | awk -F'|' '
    BEGIN { current_date = "" }
    {
      if ($1 != current_date) {
        if (current_date != "") {
          print ""
        }
        current_date = $1
        print "## " current_date
      }
      print "- " $3 " (" $2 ")"
    }
  '
} > "$tmp_file"

if [[ ! -f CHANGELOG.md ]] || ! cmp -s "$tmp_file" CHANGELOG.md; then
  mv "$tmp_file" CHANGELOG.md
  echo "CHANGELOG.md updated."
else
  rm -f "$tmp_file"
  echo "CHANGELOG.md already up to date."
fi
