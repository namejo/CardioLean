module

public import Mathlib.Analysis.SpecialFunctions.ExpDeriv
public import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

/-!
# Two-element Windkessel: zero-inflow relaxation

Sources: Wang et al. (2003), DOI 10.1152/ajpheart.00175.2002,
Methods / Theory / Windkessel theory, p. H1359, equations (1)-(3);
J. Alastruey (2010), DOI 10.1007/s10558-010-9109-9,
Methodology / Reservoir-Excess Separation, equations (1) and (2).
The source balance is q_IN = C_T * dp_w/dt + (p_w - P_out)/R_T.
We select q_IN identically zero, shift the initial time to zero, and keep
R, C, and pOut constant. This is one explicit solution, not the full paper.

Use R > 0, C > 0, pInit ≥ pOut and elapsed time t ≥ 0 for the intended regime.
pOut is a chosen constant outflow reference; it is not silently set to zero
or identified with measured venous pressure. Units: t in s, pressure in mmHg,
flow in mL/s, R in mmHg*s/mL, C in mL/mmHg; R*C is a time.
Units are documented conventions, not enforced by real-number types.

See docs/models/Windkessel.md and docs/SOURCE_MAP.md for exact source mappings,
proof status, explicit assumptions, and missing physiological validation.
-/

@[expose] public section

namespace CardioLean.Circulation.Windkessel

/-- Resistive outflow relative to a fixed pressure reference. Requires R ≠ 0
for its intended interpretation; Lean division itself is total. -/
noncomputable def outflow (R pOut pressure : ℝ) : ℝ :=
  (pressure - pOut) / R

/-- Equation (1) at a time t, with differentiability explicitly witnessed.

Using `HasDerivAt` avoids interpreting Lean's default `deriv` value at a
nondifferentiable point as a physical rate. The balance states that inflow is
storage rate plus resistive outflow. No existence or uniqueness is asserted.
-/
def SatisfiesBalanceAt (R C pOut : ℝ) (inflow pressure : ℝ → ℝ) (t : ℝ) : Prop :=
  ∃ rate : ℝ, HasDerivAt pressure rate t ∧
    inflow t = C * rate + outflow R pOut (pressure t)

/-- Equation (2) specialized to zero inflow and initial time zero.

The function is defined for every real input, including nonphysical parameters.
The derivative theorem is algebraic; the balance and bounds impose their own
hypotheses. This smooth extension to negative time is not a past physiological model.
-/
noncomputable def decay (R C pOut pInit t : ℝ) : ℝ :=
  pOut + (pInit - pOut) * Real.exp (-t / (R * C))

/-- The closed form attains its specified initial pressure. -/
theorem decay_initial (R C pOut pInit : ℝ) :
    decay R C pOut pInit 0 = pInit := by
  simp [decay]

/-- Differentiate the explicit curve using the exponential chain rule.

No sign assumption is needed for this identity of total real functions.
In particular it alone does not validate zero resistance or compliance.
-/
theorem decay_hasDerivAt (R C pOut pInit t : ℝ) :
    HasDerivAt (decay R C pOut pInit)
      (-(decay R C pOut pInit t - pOut) / (R * C)) t := by
  have h := (((hasDerivAt_id t).neg.div_const (R * C)).exp.const_mul
    (pInit - pOut)).const_add pOut
  -- The chain rule supplies the derivative; ring checks its rearrangement.
  convert h using 1
  · rfl
  · dsimp [decay]
    ring

/-- For positive R and C the curve satisfies the actual zero-inflow balance. -/
theorem decay_satisfies_zeroInflow {R C : ℝ} (hR : 0 < R) (hC : 0 < C)
    (pOut pInit t : ℝ) :
    SatisfiesBalanceAt R C pOut (fun _ => 0) (decay R C pOut pInit) t := by
  refine ⟨-(decay R C pOut pInit t - pOut) / (R * C),
    decay_hasDerivAt R C pOut pInit t, ?_⟩
  -- Substitute the derivative into q = C*p' + (p-pOut)/R and cancel.
  dsimp [outflow]
  field_simp; ring

/-- A nonnegative initial pressure difference remains nonnegative. -/
theorem decay_ge_out {R C pOut pInit t : ℝ} (hInit : pOut ≤ pInit) :
    pOut ≤ decay R C pOut pInit t := by
  have h := mul_nonneg (sub_nonneg.mpr hInit)
    (le_of_lt (Real.exp_pos (-t / (R * C))))
  dsimp [decay]
  linarith

/-- At nonnegative elapsed times pressure cannot exceed its initial value. -/
theorem decay_le_initial {R C pOut pInit t : ℝ} (hR : 0 < R) (hC : 0 < C)
    (hInit : pOut ≤ pInit) (ht : 0 ≤ t) :
    decay R C pOut pInit t ≤ pInit := by
  have hexp : Real.exp (-t / (R * C)) ≤ 1 :=
    Real.exp_le_one_iff.mpr (div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr ht)
      (le_of_lt (mul_pos hR hC)))
  have h := mul_le_mul_of_nonneg_left hexp (sub_nonneg.mpr hInit)
  dsimp [decay]
  linarith

/-- With initial pressure at least pOut, the curve is nonincreasing in time. -/
theorem decay_antitone {R C pOut pInit : ℝ} (hR : 0 < R) (hC : 0 < C)
    (hInit : pOut ≤ pInit) : Antitone (decay R C pOut pInit) := by
  intro s t hst
  have harg : -t / (R * C) ≤ -s / (R * C) :=
    div_le_div_of_nonneg_right (neg_le_neg hst) (le_of_lt (mul_pos hR hC))
  have h := mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr harg)
    (sub_nonneg.mpr hInit)
  dsimp [decay]
  linarith

/-- Positive resistance and pressure above the reference give nonnegative outflow. -/
theorem outflow_nonneg {R pOut pressure : ℝ} (hR : 0 < R)
    (hp : pOut ≤ pressure) : 0 ≤ outflow R pOut pressure := by
  exact div_nonneg (sub_nonneg.mpr hp) (le_of_lt hR)

/-- After one RC time, the excess pressure is its initial value times exp(-1). -/
theorem decay_at_timeConstant {R C : ℝ} (hR : 0 < R) (hC : 0 < C)
    (pOut pInit : ℝ) :
    decay R C pOut pInit (R * C) = pOut + (pInit - pOut) * Real.exp (-1) := by
  have hRC : R * C ≠ 0 := ne_of_gt (mul_pos hR hC)
  simp [decay, hRC]

/-- Equal RC products give identical pressure curves for the same initial/reference
pressures. This project derivation exposes a parameter-estimation limitation:
zero-inflow pressure alone cannot distinguish these pairs of parameters. -/
theorem decay_eq_of_product_eq {R₁ C₁ R₂ C₂ : ℝ} (hRC : R₁ * C₁ = R₂ * C₂)
    (pOut pInit : ℝ) :
    decay R₁ C₁ pOut pInit = decay R₂ C₂ pOut pInit := by
  funext t
  simp only [decay, hRC]

end CardioLean.Circulation.Windkessel
