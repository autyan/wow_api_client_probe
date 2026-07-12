# wow_api_client_probe

`apiRefersher` is a small World of Warcraft addon and host-side toolset for
capturing the API surface exposed by a real game client. It is intended for
build-to-build calibration after client updates, before maintaining or
patching other addons.

The probe records three complementary layers:

- Blizzard's generated API documentation and normalized signatures.
- Runtime global and `C_*` namespace symbol types.
- Focused compatibility contracts for APIs commonly used by addons.

The addon never calls arbitrary documented functions. Runtime probes are
limited to existence and type checks so a scan does not invoke protected or
state-changing APIs.

## Build

```bash
scripts/build.sh
```

Install the resulting `dist/apiRefersher` directory under the client's
`Interface/AddOns` directory.

## In-game workflow

The first login on a new client build captures a snapshot automatically. A
manual scan can be requested at any time:

```text
/apirefresher scan
/apirefresher status
/apirefresher clear
```

Run `/reload` or log out after a scan so the client writes
`apiRefersherDB` to SavedVariables.

For the cleanest runtime surface, capture the baseline with only
`apiRefersher` and Blizzard addons enabled. A normal addon session can then be
captured separately when diagnosing interactions.

## Export a snapshot

```bash
scripts/capture-snapshot.sh \
  "/path/to/WTF/Account/<account>/SavedVariables/apiRefersher.lua" \
  tbc-anniversary-cn
```

The command writes a deterministic, line-oriented snapshot under
`snapshots/<flavor>/`. Commit these snapshots to preserve the API history.

Compare two builds with:

```bash
scripts/diff-snapshots.sh snapshots/old.snapshot snapshots/new.snapshot
```

Diff sections are identified by stable record types such as `FUNCTION`,
`EVENT`, `TABLE`, `EARLY`, `RUNTIME`, and `CONTRACT`.

## Scope and limitations

- API documentation can describe systems not callable in the current game
  flavor; each function record includes its observed runtime type.
- Lua cannot safely infer native function signatures without documentation.
- Protected behavior, combat lockdown, taint, and semantic changes require
  explicit, reviewed behavior probes or real addon error traces.
- SavedVariables are the bridge out of the game sandbox; the addon does not
  write arbitrary files.

## Development

```bash
scripts/test.sh
```

The project targets TBC Anniversary interface `20506` in its first release.
Additional client flavors can use flavor-specific TOCs while sharing the same
collector and snapshot schema.
