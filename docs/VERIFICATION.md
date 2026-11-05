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
pinned action revisions. The [initial hosted workflow run](https://github.com/namejo/CardioLean/actions/runs/41995730781)
for commit `a01e6d8917bfa9bb771acd8f0f7ef169edf405b9` completed with conclusion
`success` on 2026-11-05. This is separately observed CI evidence, in addition to
the Proxmox checks above. Later commits require their own workflow results.

No human independent mathematical or scientific review has been recorded. Units
are described but not enforced by Lean types. Mathematical proofs about this
specified function do not establish physiological accuracy, experimental fit,
or applicability to human cardiac muscle.

## Hill chapter and notebook follow-up (2026-11-05)

The expanded Hill chapter, journal questions, and optional notebook were checked
on the same Proxmox host. No Lean source, theorem statement, or Lean dependency
was changed. `lake exe cache get` and `lake build` exited successfully again
(910 jobs, no warnings).

The notebook was executed from a fresh kernel using Python 3.13.5 and the versions
in `notebooks/requirements.txt` (Matplotlib 3.11.2, ipykernel 7.4.0, NBClient 0.11.0).
The execution command, with these optional packages installed, was:

```bash
python notebooks/execute.py
```

All code cells completed without errors. The baseline example gave velocities
0.4, approximately 0.066667, and 0 m/s at forces 0, 0.5, and 1 N. Checks on
101 baseline samples passed; the largest absolute product-equation residual was
approximately `2.78e-17 N·m/s`. This records floating-point observations, not a
new mathematical proof or experimental validation.

The exported chapter figure was visually inspected. Markdown and notebook links,
notebook format, and preservation of the original README introduction were checked.
The optional Python environment and notebook checkpoint directories are ignored.
The GitHub workflow checks Lean; notebook execution was checked separately on Proxmox.
