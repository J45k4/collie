# Standalone Collie extraction

The application was extracted from Flexscript revision `d98c05f3a7de693442c5ea532ce515524f9e206c`.
`source-map.json` records each original path, destination and the SHA-256 of its
working-tree bytes. The pending change in `adapters/workspace.flex` was carried
across unchanged except for its SDK import path. The extraction preserves the original Flexscript history; this repository
records the source paths and working-tree hashes for provenance.

## Ownership

Collie owns its agent core, providers, permissions and automatic review policy,
UI screens, CLI, desktop and Android hosts, guest-facing tools, branding,
application tests, build generators, packaging and application benchmark workloads.
Flexscript owns the compiler, interpreter/JIT, VM, FlexDB, networking, images,
TUI/GUI/UI primitives and generic language/library tests. Shared tests were split
so Flexscript's compiler tool registry and CI do not require a Collie checkout.
Generic JSON fixture utilities and neutral image fixtures now live in Flexscript.

## Dependency and build contract

`flexscript.lock` pins the SDK Git revision. `configure` accepts a separate source
root, checks that revision, and creates the ignored `.flexscript` link. Changing
SDK branches requires an explicit `--allow-sdk-mismatch`; dirty SDK content is
reported, not reverted. The pin identifies the baseline revision, not a hash of
uncommitted SDK edits. CI checks out the pin independently.

The CLI and embedded desktop/Android engines consume the same SDK. Source
assembly still flattens the compiler and adapts its allocation, cancellation and
host-call entry points. Android's allowlist accepts only the Collie source root
and the configured SDK root after canonicalizing paths. No reverse application
imports or compatibility links are installed in Flexscript.

The shell scripts are configuration/bootstrap conveniences. Actual app builders
remain Flexscript, and the packaged desktop works without Python or shell launchers.
The Android package ID remains `org.flexscript.collie`; this migration does not
install an APK or change signing credentials or user data.

## Subsequent SDK work

This is the repository extraction, not a new embedding ABI. A follow-up should
replace compiler-source rewriting with explicit compile/execute/cancel/host-call
interfaces; split generic VM snapshot mechanics out of the current Collie
checkpoint adapter; and package the reusable Android widget renderer separately
from its current application package and callbacks. Those adapters remain with
Collie in this first pass to preserve the existing runtime behavior. Compiler,
VM and existing reusable libraries have not been forked into this repository.

## Validation and existing failure

The extraction was checked with the CLI suite, shared UI/core tests, Android
ARM64 native builds and QEMU worker/continuation tests, desktop workspace/docking
checks, and a packaged desktop run with Python absent from PATH. Flexscript's
portable UI, native widget, browser and generic tool checks pass independently.
The separate repository also builds its desktop and all 76 tools against the
pinned SDK revision in a separate checkout with no `apps/collie` source directory.
The offline PTY suite passes from the new repository.

The full CLI `--vm` suite also exposes an existing database-program failure
(`exit_code: 4`). It reproduces in the original checkout with the same compiler
and pending workspace-adapter edit. This extraction preserves that edit rather
than silently changing its behavior. Bubblewrap tests need a host environment
where user namespaces are available.
