module

public import Mathlib.Analysis.SpecialFunctions.ExpDeriv
public import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

/-!
# Passive one-dimensional linear viscoelastic building blocks

Roylance (2001), Engineering Viscoelasticity, section 4.1, eq. (22), gives
Maxwell's series law. Caporizzo et al. (2018), DOI 10.1016/j.bpj.2018.09.019,
Fig. 2D / 3B, motivates a Kelvin-Voigt branch parallel to a Maxwell branch.
We derive that network from its element laws; we do NOT silently copy the
paper's displayed eq. (4), whose coefficient differs from this derivation.
See docs/research/002-viscoelastic-source-audit.md for the precise discrepancy.

Assumptions: uniaxial small engineering strain, tensile applied stress positive,
constant effective parameters, quasistatic massless elements, passive response.
E has units Pa, eta Pa*s, strain is dimensionless, strain rate is 1/s.
These laws describe mathematical elements, not validated human-cell parameters.
No active contraction or complete tissue model is implemented.
-/

@[expose] public section

namespace CardioLean.Mechanics.LinearViscoelastic

/-- Effective tensile stress of a Hookean spring. -/
noncomputable def springStress (E strain : ℝ) : ℝ := E * strain

/-- Effective tensile stress of a Newtonian dashpot. -/
noncomputable def dashpotStress (eta strainRate : ℝ) : ℝ := eta * strainRate

/-- Equal strain in parallel, with branch stresses adding. -/
noncomputable def kelvinVoigtStress (E eta strain strainRate : ℝ) : ℝ :=
  springStress E strain + dashpotStress eta strainRate

/-- Maxwell series law solved for the stress rate. Intended interpretation uses
positive E and eta; Lean division itself is total. -/
noncomputable def maxwellStressRate (E eta stress strainRate : ℝ) : ℝ :=
  E * (strainRate - stress / eta)

/-- Energy per reference volume stored in a linear spring. -/
noncomputable def springEnergy (E strain : ℝ) : ℝ := E * strain ^ 2 / 2

/-- Effective stress of a Kelvin-Voigt branch parallel to a Maxwell branch.
`z` is the Maxwell branch stress, a state variable rather than instantaneous E*strain. -/
noncomputable def parallelStress (E1 eta1 strain strainRate z : ℝ) : ℝ :=
  kelvinVoigtStress E1 eta1 strain strainRate + z

/-- A nonnegative modulus gives nonnegative spring energy. -/
theorem springEnergy_nonneg {E : ℝ} (hE : 0 ≤ E) (strain : ℝ) :
    0 ≤ springEnergy E strain :=
  div_nonneg (mul_nonneg hE (sq_nonneg strain)) (by norm_num)

/-- Differentiating stored spring energy supplies the elastic power. -/
theorem springEnergy_hasDerivAt {strain : ℝ → ℝ} {v t : ℝ}
    (h : HasDerivAt strain v t) (E : ℝ) :
    HasDerivAt (fun s => springEnergy E (strain s)) (E * strain t * v) t := by
  have hd := ((h.pow 2).const_mul E).div_const 2
  convert hd using 1
  · rfl
  · dsimp
    ring

/-- A dashpot cannot produce mechanical power if eta is nonnegative. -/
theorem dashpot_dissipation_nonneg {eta : ℝ} (hEta : 0 ≤ eta) (v : ℝ) :
    0 ≤ dashpotStress eta v * v := by
  have h := mul_nonneg hEta (sq_nonneg v)
  dsimp [dashpotStress]
  nlinarith only [h]

/-- Kelvin-Voigt input power = elastic storage rate + viscous dissipation.
Combine with `springEnergy_hasDerivAt` for a time-dependent strain history. -/
theorem kelvinVoigt_power_balance (E eta strain v : ℝ) :
    kelvinVoigtStress E eta strain v * v = E * strain * v + eta * v ^ 2 := by
  unfold kelvinVoigtStress springStress dashpotStress
  ring

/-- Rearrange the Maxwell rate law to the sum of series strain rates. -/
theorem maxwell_rate_iff {E eta stress rate v : ℝ} (hE : 0 < E) :
    rate = maxwellStressRate E eta stress v ↔ v = rate / E + stress / eta := by
  unfold maxwellStressRate
  constructor <;> intro h
  · rw [h]
    field_simp; ring
  · rw [h]
    field_simp; ring

/-- Maxwell power balance: stress*v = stored spring-energy rate + dissipation.
The storage-rate term is (stress/E)*stressRate. -/
theorem maxwell_power_balance {E eta stress rate v : ℝ} (hE : 0 < E)
    (hRate : rate = maxwellStressRate E eta stress v) :
    stress * v = (stress / E) * rate + stress ^ 2 / eta := by
  rw [hRate]
  unfold maxwellStressRate
  field_simp; ring

/-- Parallel Kelvin-Voigt/Maxwell network power balance for its branch rate.
This is a passive mechanical identity, not an assertion about ATP or activation. -/
theorem parallel_power_balance {E2 eta2 strain v z zRate : ℝ} (hE2 : 0 < E2)
    (hRate : zRate = maxwellStressRate E2 eta2 z v) (E1 eta1 : ℝ) :
    parallelStress E1 eta1 strain v z * v =
      E1 * strain * v + (z / E2) * zRate + eta1 * v ^ 2 + z ^ 2 / eta2 := by
  have hm := maxwell_power_balance hE2 hRate
  dsimp [parallelStress, kelvinVoigtStress, springStress, dashpotStress]
  nlinarith only [hm]

/-- Nonnegative parallel dashpot viscosity and positive Maxwell viscosity give
nonnegative total dissipation for every strain rate and branch stress. -/
theorem parallel_dissipation_nonneg {eta1 eta2 : ℝ} (h1 : 0 ≤ eta1) (h2 : 0 < eta2)
    (v z : ℝ) : 0 ≤ eta1 * v ^ 2 + z ^ 2 / eta2 :=
  add_nonneg (mul_nonneg h1 (sq_nonneg v)) (div_nonneg (sq_nonneg z) (le_of_lt h2))

/-- Eliminate the internal stress from the branch equations and their differentiated
stress-sum relation. This is a pointwise algebraic elimination using supplied
rates, not an ODE existence/uniqueness or differentiability theorem.
The coefficient of v is E1*eta2 + E2*eta2 + E2*eta1; see the source-audit note. -/
theorem parallel_second_order {E1 E2 eta1 eta2 strain v accel z zRate stress stressRate : ℝ}
    (hEta2 : 0 < eta2) (hStress : stress = parallelStress E1 eta1 strain v z)
    (hDerivative : stressRate = E1 * v + eta1 * accel + zRate)
    (hRate : zRate = maxwellStressRate E2 eta2 z v) :
    eta1 * eta2 * accel + (E1 * eta2 + E2 * eta2 + E2 * eta1) * v + E1 * E2 * strain =
      E2 * stress + eta2 * stressRate := by
  have hz : eta2 * zRate = E2 * (eta2 * v - z) := by
    rw [hRate]
    unfold maxwellStressRate
    field_simp
  have hs := congrArg (fun x : ℝ => E2 * x) hStress
  have hd := congrArg (fun x : ℝ => eta2 * x) hDerivative
  dsimp [parallelStress, kelvinVoigtStress, springStress, dashpotStress] at hs
  nlinarith only [hs, hd, hz]

/-- Maxwell relaxation after the strain has been held fixed. The loading jump is
not differentiated here; `stress0` is the post-loading stress. -/
noncomputable def relaxation (E eta stress0 t : ℝ) : ℝ :=
  stress0 * Real.exp (-(E / eta) * t)

/-- Initial post-loading stress. -/
theorem relaxation_initial (E eta stress0 : ℝ) : relaxation E eta stress0 0 = stress0 := by
  simp [relaxation]

/-- The relaxation curve obeys the Maxwell rate law at zero strain rate.
The identity holds for total real functions; physical use still needs E,eta>0. -/
theorem relaxation_hasDerivAt (E eta stress0 t : ℝ) :
    HasDerivAt (relaxation E eta stress0)
      (maxwellStressRate E eta (relaxation E eta stress0 t) 0) t := by
  have hd := (((hasDerivAt_id t).const_mul (-(E / eta))).exp).const_mul stress0
  convert hd using 1
  · rfl
  · dsimp [maxwellStressRate, relaxation]
    ring

/-- For positive parameters and nonnegative post-loading stress, relaxation
stays between zero and the initial stress at nonnegative elapsed times. -/
theorem relaxation_bounds {E eta stress0 t : ℝ} (hE : 0 < E) (hEta : 0 < eta)
    (hStress : 0 ≤ stress0) (ht : 0 ≤ t) :
    0 ≤ relaxation E eta stress0 t ∧ relaxation E eta stress0 t ≤ stress0 := by
  have he : Real.exp (-(E / eta) * t) ≤ 1 :=
    Real.exp_le_one_iff.mpr (mul_nonpos_of_nonpos_of_nonneg
      (neg_nonpos.mpr (le_of_lt (div_pos hE hEta))) ht)
  exact ⟨mul_nonneg hStress (le_of_lt (Real.exp_pos _)),
    (mul_le_mul_of_nonneg_left he hStress).trans_eq (mul_one stress0)⟩

/-- Kelvin-Voigt creep under constant applied stress, starting at zero strain. -/
noncomputable def kelvinCreep (E eta stress0 t : ℝ) : ℝ :=
  stress0 / E * (1 - Real.exp (-(E / eta) * t))

/-- Creep starts at zero strain; no instantaneous jump is supplied by this element. -/
theorem kelvinCreep_initial (E eta stress0 : ℝ) : kelvinCreep E eta stress0 0 = 0 := by
  simp [kelvinCreep]

/-- Derivative of the constant-stress creep solution for positive parameters. -/
theorem kelvinCreep_hasDerivAt {E eta : ℝ} (hE : 0 < E) (hEta : 0 < eta)
    (stress0 t : ℝ) :
    HasDerivAt (kelvinCreep E eta stress0)
      (stress0 / eta * Real.exp (-(E / eta) * t)) t := by
  have hExp := ((hasDerivAt_id t).const_mul (-(E / eta))).exp
  have hd := (hExp.const_sub 1).const_mul (stress0 / E)
  convert hd using 1
  · rfl
  · dsimp
    field_simp

/-- The creep curve and its computed rate satisfy the applied-stress equation. -/
theorem kelvinCreep_balance {E eta : ℝ} (hE : 0 < E) (hEta : 0 < eta)
    (stress0 t : ℝ) :
    kelvinVoigtStress E eta (kelvinCreep E eta stress0 t)
      (stress0 / eta * Real.exp (-(E / eta) * t)) = stress0 := by
  dsimp [kelvinVoigtStress, springStress, dashpotStress, kelvinCreep]
  field_simp; ring

end CardioLean.Mechanics.LinearViscoelastic
