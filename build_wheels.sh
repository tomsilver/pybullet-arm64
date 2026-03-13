#!/usr/bin/env bash
set -euo pipefail

# Build wheels for multiple Python versions and upload to PyPI.
# Usage:
#   ./build_wheels.sh        # build only
#   ./build_wheels.sh upload # build and upload to PyPI

PYTHON_VERSIONS=("3.10" "3.11" "3.12" "3.13")

rm -rf wheelhouse/ build/
mkdir -p wheelhouse

built=0
for pyver in "${PYTHON_VERSIONS[@]}"; do
  echo "==> Building wheel for Python ${pyver}..."
  rm -rf build/
  if uv build --python "${pyver}" --wheel --out-dir wheelhouse; then
    built=$((built + 1))
  else
    echo "    WARNING: Failed to build for Python ${pyver}, skipping."
  fi
  echo ""
done

if [[ $built -eq 0 ]]; then
  echo "ERROR: No wheels were built."
  exit 1
fi

echo "==> Building sdist..."
rm -rf build/
uv build --sdist --out-dir wheelhouse
echo ""

echo "==> Built ${built} wheel(s):"
ls -lh wheelhouse/

if [[ "${1:-}" == "upload" ]]; then
  echo ""
  echo "==> Uploading to PyPI..."
  uvx twine upload wheelhouse/*
else
  echo ""
  echo "Run './build_wheels.sh upload' to upload to PyPI."
fi
