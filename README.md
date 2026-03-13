# pybullet-arm64

A maintained fork of [pybullet](https://github.com/bulletphysics/bullet3) that fixes building on macOS (including Apple Silicon / arm64).

The upstream `pybullet` package is no longer maintained and fails to build on modern macOS due to a bundled zlib header that redefines `fdopen` to `NULL`. This fork comments out that macro (`examples/ThirdPartyLibs/zlib/zutil.h`) and publishes wheels to PyPI so you can install without building from source.

## Installation

```
pip install pybullet-arm64
```

This is a drop-in replacement for `pybullet` — use `import pybullet` as usual:

```python
import pybullet as p
physics_client = p.connect(p.DIRECT)
p.setGravity(0, 0, -10)
# ... everything works the same as pybullet
p.disconnect()
```

## Publishing a new version to PyPI

1. Update the version in `setup.py` (the `version=` argument in the `setup()` call).
2. Build the sdist and wheel:
   ```
   pip install build twine
   rm -rf dist/ build/
   python -m build
   ```
3. Upload to PyPI:
   ```
   twine upload dist/*
   ```
   You will need PyPI credentials with access to the `pybullet-arm64` project.

## What changed from upstream

This fork is based on [bulletphysics/bullet3](https://github.com/bulletphysics/bullet3) with the following changes:

- **`examples/ThirdPartyLibs/zlib/zutil.h`**: Commented out `#define fdopen(fd, mode) NULL` which broke builds on macOS.
- **`setup.py`**: Renamed package from `pybullet` to `pybullet-arm64` and updated metadata. The compiled extension module is still named `pybullet` so `import pybullet` works.
- **`.github/workflows/publish.yml`**: CI that tests building and importing on Ubuntu, macOS (arm64), and Windows.

## License

All source code files are licensed under the permissive zlib license (http://opensource.org/licenses/Zlib) unless marked differently in a particular folder/file.

## Original project

For the full Bullet Physics SDK documentation, build instructions, and history, see the [upstream repository](https://github.com/bulletphysics/bullet3).
