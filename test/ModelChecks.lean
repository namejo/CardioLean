module

import CardioLean
import Mathlib.Tactic.NormNum

/-!
API and assumption checks, executed separately by CI. The examples exercise
published results and excluded parameter regimes. They add no scientific data.
-/

open CardioLean.Circulation.Windkessel

-- Check that the root import exposes the Hill bounds with their exact hypotheses.
example {F₀ a b F : ℝ} (ha : 0 < a) (hb : 0 ≤ b) (hF : 0 ≤ F)
    (hFF₀ : F ≤ F₀) :
    0 ≤ CardioLean.Contraction.Hill.velocity F₀ a b F ∧
      CardioLean.Contraction.Hill.velocity F₀ a b F ≤ b * F₀ / a :=
  CardioLean.Contraction.Hill.velocity_bounds ha hb hF hFF₀

-- A closed-form curve actually satisfies the balance, not just its initial value.
example (t : ℝ) : SatisfiesBalanceAt 1 2 5 (fun _ => 0) (decay 1 2 5 10) t := by
  exact decay_satisfies_zeroInflow (by norm_num) (by norm_num) 5 10 t

-- Pressure-only data cannot distinguish two positive pairs having the same RC.
example : decay 1 1 0 1 = decay 2 (1 / 2) 0 1 := by
  apply decay_eq_of_product_eq
  norm_num

-- C = 0 can make the flow balance impossible; it cannot be silently allowed.
example : ¬ SatisfiesBalanceAt 1 0 0 (fun _ => 0) (fun _ => 1) 0 := by
  rintro ⟨rate, _, hbalance⟩
  norm_num [outflow] at hbalance

-- Negative compliance can produce growth: positivity assumptions have content.
example : 1 < decay 1 (-1) 0 1 1 := by
  norm_num [decay]

-- Constant nonzero input must satisfy the same balance with that actual input.
example (t : ℝ) :
    SatisfiesBalanceAt 2 (1 / 2) 5 (fun _ => 5) (constantPressure 2 (1 / 2) 5 5 10) t := by
  exact constantPressure_satisfies_balance (by norm_num) (by norm_num) 5 5 10 t

-- Uniqueness is local to the observed interval; no global solution is assumed.
example {p : ℝ → ℝ} {t : ℝ} (ht : 0 ≤ t)
    (hp : ∀ s ∈ Set.Icc 0 t, SatisfiesBalanceAt 2 (1 / 2) 5 (fun _ => 5) p s)
    (hInit : p 0 = 10) : p t = constantPressure 2 (1 / 2) 5 5 10 t := by
  exact constantPressure_unique (by norm_num) (by norm_num) ht hp hInit

-- The rising case is bounded by the initial value and the new equilibrium 15.
example {t : ℝ} (ht : 0 ≤ t) :
    10 ≤ constantPressure 2 (1 / 2) 5 5 10 t ∧
    constantPressure 2 (1 / 2) 5 5 10 t ≤ 15 := by
  have h := constantPressure_bounds (R := 2) (C := 1 / 2) (pOut := 5)
    (q := 5) (pInit := 10) (by norm_num) (by norm_num) ht
  norm_num [equilibriumPressure] at h
  exact h

-- The previous zero-input model remains an exact specialization.
example : constantPressure 2 (1 / 2) 5 0 10 = decay 2 (1 / 2) 5 10 :=
  constantPressure_zero 2 (1 / 2) 5 10

-- Passive mechanics: energy dissipation must not be assumed for negative viscosity.
example : ¬ (0 ≤ CardioLean.Mechanics.LinearViscoelastic.dashpotStress (-1) 1 * 1) := by
  norm_num [CardioLean.Mechanics.LinearViscoelastic.dashpotStress]

-- Source audit: one pointwise tuple satisfies all supplied branch/rate relations,
-- but distinguishes the network-derived coefficient from the displayed Eq.(4).
-- All parameters are positive; this is an algebraic check, not a fitted experiment.
example :
    CardioLean.Mechanics.LinearViscoelastic.parallelStress 1 1 0 1 0 = 1 ∧
    CardioLean.Mechanics.LinearViscoelastic.maxwellStressRate 1 2 0 1 = 1 ∧
    (2 : ℝ) = 1 * 1 + 1 * 0 + 1 ∧
    (1 : ℝ) * 2 * 0 + (1 * 2 + 1 * 2 + 1 * 1) * 1 + 1 * 1 * 0 = 1 * 1 + 2 * 2 ∧
    (1 : ℝ) * 2 * 0 + (1 * 2 + 1 * 1 + 1 * 1) * 1 + 1 * 1 * 0 ≠ 1 * 1 + 2 * 2 := by
  norm_num [CardioLean.Mechanics.LinearViscoelastic.parallelStress,
    CardioLean.Mechanics.LinearViscoelastic.kelvinVoigtStress,
    CardioLean.Mechanics.LinearViscoelastic.springStress,
    CardioLean.Mechanics.LinearViscoelastic.dashpotStress,
    CardioLean.Mechanics.LinearViscoelastic.maxwellStressRate]
