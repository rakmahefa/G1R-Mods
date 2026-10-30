# Packaging and releases

## Current development distribution

The DEV workflow builds an independent ZIP for each mod and uploads the files as a GitHub Actions artifact. The ZIP root contains `manifest.json`, the manifest entry file, and the mod's distributable assets. Tests and repository-only files are excluded.

Download an artifact from the relevant DEV workflow run and install the mod ZIP through the game's mod import UI.

Packages use fixed ZIP timestamps and sorted paths, making repeated builds from identical sources reproducible. `dist/checksums.sha256` contains SHA-256 hashes for the generated packages.

## Why per-mod GitHub Releases are not enabled yet

The engine's simple GitHub release updater expects one mod repository and one mod version stream. This repository is a monorepo containing multiple independently versioned mods, so pointing every mod's `github` field at `rakmahefa/G1R-Mods` would not give each mod an unambiguous release stream.

For now, keep the `github` field absent. Before enabling launcher auto-update or a community index, choose one of these designs:

1. Publish each mod to its own repository using a generated subtree/export workflow.
2. Publish a dedicated monorepo feed that maps each mod ID to its own versioned ZIP release asset and checksum.

That distribution decision is intentionally separate from local development and CI.
