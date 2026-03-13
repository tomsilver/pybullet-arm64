#!/usr/bin/env bash
set -euo pipefail

# Publish pybullet-arm64 to PyPI from CI-built wheels.
#
# Usage:
#   ./publish.sh           # download latest CI artifacts and upload to PyPI
#   ./publish.sh <run-id>  # download artifacts from a specific CI run

REPO="tomsilver/pybullet-arm64"

if [[ -n "${1:-}" ]]; then
  RUN_ID="$1"
else
  echo "==> Finding latest successful CI run on main..."
  RUN_ID=$(gh run list --repo "$REPO" --branch main --workflow CI --status completed --json databaseId,conclusion \
    --jq '[.[] | select(.conclusion == "success")][0].databaseId')

  if [[ -z "$RUN_ID" || "$RUN_ID" == "null" ]]; then
    echo "ERROR: No successful CI run found on main."
    exit 1
  fi
fi

echo "==> Using CI run: $RUN_ID"
echo "    https://github.com/$REPO/actions/runs/$RUN_ID"

# Show the version from setup.py
VERSION=$(python -c "
import re
with open('setup.py') as f:
    m = re.search(r\"version='([^']+)'\", f.read())
    print(m.group(1))
")
echo "==> Package version: $VERSION"

# Download artifacts
rm -rf dist/
mkdir -p dist

echo "==> Downloading wheels and sdist..."
gh run download "$RUN_ID" --repo "$REPO" --dir dist/

# Flatten — gh downloads into subdirectories per artifact name
find dist -name '*.whl' -o -name '*.tar.gz' | while read -r f; do
  mv "$f" dist/
done
find dist -mindepth 1 -type d -empty -delete

echo ""
echo "==> Artifacts to upload:"
ls -lh dist/
echo ""

# Confirm
read -p "Upload these to PyPI? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborted. Artifacts are in dist/ if you want to upload manually."
  exit 0
fi

echo "==> Uploading to PyPI..."
uvx twine upload dist/*

echo ""
echo "==> Done! View at: https://pypi.org/project/pybullet-arm64/$VERSION/"
