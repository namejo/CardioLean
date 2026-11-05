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
