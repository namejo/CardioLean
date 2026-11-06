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

## First circulation component and paper mapping (2026-11-05)

Environment: Proxmox `prohomelab`, `/root/CardioLean`; Lean 4.35.0, Lake
5.0.0-src+eb6cafb, Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`.
No toolchain or Lean dependency revision was changed.

Successful commands on the final Lean sources:

```bash
lake exe cache get
lake build
lake env lean CardioLean/Contraction/Hill.lean
lake env lean CardioLean/Circulation/Windkessel.lean
lake env lean test/ModelChecks.lean
```

The full library build completed 2218 jobs with no warnings. Hill now has eight
checked theorems, and Windkessel has nine. A temporary `import all` file ran
`#print axioms` on all 17; every result depended only on `propext`,
`Classical.choice`, and `Quot.sound`, without `sorryAx` or new custom axioms.
The root-import model checks verify API use, a zero-inflow solution example,
equal-RC pressure curves, failure of a zero-compliance balance, and growth with
negative compliance. The GitHub workflow now includes these checks; its hosted
result for this new commit must be observed separately.

The source-map index was checked against all 17 actual theorem names. Markdown
and notebook relative links, original README preservation, and absence of proof
holes were checked. Crossref metadata was checked for the four new references;
only the two Windkessel papers supplied adopted equations. Candidate paper
reading depth is recorded in the research tree.

Both notebooks executed successfully using Python 3.13.5 and the existing optional
pins (Matplotlib 3.11.2, ipykernel 7.4.0, NBClient 0.11.0):

```bash
python notebooks/execute.py
python notebooks/execute.py windkessel-exploration.ipynb
```

The Windkessel notebook checked 501 baseline samples, bounds, ordering, the
exp(-1) excess-pressure factor, and identical pressure curves from positive
parameter pairs with equal RC. With synthetic R=2, C=0.5, pOut=5, pInit=15 in
the stated units, p(RC) was approximately 8.678794 mmHg. Forward-Euler errors at
RC decreased from about 0.514732 to 0.058242 mmHg as the step was successively
halved from RC/4 to RC/32. A step of 1.25 RC gave an initial update to 2.5 mmHg,
below the 5 mmHg reference. The exported figure was visually inspected.

These are finite floating-point experiments, not proofs about the numerical
scheme or experimental validation. No general-input solution theory, uniqueness,
formal infinite-time limit, parameter fitting, chamber/valve coupling, or
independent human scientific review is claimed.

## Constant input and interval-local uniqueness (2026-11-05)

Environment: Proxmox `prohomelab`, `/root/CardioLean`, Lean 4.35.0, Lake
5.0.0-src+eb6cafb, Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`.
The toolchain, manifest, and optional Python dependency pins are unchanged.

These commands completed successfully on the final Lean code:

```bash
lake exe cache get
lake build
lake env lean CardioLean/Circulation/WindkesselConstant.lean
lake env lean test/ModelChecks.lean
```

The build completed 2219 jobs without warnings. Nine new theorems establish
constant-input initial value, zero-input specialization, equilibrium outflow,
flow balance, interval bounds, nonincrease/nondecrease, conditional uniqueness
for a common arbitrary input, and agreement with the constant-input closed form.
The library now has 26 named model theorems. An `import all` / `#print axioms`
audit of every one reported only `propext`, `Classical.choice`, and `Quot.sound`,
with no `sorryAx` or custom axioms.

The CI model checks now also exercise nonzero flow, interval-local uniqueness
with an arbitrary candidate function, rising-case bounds, and exact recovery of
the zero-input model. They passed on Proxmox. Hosted CI for the published commit
requires its own observed result; this record does not infer that from local checks.

The new notebook completed every cell in a fresh kernel:

```bash
python notebooks/execute.py windkessel-constant-inflow.ipynb
```

Using Python 3.13.5 and the existing optional package pins, it checked 501 samples
for each of rising, equilibrium, and falling curves. With synthetic R=2, C=0.5,
pOut=5 and q=5 in the documented units, equilibrium pressure was 15 mmHg.
Pressures at RC for initial values 10, 15, and 20 mmHg were approximately
13.160603, 15, and 16.839397 mmHg. Euler errors at RC decreased from about
0.257366 to 0.029121 mmHg as the step was halved from RC/4 to RC/32.
A specific equal-RC pair gave identical zero-input curves but distinct curves
with the same nonzero input. This is a finite example, not a general parameter
identifiability proof. The saved plot was visually inspected.

The source index covers all 26 theorem names; relative links, all library imports,
absence of proof holes, notebook format/completion, and preservation of the
original README introduction were checked. No new scientific equation was adopted
from an uninspected paper: the new curve is an explicit specialization of the
already cited source balance.

The uniqueness theorem requires the ordinary derivative balance at every point
of the closed observation interval, including endpoints. It is conditional on
the existence of those candidates. General-input existence, weaker endpoint
regularity, switching inputs/valves, infinite-time limits, numerical-method
guarantees, parameter fitting, and physiological validation remain open.

## Passive Maxwell/Kelvin–Voigt foundations (2026-11-05)

The user selected passive stretching first, followed by active contraction later.
Work was performed on Proxmox `prohomelab`, `/root/CardioLean`, using Lean 4.35.0,
Lake 5.0.0-src+eb6cafb, and Mathlib
`56a005855ea17e0b0958f73ec801ae140b0a1679`. Toolchain and dependency pins are unchanged.

These commands exited successfully on the final Lean code:

```bash
lake exe cache get
lake build
lake env lean CardioLean/Mechanics/LinearViscoelastic.lean
lake env lean test/ModelChecks.lean
```

The full build completed 2222 jobs without warnings. The new mechanics module
contains 15 named checked theorems; the library now contains 41 named model
theorems. An `import all` / `#print axioms` audit of all 41 reported only
`propext`, `Classical.choice`, and `Quot.sound`, with no custom axiom or `sorryAx`.
The source-map index includes all actual theorem names and new definitions.

The model checks include negative viscosity producing negative dashpot power and
a complete positive-parameter pointwise tuple that satisfies the parallel-network
branch/rate relations. It yields 5=5 for the topology-derived coefficient and
4!=5 for the coefficient currently displayed in Caporizzo2018 HTML equation (4).
The diagram was visually inspected and the displayed HTML/MathML was read.
The publisher PDF, possible errata, and authors' intended interpretation remain
unverified; the literature issue is Under investigation. No claim of an erratum
or of invalid experimental results is made.

The notebook completed every cell in a fresh kernel using Python 3.13.5 and the
existing optional package pins:

```bash
python notebooks/execute.py passive-viscoelasticity.ipynb
```

All values were synthetic. The basic-element time constant was 0.5 s; Maxwell
post-loading stress at that time was approximately 7.357589 Pa from an initial
20 Pa. Finite ramp–hold–return calculations checked 2197 smooth-phase pointwise
power balances, with maximum absolute residual about `2.66e-15 Pa/s`. Ramp
corners were excluded from ordinary-derivative checks. Numerically integrated
steady-cycle loop work agreed with the informal harmonic formula within relative
tolerance `1e-4` for Kelvin–Voigt, Maxwell, and the parallel network. The plot was
visually inspected. These do not prove an integrated energy inequality or a
complex-modulus theorem in Lean.

Markdown/notebook links, all root-module imports, absence of proof holes, saved
notebook completion, and original README introduction preservation were checked.
The selected linear network is bilateral, so compression/slackening limits are
documented explicitly. No experiment was fitted, no cell parameters were inferred,
and no complete passive or active cardiomyocyte model was validated. Hosted CI
for the published commit requires its own observed outcome.

## Pixel/voxel-method exploration (2026-11-06)

Work was performed on Proxmox prohomelab in /root/CardioLean, branch
feature/voxel-method-exploration. The pins remain Lean 4.35.0, Lake
5.0.0-src+eb6cafb, and Mathlib 56a005855ea17e0b0958f73ec801ae140b0a1679.
LEAN_NUM_THREADS=4 was used. On the final Lean source, all these commands exited 0
without warnings:

~~~bash
lake exe cache get
lake build
lake env lean CardioLean/Mechanics/PlanarNetwork.lean
lake env lean test/ModelChecks.lean
lake env lean test/PlanarNetworkChecks.lean
~~~

The full build completed 2223 jobs. The new module contains 21 named checked
theorems; the library now contains 62. An import-all / print-axioms audit of
all 62 returned only propext, Classical.choice, and Quot.sound.
No custom axiom, proof hole, or proof-bypassing mechanism was used.

The strongest new result gives an actual total stored-energy derivative in
terms of internal nodal power and dissipation, conditional on supplied
differentiable trajectories and Maxwell laws. It is not a nodal ODE solution,
external-work theorem, integrated energy inequality, rigidity theorem, or
physiological validation. Unit directions and unique links remain geometry
preconditions documented outside the raw Edge structure.
Six new standalone examples check important exclusions and sign conventions.

The numerical script and notebook were executed on Proxmox with Python
3.13.5, NumPy 2.5.4,
and Matplotlib 3.11.2 in the existing optional environment:

~~~bash
python experiments/voxel_method.py
python -m py_compile experiments/voxel_method.py
python notebooks/execute.py voxel-method.ipynb
~~~

The notebook completed all six code cells in a fresh kernel, saved output and
an embedded PNG. The standalone figure was visually inspected. No optional
Python dependency was added to the Lean build.

Recorded synthetic results:

- 3-by-3 planar node grid: axial/diagonal free nullities 6/3; after three
  rigid-motion constraints, 3/0. Shear energy 0/0.0025 under the stated toy weights.
- 3-by-3-by-3 node cube: six-neighbor/face-and-body-diagonal free nullities 27/6;
  after six rigid-motion constraints, 21/0. This checks only 3D topology, using
  unit weights; it is not a calibrated 3D tissue constitutive law.
- Eight-coefficient planar orthotropic Kelvin–Voigt fit: no-shear design rank 6;
  adding the same equations re-expressed at 90 degrees leaves rank 6; independent
  normal/shear/rate histories give rank 8 (363 equations). The nondimensional
  full-rank condition number was approximately 24.6841. Maximum noise-free
  coefficient error was 6.55e-15.
- Separate idealized displacement projectors: one xy observation rank 2;
  adding its screen-coordinate rotation stays rank 2; a genuinely measured yz
  component raises the stacked rank to 3. This is not the eight-parameter fit.
- Maximum tensor power residual was about 8.88e-16; graph edge-power residual
  about 3.47e-18; dynamic supplied-tuple power residual about 2.78e-17.
- Under explicitly chosen 2D toy weights, two affine deformation energies were
  unchanged at node counts 2, 3, 5 and 9 per axis. This is not general mesh
  convergence or constitutive calibration.

[The JSON record](research/voxel-method-results.json) includes full singular
values, rank tolerances, normalization, coefficients and limitations.
Known synthetic stresses are provided to the linear tensor fit; ordinary MRI
does not supply these local stresses. No real images were imported or fitted.
There is no noise/uncertainty study, nonlinear identification guarantee, active
contraction, or physiological comparison.

The source audit used primary full text where stated and publisher/author
abstracts where full equations were unavailable. Mao2010 was inspected at
abstract level; Parvizian2007 remains an abstract-only reading candidate.
GitHub Actions status is separate from these observed Proxmox checks.

Final structural checks also passed: all 27 library modules are imported by the
root, 161 local Markdown/notebook links resolve, all six new notebook code cells
have completed outputs with an embedded figure, and the original README from
commit 4bf4c0f remains an unchanged prefix. Git diff whitespace checks and the
updated notebook-runner syntax check passed.
