# Initial verification record

Checked on 2026-11-05 in `/root/CardioLean` on the Proxmox host `prohomelab`
(`ssh proxmox`), Linux x86_64. All commands below exited successfully.

- Lean: `leanprover/lean4:v4.35.0` (Lean commit `eb6cafb7290e8bd5f2937522d8d804f58f02bafc`).
- Lake: `5.0.0-src+eb6cafb`, supplied with that Lean toolchain.
- Mathlib: v4.35.0, commit `56a005855ea17e0b0958f73ec801ae140b0a1679`.
- `lake-manifest.json` locks Mathlib and its transitive dependencies.

## Compilation

From the repository root, after installing elan and making its binaries available:

```bash
export PATH="$HOME/.elan/bin:$PATH"
export LEAN_NUM_THREADS=4
lake exe cache get
lake build
lake env lean CardioLean/Contraction/Hill.lean
```

The cache command found all required precompiled Mathlib artifacts. The build
reported `Build completed successfully (910 jobs).` with no warnings after
updating imports to the pinned release's module conventions. All 24 topic modules
and the root entry point compiled. The separate Hill check produced no errors
or warnings. The six checked theorem names and exact assumptions are recorded
in [the Hill model notes](models/Hill.md).

An additional temporary file importing only `CardioLean` successfully checked
the public API and the definitional equality of `velocity` with its formula.
This verifies that the library entry point exposes the implemented mathematics.

## Proof foundations and structure

A temporary Lean file used `import all CardioLean.Contraction.Hill` and
`#print axioms` on each of the six theorems. Each reported exactly:

```text
[propext, Classical.choice, Quot.sound]
```

These are standard logical foundations used by Lean/Mathlib real-number proofs.
No theorem reported `sorryAx` or any custom axiom. No project Lean source contains
`sorry`, `admit`, a new `axiom`, or a proof-bypassing mechanism.

Structure checks confirmed that every requested module exists and is imported by
`CardioLean.lean`, documentation links resolve, and the original README introduction
is retained verbatim. `git diff --check` passed. Future-model modules contain only
documentation and namespaces; compiling them does not verify future model equations.

## What remains separate

GitHub Actions is configured in [lean.yml](../.github/workflows/lean.yml) using
pinned action revisions. A local build is not evidence of a successful hosted CI
run; consult the workflow result for the corresponding published commit.

No human independent mathematical or scientific review has been recorded. Units
are described but not enforced by Lean types. Mathematical proofs about this
specified function do not establish physiological accuracy, experimental fit,
or applicability to human cardiac muscle.
