# Scientific sources ↔ Lean declarations

This is the central attribution index. A source equation motivates a definition;
project lemmas are properties proved here under their exact Lean hypotheses.
The table does not mean that the original authors stated or formally proved
those lemmas, or that their entire paper was formalized. Full bibliographic
entries are in [REFERENCES.md](../REFERENCES.md).

## Implemented equations

| Reference and locator | Lean module / namespace | Correspondence and scope |
|---|---|---|
| Hill1938, printed p. 161, equations (1)–(2) | [Contraction/Hill.lean](../CardioLean/Contraction/Hill.lean), `CardioLean.Contraction.Hill` | `velocity`: rearranged force–velocity relation; P/P₀ renamed F/F₀ |
| Wang2003, p. H1359, equations (1)–(2), resistive-outflow paragraph; Alastruey2010, equation (1) | [Circulation/Windkessel.lean](../CardioLean/Circulation/Windkessel.lean), `CardioLean.Circulation.Windkessel` | `outflow` and `SatisfiesBalanceAt`: explicit derivative witness and flow balance; R/C fixed; P∞ or P_out becomes pOut |
| Wang2003, equation (3) and following zero-inflow discussion; Alastruey2010, equation (2) | Same Windkessel module | `decay`: zero-inflow, initial-time-zero specialization; not the general forced solution |
| Wang2003, p. H1359, equations (1)–(3); Alastruey2010, equations (1)–(2) | [Circulation/WindkesselConstant.lean](../CardioLean/Circulation/WindkesselConstant.lean), same Windkessel namespace | `equilibriumPressure` and `constantPressure`: project constant-input specialization, initial time zero |

The six definitions/predicates in the table above (`velocity`, `outflow`,
`SatisfiesBalanceAt`, `decay`, `equilibriumPressure`, `constantPressure`) have status **Formal definition completed**.
Their model documentation supplies assumptions, units, biological interpretation,
and limitations: [Hill](models/Hill.md), [Windkessel](models/Windkessel.md),
[constant input and uniqueness](models/WindkesselConstant.md).

## Project-derived results

Every theorem listed here has status **Machine-checked proof completed**;
[verification evidence](VERIFICATION.md) records the actual checks. Names below
are relative to the module namespace in the first column.

| Namespace | Derived Lean theorems | Relation to scientific source |
|---|---|---|
| `CardioLean.Contraction.Hill` | `denominator_pos`, `equation_iff_velocity` | Side condition and reversible rearrangement of the Hill equation |
| Same | `velocity_nonneg`, `velocity_at_isometric`, `velocity_antitoneOn`, `velocity_strictAntiOn` | Project proofs of signs, endpoint, and comparisons under explicit hypotheses |
| Same | `velocity_at_zero`, `velocity_bounds` | Project derivations of zero-load velocity and interval bounds, extending the chapter exercises |
| `CardioLean.Circulation.Windkessel` | `decay_initial`, `decay_hasDerivAt`, `decay_satisfies_zeroInflow` | Check the specialized candidate against its initial condition and the source balance |
| Same | `decay_ge_out`, `decay_le_initial`, `decay_antitone`, `outflow_nonneg` | Project proofs of pressure and outflow properties |
| Same | `decay_at_timeConstant` | Check the exact exp(-1) pressure-difference factor at RC |
| Same | `decay_eq_of_product_eq` | Project derivation: identical RC products give identical pressure curves for the same initial/reference pressures |

The following additional declarations extend the same Windkessel namespace in
`WindkesselConstant.lean`, also with status **Machine-checked proof completed**:

| Derived Lean theorems | Attribution and scope |
|---|---|
| `constantPressure_initial`, `constantPressure_zero` | Project checks of initial value and exact zero-input specialization |
| `outflow_at_equilibrium`, `constantPressure_satisfies_balance` | Project checks of the equilibrium and the constant-input source balance |
| `constantPressure_bounds`, `constantPressure_antitone`, `constantPressure_monotone` | Project bounds and comparisons for the specialized solution |
| `solutions_unique`, `constantPressure_unique` | Project integrating-factor / mean-value argument for interval-local conditional uniqueness; not an existence result for arbitrary inputs |

The source equations motivate these results; the uniqueness proof also uses
Mathlib's `Analysis/Calculus/MeanValue.lean` at the pinned revision. No scientific
paper is credited with supplying that Lean proof.

The test examples in [test/ModelChecks.lean](../test/ModelChecks.lean) exercise
these results and excluded parameter cases. The Python notebooks independently
implement numerical formulas; they are not extracted from Lean and do not add
machine-checked theorems. Future refactoring must preserve this distinction.

## Passive mechanics: explicit branch-law derivations

[LinearViscoelastic.lean](../CardioLean/Mechanics/LinearViscoelastic.lean),
namespace `CardioLean.Mechanics.LinearViscoelastic`, adds the definitions
`springStress`, `dashpotStress`, `kelvinVoigtStress`, `maxwellStressRate`,
`springEnergy`, `parallelStress`, `relaxation`, and `kelvinCreep`, all with status
**Formal definition completed**. Units, initial states, signs, and limits are in
[Chapter 4](models/PassiveViscoelasticity.md).

| Source / project derivation | Lean theorems, all Machine-checked proof completed |
|---|---|
| Project spring energy and dashpot sign calculations from Hookean/Newtonian element laws (Roylance2001 section 4.1) | `springEnergy_nonneg`, `springEnergy_hasDerivAt`, `dashpot_dissipation_nonneg` |
| Project parallel-stress power identity for Kelvin–Voigt elements (Roylance2001 problems 7–10) | `kelvinVoigt_power_balance` |
| Roylance2001 equation (22), rearranged; project power identity | `maxwell_rate_iff`, `maxwell_power_balance` |
| Caporizzo2018 Figures 2D/3B topology, using standard branch laws; project energy and elimination derivations | `parallel_power_balance`, `parallel_dissipation_nonneg`, `parallel_second_order` |
| Roylance2001 section 4.1 post-loading relaxation; project derivative/bounds proofs | `relaxation_initial`, `relaxation_hasDerivAt`, `relaxation_bounds` |
| Roylance2001 Voigt creep (problems 7–10), specialized to constant stress / zero initial strain | `kelvinCreep_initial`, `kelvinCreep_hasDerivAt`, `kelvinCreep_balance` |

The second-order coefficient is explicitly **not** copied from Caporizzo's
currently displayed HTML equation (4); see [the unresolved source audit](research/002-viscoelastic-source-audit.md).
The diagram, standard element laws, and the chosen interpretation are separate
pieces of evidence. Algebraic consistency does not validate a biological topology
or establish that a displayed source discrepancy is an authorial error.
Moulton2017 is background reading for future 3D mechanics, with no mapped Lean
constitutive equation yet. Active contraction remains future work.

## Investigated papers without an implemented equation

- WagnerKeizer1994: calcium-buffering/diffusion reading candidate; no Lean equation mapped yet.
- SugaSagawa1974: ventricular pressure–volume candidate; metadata checked, original full text not yet inspected.

These branches are **Under investigation**, with evidence and next prerequisites
in [the research tree](research/001-next-directions.md). Other reserved modules
remain **Not started**. No independent human review or physiological validation
is implied by any status here.

## Planar network: voxel-method mathematical precursor

[PlanarNetwork.lean](../CardioLean/Mechanics/PlanarNetwork.lean), namespace
`CardioLean.Mechanics.PlanarNetwork`, adds the following representations,
all **Formal definition completed**: `Vector`, `dot`, `Edge`, `extension`, `reverse`, `startForce`, `finishForce`, `pairedPower`, `internalPower`, `edgeEnergy`, `networkEnergy`, `networkDissipation`, `simpleShear`.

These are project constructions. The supplied edge directions are not
automatically checked as normalized image-derived geometry. Force/extension
units differ from the scalar source module's stress/strain interpretation.

All 21 theorems below have status **Machine-checked proof completed**:

| Provenance and scope | Actual theorem names |
| --- | --- |
| Axial compatibility; project vector algebra, with fixed reference-aligned directions for rotation | `extension_reverse`, `extension_translation`, `extension_infinitesimal_rotation`, `extension_hasDerivAt` |
| Equal/opposite endpoint forces and finite-sum virtual power; project derivation | `paired_force_cancels`, `paired_power_eq`, `internal_power_eq` |
| Connection/finite-network stored energy and sign conditions; standard element laws from Roylance2001 | `edge_energy_nonneg`, `edge_energy_hasDerivAt`, `network_energy_nonneg`, `network_dissipation_nonneg`, `network_energy_hasDerivAt` |
| Parallel branch laws and finite sums; project derivation reusing LinearViscoelastic | `network_power_balance`, `network_energy_hasDerivAt_power`, `network_energy_hasDerivAt_internalPower` |
| Square-grid limitation motivated by Mao2010 original abstract; explicit finite-dimensional project proof | `horizontal_shear_extension`, `vertical_shear_extension`, `shear_relative_displacement_nonzero`, `shear_not_infinitesimal_rigid_motion` |
| Known-force Kelvin–Voigt proportional-rate ambiguity; project algebra, not a theorem adopted from an MRI paper | `proportional_rate_force`, `proportional_rate_parameter_ambiguity` |

The strongest energy result is an actual conditional stored-energy derivative,
equal to minus internal nodal power minus dissipation. Supplied nodal motion and
Maxwell states must have the stated derivatives and satisfy the branch law.
A full mass/external-work equation, existence/uniqueness, and an integrated
energy inequality are not claimed. Parameter signs needed for physical
passivity are separate hypotheses of the sign theorems.

The [chapter](models/VoxelMechanics.md) supplies assumptions and units.
[PlanarNetworkChecks.lean](../test/PlanarNetworkChecks.lean) checks endpoint
force reversal, invisible shear, finite-rotation limitations, direction scaling,
positive indistinguishable parameter pairs, and negative-stiffness exclusions.

### Numerical exploration and reading-only sources

The [experiment](../experiments/voxel_method.py),
[executed notebook](../notebooks/voxel-method.ipynb), and
[JSON results](research/voxel-method-results.json) have status **Under investigation**.
They independently implement numerical formulas; they are not extracted from
Lean. The 3D connection check and eight-coefficient tensor fit are not Lean
theorems or a completed 3D voxel constitutive model.

Asner2016 sections 2.2/2.4, Hadjicharalambous2015 section 2.3.1 equations (13)–(14)
and Theorem 2, and Castelein2025 acquisition/processing sections inform the
measurement and identifiability discussion. Their cardiac constitutive equations,
inversion procedures and experimental results are not formalized here.
Parvizian2007 is an abstract-only continuum-grid reading candidate.
[The literature audit](research/003-voxel-method-literature.md) records access and
exact adoption limits. No physiological validation or independent human review
is claimed.
