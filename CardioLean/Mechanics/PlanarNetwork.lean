module

public import CardioLean.Mechanics.LinearViscoelastic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp

/-!
# A small-deformation planar axial network

This is a project-derived mathematical exploration, not an MRI reconstruction or
validated myocardial constitutive law. The element algebra reuses Roylance2001's
standard Maxwell/Kelvin-Voigt laws through `LinearViscoelastic`. The square-grid
shear test is motivated by Mao, Xu and Lubensky (2010), PRL 104, 085504,
https://arxiv.org/abs/0909.2616 (original abstract on the author-preprint record).
See docs/models/VoxelMechanics.md for assumptions, sources and limitations.

Node displacements and velocities are real pairs. Each physical link should be
listed once; a finite edge index does not itself enforce this. A link direction
is a supplied fixed vector. Its intended force/extension interpretation requires
that it be the unit reference direction from `start` to `finish`; normalization,
reference geometry and distinct endpoints are not enforced by the structure.
The algebraic lemmas remain true without those geometric restrictions.

Unlike the stress/strain names in `LinearViscoelastic`, arguments here represent
extension q [m], force z [N], stiffness k [N/m], and viscosity c [N*s/m]. These
units are documented conventions, not a dimension-checking Lean type system.
Fixed directions mean infinitesimal kinematics, not finite-rotation mechanics.
-/

@[expose] public section

namespace CardioLean.Mechanics.PlanarNetwork

open scoped BigOperators

/-- Two Cartesian components, used for displacement, velocity and force. -/
abbrev Vector := ℝ × ℝ

/-- Euclidean dot product written explicitly to keep the first proofs readable. -/
noncomputable def dot (v w : Vector) : ℝ := v.1 * w.1 + v.2 * w.2

/-- One axial connection. Supply a unit reference direction for physical use. -/
structure Edge (Node : Type*) where
  start : Node
  finish : Node
  direction : Vector

/-- Linearized extension: relative displacement projected onto the fixed direction. -/
noncomputable def extension {Node : Type*} (e : Edge Node) (u : Node → Vector) : ℝ :=
  dot e.direction (u e.finish - u e.start)

/-- Reversing endpoint order also reverses the stored direction. -/
def reverse {Node : Type*} (e : Edge Node) : Edge Node :=
  ⟨e.finish, e.start, -e.direction⟩

/-- Reversing an edge changes its description, not its extension. `ring` checks
that the two sign reversals cancel in both Cartesian components. -/
theorem extension_reverse {Node : Type*} (e : Edge Node) (u : Node → Vector) :
    extension (reverse e) u = extension e u := by
  dsimp [extension, reverse, dot]
  ring

/-- Translating every node by the same vector does not stretch any link. -/
theorem extension_translation {Node : Type*} (e : Edge Node) (u : Node → Vector)
    (a : Vector) : extension e (fun i => u i + a) = extension e u := by
  dsimp [extension, dot]
  ring

/-- A reference-aligned axial direction does not respond to an infinitesimal
rigid rotation. The arbitrary scale is normally the inverse reference length;
normalization is not needed for this algebraic invariance. -/
theorem extension_infinitesimal_rotation {Node : Type*} (e : Edge Node)
    (reference : Node → Vector) (scale angle : ℝ)
    (hDirection : e.direction =
      (scale * ((reference e.finish).1 - (reference e.start).1),
       scale * ((reference e.finish).2 - (reference e.start).2))) :
    extension e (fun i => (-angle * (reference i).2, angle * (reference i).1)) = 0 := by
  unfold extension
  rw [hDirection]
  dsimp [dot]
  ring

/-- With a fixed reference direction, differentiating nodal displacement
components differentiates the extension to the projected relative velocity. -/
theorem extension_hasDerivAt {Node : Type*} (e : Edge Node)
    {u : Node → ℝ → Vector} {velocity : Node → Vector} {t : ℝ}
    (hx : ∀ i, HasDerivAt (fun s => (u i s).1) (velocity i).1 t)
    (hy : ∀ i, HasDerivAt (fun s => (u i s).2) (velocity i).2 t) :
    HasDerivAt (fun s => extension e (fun i => u i s)) (extension e velocity) t := by
  exact (((hx e.finish).sub (hx e.start)).const_mul e.direction.1).add
    (((hy e.finish).sub (hy e.start)).const_mul e.direction.2)

/-- Force on the start node from a positive tensile axial force. -/
noncomputable def startForce {Node : Type*} (e : Edge Node) (force : ℝ) : Vector :=
  (force * e.direction.1, force * e.direction.2)

/-- Equal and opposite force on the finish node. -/
noncomputable def finishForce {Node : Type*} (e : Edge Node) (force : ℝ) : Vector :=
  (-force * e.direction.1, -force * e.direction.2)

/-- Each internal link satisfies action-reaction, without a loading assumption. -/
theorem paired_force_cancels {Node : Type*} (e : Edge Node) (force : ℝ) :
    startForce e force + finishForce e force = 0 := by
  apply Prod.ext <;> dsimp [startForce, finishForce] <;> ring

/-- Mechanical power delivered by this link's two nodal forces. -/
noncomputable def pairedPower {Node : Type*} (e : Edge Node) (force : ℝ)
    (velocity : Node → Vector) : ℝ :=
  dot (startForce e force) (velocity e.start) +
    dot (finishForce e force) (velocity e.finish)

/-- Internal nodal power is minus tensile force times extension rate. This sign
is why restoring forces remove the energy supplied to a passive link. -/
theorem paired_power_eq {Node : Type*} (e : Edge Node) (force : ℝ)
    (velocity : Node → Vector) :
    pairedPower e force velocity = -force * extension e velocity := by
  dsimp [pairedPower, startForce, finishForce, extension, dot]
  ring

/-- Sum of internal nodal power across a finite list of unique links. -/
noncomputable def internalPower {Node EdgeId : Type*} [Fintype EdgeId]
    (edges : EdgeId → Edge Node) (force : EdgeId → ℝ) (velocity : Node → Vector) : ℝ :=
  ∑ e, pairedPower (edges e) (force e) velocity

/-- Finite-network virtual power follows by summing the paired-force identity.
No node equation of motion is assumed or solved by this theorem. -/
theorem internal_power_eq {Node EdgeId : Type*} [Fintype EdgeId]
    (edges : EdgeId → Edge Node) (force : EdgeId → ℝ) (velocity : Node → Vector) :
    internalPower edges force velocity = -(∑ e, force e * extension (edges e) velocity) := by
  simp only [internalPower, paired_power_eq, neg_mul, Finset.sum_neg_distrib]

/-- Spring energy plus the energy of the spring inside a Maxwell branch. -/
noncomputable def edgeEnergy (k0 k1 q z : ℝ) : ℝ :=
  LinearViscoelastic.springEnergy k0 q + z ^ 2 / (2 * k1)

/-- Nonnegative stored energy needs nonnegative k0 and positive k1. -/
theorem edge_energy_nonneg {k0 k1 : ℝ} (h0 : 0 ≤ k0) (h1 : 0 < k1) (q z : ℝ) :
    0 ≤ edgeEnergy k0 k1 q z := by
  exact add_nonneg (LinearViscoelastic.springEnergy_nonneg h0 q)
    (div_nonneg (sq_nonneg z) (le_of_lt (mul_pos (by norm_num) h1)))

/-- Differentiate the stored energy from actual differentiable q and z histories.
The only division condition is k1 != 0; positive stiffness is a separate physical
assumption used by the energy-sign theorem. -/
theorem edge_energy_hasDerivAt {q z : ℝ → ℝ} {v zRate t : ℝ}
    (hq : HasDerivAt q v t) (hz : HasDerivAt z zRate t)
    (k0 : ℝ) {k1 : ℝ} (h1 : k1 ≠ 0) :
    HasDerivAt (fun s => edgeEnergy k0 k1 (q s) (z s))
      (k0 * q t * v + (z t / k1) * zRate) t := by
  have hd := (LinearViscoelastic.springEnergy_hasDerivAt hq k0).add
    ((hz.pow 2).div_const (2 * k1))
  convert hd using 1
  · rfl
  · dsimp
    field_simp

/-- Total stored energy. Coefficients are fixed in time. -/
noncomputable def networkEnergy {EdgeId : Type*} [Fintype EdgeId]
    (k0 k1 q z : EdgeId → ℝ) : ℝ := ∑ e, edgeEnergy (k0 e) (k1 e) (q e) (z e)

/-- Total viscous power loss for a parallel Kelvin-Voigt/Maxwell link family. -/
noncomputable def networkDissipation {EdgeId : Type*} [Fintype EdgeId]
    (c0 c1 v z : EdgeId → ℝ) : ℝ := ∑ e, (c0 e * (v e) ^ 2 + (z e) ^ 2 / c1 e)

/-- Nonnegative link energies give nonnegative network energy. -/
theorem network_energy_nonneg {EdgeId : Type*} [Fintype EdgeId]
    {k0 k1 : EdgeId → ℝ} (h0 : ∀ e, 0 ≤ k0 e) (h1 : ∀ e, 0 < k1 e)
    (q z : EdgeId → ℝ) : 0 ≤ networkEnergy k0 k1 q z := by
  exact Finset.sum_nonneg (fun e _ => edge_energy_nonneg (h0 e) (h1 e) (q e) (z e))

/-- This sign theorem does not need a solution of a node equation. -/
theorem network_dissipation_nonneg {EdgeId : Type*} [Fintype EdgeId]
    {c0 c1 : EdgeId → ℝ} (h0 : ∀ e, 0 ≤ c0 e) (h1 : ∀ e, 0 < c1 e)
    (v z : EdgeId → ℝ) : 0 ≤ networkDissipation c0 c1 v z := by
  exact Finset.sum_nonneg (fun e _ =>
    LinearViscoelastic.parallel_dissipation_nonneg (h0 e) (h1 e) (v e) (z e))

/-- Finite sums may be differentiated term by term. The supplied histories must
have the stated derivatives; this is not an existence theorem. -/
theorem network_energy_hasDerivAt {EdgeId : Type*} [Fintype EdgeId]
    {q z : EdgeId → ℝ → ℝ} {v zRate : EdgeId → ℝ} {t : ℝ}
    (hq : ∀ e, HasDerivAt (q e) (v e) t) (hz : ∀ e, HasDerivAt (z e) (zRate e) t)
    (k0 : EdgeId → ℝ) {k1 : EdgeId → ℝ} (h1 : ∀ e, k1 e ≠ 0) :
    HasDerivAt (fun s => networkEnergy k0 k1 (fun e => q e s) (fun e => z e s))
      (∑ e, (k0 e * q e t * v e + (z e t / k1 e) * zRate e)) t := by
  exact HasDerivAt.fun_sum (fun e _ => edge_energy_hasDerivAt (hq e) (hz e) (k0 e) (h1 e))

/-- Algebraic finite-network power balance for supplied Maxwell rates. Combine
with `network_energy_hasDerivAt` to identify the storage term as a derivative. -/
theorem network_power_balance {EdgeId : Type*} [Fintype EdgeId]
    (k0 c0 : EdgeId → ℝ) {k1 c1 : EdgeId → ℝ}
    (q v z zRate : EdgeId → ℝ) (h1 : ∀ e, 0 < k1 e)
    (hRate : ∀ e, zRate e = LinearViscoelastic.maxwellStressRate (k1 e) (c1 e) (z e) (v e)) :
    (∑ e, LinearViscoelastic.parallelStress (k0 e) (c0 e) (q e) (v e) (z e) * v e) =
      (∑ e, (k0 e * q e * v e + (z e / k1 e) * zRate e)) +
        networkDissipation c0 c1 v z := by
  simp only [networkDissipation, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro e _
  simpa only [add_assoc] using
    LinearViscoelastic.parallel_power_balance (h1 e) (hRate e) (k0 e) (c0 e)

/-- The network's stored-energy derivative equals tensile input power minus
viscous loss, for differentiable histories obeying the Maxwell branch law.
Existence of those histories and a complete nodal initial-value problem remain
separate questions. Viscosity signs are required separately for passivity. -/
theorem network_energy_hasDerivAt_power {EdgeId : Type*} [Fintype EdgeId]
    {q z : EdgeId → ℝ → ℝ} {v zRate : EdgeId → ℝ} {t : ℝ}
    (hq : ∀ e, HasDerivAt (q e) (v e) t) (hz : ∀ e, HasDerivAt (z e) (zRate e) t)
    (k0 c0 : EdgeId → ℝ) {k1 c1 : EdgeId → ℝ} (h1 : ∀ e, 0 < k1 e)
    (hRate : ∀ e, zRate e =
      LinearViscoelastic.maxwellStressRate (k1 e) (c1 e) (z e t) (v e)) :
    HasDerivAt (fun s => networkEnergy k0 k1 (fun e => q e s) (fun e => z e s))
      ((∑ e, LinearViscoelastic.parallelStress (k0 e) (c0 e) (q e t) (v e) (z e t) * v e) -
        networkDissipation c0 c1 v (fun e => z e t)) t := by
  have hd := network_energy_hasDerivAt hq hz k0 (fun e => ne_of_gt (h1 e))
  have hp := network_power_balance k0 c0 (fun e => q e t) v (fun e => z e t) zRate h1 hRate
  convert hd using 1
  linarith only [hp]

/-- Coupling the geometric virtual-power identity to differentiable link
histories gives a stored-energy derivative in terms of actual internal nodal
power. This is still conditional on the supplied motion and branch states; no
mass matrix, external load or boundary reaction equation is solved here. -/
theorem network_energy_hasDerivAt_internalPower {Node EdgeId : Type*} [Fintype EdgeId]
    (edges : EdgeId → Edge Node) {u : Node → ℝ → Vector} {velocity : Node → Vector}
    {z : EdgeId → ℝ → ℝ} {zRate : EdgeId → ℝ} {t : ℝ}
    (hx : ∀ i, HasDerivAt (fun s => (u i s).1) (velocity i).1 t)
    (hy : ∀ i, HasDerivAt (fun s => (u i s).2) (velocity i).2 t)
    (hz : ∀ e, HasDerivAt (z e) (zRate e) t)
    (k0 c0 : EdgeId → ℝ) {k1 c1 : EdgeId → ℝ} (h1 : ∀ e, 0 < k1 e)
    (hRate : ∀ e, zRate e = LinearViscoelastic.maxwellStressRate
      (k1 e) (c1 e) (z e t) (extension (edges e) velocity)) :
    HasDerivAt
      (fun s => networkEnergy k0 k1
        (fun e => extension (edges e) (fun i => u i s)) (fun e => z e s))
      (-internalPower edges
        (fun e => LinearViscoelastic.parallelStress (k0 e) (c0 e)
          (extension (edges e) (fun i => u i t)) (extension (edges e) velocity) (z e t))
        velocity - networkDissipation c0 c1
          (fun e => extension (edges e) velocity) (fun e => z e t)) t := by
  have hd := network_energy_hasDerivAt_power
    (fun e => extension_hasDerivAt (edges e) hx hy) hz k0 c0 h1 hRate
  simpa only [internal_power_eq, neg_neg] using hd

/-- A homogeneous simple shear: horizontal displacement proportional to height. -/
noncomputable def simpleShear (gamma : ℝ) (x : Vector) : Vector := (gamma * x.2, 0)

/-- Every horizontal nearest-neighbor link misses this shear. -/
theorem horizontal_shear_extension (gamma x y length : ℝ) :
    dot (1, 0) (simpleShear gamma (x + length, y) - simpleShear gamma (x, y)) = 0 := by
  simp [dot, simpleShear]

/-- Every vertical nearest-neighbor link also misses this shear. The same identity
applies to velocity when gamma is replaced by its rate. -/
theorem vertical_shear_extension (gamma x y length : ℝ) :
    dot (0, 1) (simpleShear gamma (x, y + length) - simpleShear gamma (x, y)) = 0 := by
  simp [dot, simpleShear]

/-- The shear moves the top of a unit square relative to the bottom whenever
 gamma != 0, although all horizontal/vertical axial extensions vanish. -/
theorem shear_relative_displacement_nonzero {gamma : ℝ} (h : gamma ≠ 0) :
    simpleShear gamma (0, 1) ≠ simpleShear gamma (0, 0) := by
  intro heq
  have hx := congrArg Prod.fst heq
  exact h (by simpa [simpleShear] using hx)

/-- Nonzero simple shear cannot be explained by a rigid translation plus an
infinitesimal rotation. Evaluating the alleged motion at three square corners
forces translation, angle and then gamma to vanish (`linarith`). -/
theorem shear_not_infinitesimal_rigid_motion {gamma : ℝ} (h : gamma ≠ 0) :
    ¬ ∃ (translation : Vector) (angle : ℝ), ∀ x : Vector,
      simpleShear gamma x =
        (translation.1 - angle * x.2, translation.2 + angle * x.1) := by
  rintro ⟨translation, angle, hMotion⟩
  have h00x := congrArg Prod.fst (hMotion (0, 0))
  have h00y := congrArg Prod.snd (hMotion (0, 0))
  have h10y := congrArg Prod.snd (hMotion (1, 0))
  have h01x := congrArg Prod.fst (hMotion (0, 1))
  dsimp [simpleShear] at h00x h00y h10y h01x
  exact h (by linarith only [h00x, h00y, h10y, h01x])

/-- Known-force Kelvin-Voigt fitting becomes ambiguous if velocity is always a
fixed multiple of extension. This is a project algebraic example, not an MRI law. -/
theorem proportional_rate_force (k c q rateFactor : ℝ) :
    LinearViscoelastic.kelvinVoigtStress k c q (rateFactor * q) =
      (k + rateFactor * c) * q := by
  dsimp [LinearViscoelastic.kelvinVoigtStress, LinearViscoelastic.springStress,
    LinearViscoelastic.dashpotStress]
  ring

/-- A whole line of parameter pairs has the same force in that restricted
experiment. Positivity, if desired, must be checked for both selected pairs. -/
theorem proportional_rate_parameter_ambiguity (k c q rateFactor change : ℝ) :
    LinearViscoelastic.kelvinVoigtStress (k - rateFactor * change) (c + change)
      q (rateFactor * q) =
    LinearViscoelastic.kelvinVoigtStress k c q (rateFactor * q) := by
  rw [proportional_rate_force, proportional_rate_force]
  ring

end CardioLean.Mechanics.PlanarNetwork
