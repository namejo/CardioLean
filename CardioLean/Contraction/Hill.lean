module

public import Mathlib.Basic.Real.Basic
public import Mathlib.Algebra.Order.Field.Basic
public import Mathlib.Order.Monotone.Defs
import Mathlib.Tactic.Linarith

/-!
# Hill force–velocity relationship

Scientific source: A. V. Hill (1938), *The heat of shortening and the dynamic
constants of muscle*, Proc. R. Soc. Lond. B 126(843), 136–195,
DOI: 10.1098/rspb.1938.0050, printed p. 161, equations (1)–(2).
Hill writes P and P₀ where this file uses F and F₀.

This is an algebra exercise based on a skeletal-muscle relationship, not a
validated cardiac model. Positive velocity means shortening. We hold F₀, a, b
fixed while varying force F. Use compatible fixed units: F, F₀, a in force
units (e.g. N); v, b in velocity units (e.g. m/s). Units are documented, not
encoded in the real-number types.

The shortening domain used here is 0 ≤ F ≤ F₀, with a > 0 and b ≥ 0.
Strict decrease additionally uses b > 0. These are explicit mathematical
assumptions for this exercise; their physiological applicability is not proved.
Lean's real division is total, including division by zero. Theorems connecting
the quotient to the original equation therefore require a nonzero denominator.

See `docs/models/Hill.md` for the formulation, assumptions, proof obligations,
verification record, and limitations. No other contraction models are implemented.
-/

@[expose] public section

namespace CardioLean.Contraction.Hill

/-- Shortening velocity `b * (F₀ - F) / (F + a)`.

This definition is a total real function. Its intended physical interpretation
requires the documented domain assumptions; evaluation at `F = -a` does not
represent a solution obtained by dividing the original equation.
-/
noncomputable def velocity (F₀ a b F : ℝ) : ℝ :=
  b * (F₀ - F) / (F + a)

/-- A positive force offset and a nonnegative force make division legitimate. -/
theorem denominator_pos {a F : ℝ} (ha : 0 < a) (hF : 0 ≤ F) :
    0 < F + a := by
  -- `linarith` combines the two linear inequalities.
  linarith

/-- The quotient is exactly the rearranged Hill equation when `F + a ≠ 0`. -/
theorem equation_iff_velocity {F₀ a b F v : ℝ} (hden : F + a ≠ 0) :
    (F + a) * (v + b) = (F₀ + a) * b ↔ v = velocity F₀ a b F := by
  unfold velocity
  -- `eq_div_iff` multiplies by a NONZERO denominator (no sign assumption needed).
  rw [eq_div_iff hden]
  -- Expand products and cancel terms; `nlinarith` checks the polynomial algebra.
  constructor <;> intro h <;> nlinarith [h]

/-- On the shortening domain the numerator is nonnegative and denominator positive. -/
theorem velocity_nonneg {F₀ a b F : ℝ} (ha : 0 < a) (hb : 0 ≤ b)
    (hF : 0 ≤ F) (hFF₀ : F ≤ F₀) :
    0 ≤ velocity F₀ a b F := by
  unfold velocity
  -- F ≤ F₀ gives F₀ - F ≥ 0. Products and quotients preserve these signs.
  exact div_nonneg (mul_nonneg hb (sub_nonneg.mpr hFF₀))
    (le_of_lt (denominator_pos ha hF))

/-- At the isometric force the numerator is zero.

This algebraic identity needs no sign assumptions. For the original equation's
physical interpretation still require `F₀ + a ≠ 0`, e.g. `a > 0`, `F₀ ≥ 0`.
-/
theorem velocity_at_isometric (F₀ a b : ℝ) :
    velocity F₀ a b F₀ = 0 := by
  -- `simp` uses F₀ - F₀ = 0, b * 0 = 0, and 0 / x = 0.
  simp [velocity]

/-- Increasing force cannot increase shortening velocity on `[0, F₀]`.

`AntitoneOn` means: if F₁ ≤ F₂ and both belong to this interval,
then velocity(F₂) ≤ velocity(F₁). The case b = 0 is allowed.
-/
theorem velocity_antitoneOn {F₀ a b : ℝ} (ha : 0 < a) (hb : 0 ≤ b)
    (hF₀ : 0 ≤ F₀) :
    AntitoneOn (velocity F₀ a b) (Set.Icc 0 F₀) := by
  intro F₁ hF₁ F₂ hF₂ hle
  unfold velocity
  -- Positive denominators let us compare fractions by cross multiplication.
  apply (div_le_div_iff₀ (denominator_pos ha hF₂.1)
    (denominator_pos ha hF₁.1)).2
  -- Right cross-product minus left cross-product factors as
  -- b * (F₀ + a) * (F₂ - F₁), a product of nonnegative factors.
  have hsum : 0 ≤ F₀ + a := by linarith
  have hprod : 0 ≤ b * (F₀ + a) * (F₂ - F₁) :=
    mul_nonneg (mul_nonneg hb hsum) (sub_nonneg.mpr hle)
  nlinarith only [hprod]

/-- If b is strictly positive, larger forces give strictly smaller velocities. -/
theorem velocity_strictAntiOn {F₀ a b : ℝ} (ha : 0 < a) (hb : 0 < b)
    (hF₀ : 0 ≤ F₀) :
    StrictAntiOn (velocity F₀ a b) (Set.Icc 0 F₀) := by
  intro F₁ hF₁ F₂ hF₂ hlt
  unfold velocity
  apply (div_lt_div_iff₀ (denominator_pos ha hF₂.1)
    (denominator_pos ha hF₁.1)).2
  -- With b > 0 and F₂ > F₁, every factor in the same difference is positive.
  have hsum : 0 < F₀ + a := by linarith
  have hprod : 0 < b * (F₀ + a) * (F₂ - F₁) :=
    mul_pos (mul_pos hb hsum) (sub_pos.mpr hlt)
  nlinarith only [hprod]

/-- Zero-load velocity of the quotient. Physical interpretation uses a > 0.
This is a project derivation from Hill (1938), not a separately quoted result. -/
theorem velocity_at_zero (F₀ a b : ℝ) :
    velocity F₀ a b 0 = b * F₀ / a := by
  simp [velocity]

/-- On the shortening interval, velocity lies between zero and its zero-load value.

This completes the chapter's bound exercise by reusing the general comparison
proof, rather than repeating cross multiplication. -/
theorem velocity_bounds {F₀ a b F : ℝ} (ha : 0 < a) (hb : 0 ≤ b)
    (hF : 0 ≤ F) (hFF₀ : F ≤ F₀) :
    0 ≤ velocity F₀ a b F ∧ velocity F₀ a b F ≤ b * F₀ / a := by
  refine ⟨velocity_nonneg ha hb hF hFF₀, ?_⟩
  have hF₀ : 0 ≤ F₀ := hF.trans hFF₀
  have h := velocity_antitoneOn ha hb hF₀ ⟨le_rfl, hF₀⟩ ⟨hF, hFF₀⟩ hF
  simpa only [velocity_at_zero] using h

end CardioLean.Contraction.Hill
