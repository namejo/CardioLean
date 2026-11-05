module

public import CardioLean.Circulation.Windkessel
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

/-!
# Constant inflow and conditional uniqueness for the two-element Windkessel

Sources: Wang et al. (2003), DOI 10.1152/ajpheart.00175.2002, p. H1359,
equations (1)-(3); Alastruey (2010), DOI 10.1007/s10558-010-9109-9,
equations (1)-(2). We specialize the source balance to constant inflow q.
The equilibrium and uniqueness lemmas are project derivations from that equation.

R and C are positive constants for the intended regime. q is in mL/s;
pOut + R*q has pressure units. Nonnegative inflow is an additional biological
regime choice, not needed for every algebraic theorem below. A constant input
is not a pulsatile heartbeat or a valve model. See docs/models/WindkesselConstant.md
and docs/SOURCE_MAP.md for assumptions, equation mappings, and proof status.
-/

@[expose] public section

namespace CardioLean.Circulation.Windkessel

/-- Pressure at which resistive outflow balances constant inflow q. -/
noncomputable def equilibriumPressure (R pOut q : ℝ) : ℝ := pOut + R * q

/-- Constant-input solution, expressed using the existing exponential curve with
its reference shifted to the equilibrium pressure. This reuses the verified
calculus rather than duplicating the exponential construction. -/
noncomputable def constantPressure (R C pOut q pInit t : ℝ) : ℝ :=
  decay R C (equilibriumPressure R pOut q) pInit t

/-- The constant-input curve has the chosen initial pressure. -/
theorem constantPressure_initial (R C pOut q pInit : ℝ) :
    constantPressure R C pOut q pInit 0 = pInit := by
  exact decay_initial R C (equilibriumPressure R pOut q) pInit

/-- Zero input recovers the previous model exactly. -/
theorem constantPressure_zero (R C pOut pInit : ℝ) :
    constantPressure R C pOut 0 pInit = decay R C pOut pInit := by
  funext t
  simp [constantPressure, equilibriumPressure]

/-- At equilibrium, resistive outflow equals the prescribed inflow. -/
theorem outflow_at_equilibrium {R : ℝ} (hR : 0 < R) (pOut q : ℝ) :
    outflow R pOut (equilibriumPressure R pOut q) = q := by
  dsimp [outflow, equilibriumPressure]
  field_simp; ring

/-- The constant-input closed form satisfies the source flow balance. -/
theorem constantPressure_satisfies_balance {R C : ℝ} (hR : 0 < R) (hC : 0 < C)
    (pOut q pInit t : ℝ) :
    SatisfiesBalanceAt R C pOut (fun _ => q) (constantPressure R C pOut q pInit) t := by
  refine ⟨-(constantPressure R C pOut q pInit t - equilibriumPressure R pOut q) /
    (R * C), decay_hasDerivAt R C (equilibriumPressure R pOut q) pInit t, ?_⟩
  dsimp [outflow, equilibriumPressure]
  field_simp; ring

/-- For elapsed time at least zero, pressure lies between its initial value and
its equilibrium. This includes both rising and falling curves, and signed q. -/
theorem constantPressure_bounds {R C pOut q pInit t : ℝ} (hR : 0 < R)
    (hC : 0 < C) (ht : 0 ≤ t) :
    min pInit (equilibriumPressure R pOut q) ≤ constantPressure R C pOut q pInit t ∧
    constantPressure R C pOut q pInit t ≤ max pInit (equilibriumPressure R pOut q) := by
  by_cases hInit : pInit ≤ equilibriumPressure R pOut q
  · have he : Real.exp (-t / (R * C)) ≤ 1 :=
      Real.exp_le_one_iff.mpr (div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr ht)
        (le_of_lt (mul_pos hR hC)))
    have hlow := mul_le_mul_of_nonpos_left he (sub_nonpos.mpr hInit)
    have hupp := mul_nonpos_of_nonpos_of_nonneg (sub_nonpos.mpr hInit)
      (le_of_lt (Real.exp_pos (-t / (R * C))))
    simp only [min_eq_left hInit, max_eq_right hInit]
    dsimp [constantPressure, decay]
    constructor <;> linarith
  · have hInit' : equilibriumPressure R pOut q ≤ pInit := le_of_not_ge hInit
    simpa only [constantPressure, min_eq_right hInit', max_eq_left hInit'] using
      And.intro (decay_ge_out (R := R) (C := C) (t := t) hInit')
        (decay_le_initial hR hC hInit' ht)

/-- If initial pressure is above equilibrium, pressure is nonincreasing. -/
theorem constantPressure_antitone {R C pOut q pInit : ℝ} (hR : 0 < R)
    (hC : 0 < C) (hInit : equilibriumPressure R pOut q ≤ pInit) :
    Antitone (constantPressure R C pOut q pInit) :=
  decay_antitone hR hC hInit

/-- If initial pressure is below equilibrium, pressure is nondecreasing. -/
theorem constantPressure_monotone {R C pOut q pInit : ℝ} (hR : 0 < R)
    (hC : 0 < C) (hInit : pInit ≤ equilibriumPressure R pOut q) :
    Monotone (constantPressure R C pOut q pInit) := by
  intro s t hst
  have he := Real.exp_le_exp.mpr
    (div_le_div_of_nonneg_right (neg_le_neg hst) (le_of_lt (mul_pos hR hC)))
  have h := mul_le_mul_of_nonpos_left he (sub_nonpos.mpr hInit)
  dsimp [constantPressure, decay]
  linarith

/-- Two differentiable solutions of the same balance, with the same input and
initial pressure, agree at a nonnegative time t if both satisfy the balance on
[0,t]. This is conditional uniqueness, even for a nonconstant input. It does
not assert existence for arbitrary input, or handle discontinuous valve switching.
Ordinary derivatives are required at every point, including interval endpoints.
-/
theorem solutions_unique {R C pOut t : ℝ} {inflow p g : ℝ → ℝ}
    (hR : 0 < R) (hC : 0 < C) (ht : 0 ≤ t)
    (hp : ∀ s ∈ Set.Icc 0 t, SatisfiesBalanceAt R C pOut inflow p s)
    (hg : ∀ s ∈ Set.Icc 0 t, SatisfiesBalanceAt R C pOut inflow g s)
    (hInit : p 0 = g 0) : p t = g t := by
  -- Difference of solutions times exp(s/(RC)) has derivative zero: the input cancels.
  let w : ℝ → ℝ := fun s => (p s - g s) * Real.exp (s / (R * C))
  have hw : ∀ s ∈ Set.Icc 0 t, HasDerivAt w 0 s := by
    intro s hs
    obtain ⟨u, hu, hbu⟩ := hp s hs
    obtain ⟨v, hv, hbv⟩ := hg s hs
    have hrate : (u - v) * (R * C) = -(p s - g s) := by
      dsimp [outflow] at hbu hbv
      field_simp at hbu hbv
      nlinarith only [hbu, hbv]
    have hscaled := congrArg (fun z : ℝ => z * Real.exp (s / (R * C))) hrate
    have hd := (hu.sub hv).mul (((hasDerivAt_id s).div_const (R * C)).exp)
    convert hd using 1
    · rfl
    · dsimp
      field_simp
      nlinarith only [hscaled]
  -- The mean-value theorem makes a continuous function with zero derivative constant.
  have hwcont : ContinuousOn w (Set.Icc 0 t) :=
    fun s hs => (hw s hs).continuousAt.continuousWithinAt
  have hconst := constant_of_has_deriv_right_zero hwcont
    (fun s hs => (hw s ⟨hs.1, le_of_lt hs.2⟩).hasDerivWithinAt) t ⟨ht, le_rfl⟩
  have hzero : (p t - g t) * Real.exp (t / (R * C)) = 0 := by
    simpa [w, hInit] using hconst
  exact sub_eq_zero.mp ((mul_eq_zero.mp hzero).resolve_right (Real.exp_ne_zero _))

/-- Every differentiable solution of the constant-input balance with this initial
value agrees with the explicit curve on the observed nonnegative time interval. -/
theorem constantPressure_unique {R C pOut q pInit t : ℝ} {p : ℝ → ℝ}
    (hR : 0 < R) (hC : 0 < C) (ht : 0 ≤ t)
    (hp : ∀ s ∈ Set.Icc 0 t, SatisfiesBalanceAt R C pOut (fun _ => q) p s)
    (hInit : p 0 = pInit) : p t = constantPressure R C pOut q pInit t := by
  apply solutions_unique hR hC ht hp
    (fun s _ => constantPressure_satisfies_balance hR hC pOut q pInit s)
  simpa only [constantPressure_initial] using hInit

end CardioLean.Circulation.Windkessel
