---
emoji: 📝
name: Sync mcrdocs portal docs
description: When a devcontainer image changes, open a draft PR in Kaniska244/mcrdocs updating the portal docs to match.
on:
  push:
    branches: [main]
    paths:
      - "src/**/manifest.json"
      - "src/**/README.md"
  workflow_dispatch:
    inputs:
      images:
        description: "Comma-separated image names to force a sync for"
        required: false

permissions:
  copilot-requests: write
  contents: read
  pull-requests: read

engine: copilot
strict: true

tools:
  github:
    toolsets: [pull_requests, repos]
    mode: gh-proxy
  bash:
    - gh

network:
  allowed: [defaults, github]

safe-outputs:
  create-pull-request:
    max: 1
    staged: false
    allowed-branches: [main]
    github-token: ${{ secrets.MCRDOCS_SYNC_TOKEN }}
---

# Sync devcontainer portal docs to mcrdocs

## Goal
When one or more devcontainer images change in this repository, update the
corresponding portal documentation in `Kaniska244/mcrdocs` so it accurately
reflects the current image definitions, and open a **draft** pull request there
for human review.

## Source of truth (this repo: Kaniska244/images)
For each changed image under `src/<image>/`:
- `manifest.json` — authoritative for `version`, `variants`,
  `build.variantTags`, and `build.architectures`.
- `README.md` — supporting prose for that image.

## Target files (in Kaniska244/mcrdocs)
- Per-image: `teams/devcontainers/README.<image>.portal.md`
- Aggregate index: `teams/devcontainers/README.dev-containers.md`

## Steps
1. Determine which images changed in this push (or use the `images` input when
   run manually). Base image is split across `src/base-alpine`,
   `src/base-debian`, and `src/base-ubuntu`.
2. For each changed image, read BOTH the updated `manifest.json` in this repo
   AND the current target doc in `Kaniska244/mcrdocs`.
3. Update the tag/variant lists, version references, OS variants, and
   architecture notes so they match the manifest. Normalize tags for humans:
   strip the `image:` prefix and expand/remove the `${VERSION}` and
   `${VARIANT}` placeholders (e.g. `go:${VERSION}-1.26-trixie` becomes
   `1.26-trixie`). De-duplicate and order tags consistently.
4. In `README.dev-containers.md`, update that image's entry in the aggregate
   list. Merge `base-alpine` / `base-debian` / `base-ubuntu` into the single
   `base` entry.
5. Preserve each document's existing prose, voice, and hand-written sections
   (ARM64 support, Release tags, Contributing, etc.). Only change content that
   is now factually inaccurate.
6. While editing, fix obvious inconsistencies you encounter — for example the
   `debain-13` typo in the `cpp` entry, jumbled `python` tag ordering, and the
   stale `java` `0.205.0` / `bullseye` release-tags example.
7. Open a single **draft** pull request in `Kaniska244/mcrdocs` with a summary of
   what changed per image, so a maintainer can review and mark it ready.

## Constraints
- Only modify files under `teams/devcontainers/**` in `Kaniska244/mcrdocs`.
- Do not invent tags or versions that are not present in the manifests.
- Keep the PR focused and reviewable.
