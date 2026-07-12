# API snapshots

This directory stores deterministic exports from real client builds.

Use one subdirectory per client flavor and keep one `.snapshot` file per
version/build/project combination. Snapshot files are intentionally plain,
sorted records so normal Git diffs show API additions, removals, signature
changes, runtime type changes, and compatibility-contract results.
