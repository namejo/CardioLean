# 001 — Getting started

*Initial setup notes, 2026-11-05. This entry records repository work and questions to investigate. It is a draft learning scaffold, not a claim that I have already read every source or understood every concept below.*

## What I want this project to become

I want to learn the mathematics behind cardiac physiology and how to express precise mathematical claims in Lean 4. I am not a trained mathematician. I want this journal to keep the sources, assumptions, incomplete work, and corrections visible alongside the code.

The long-term topics include electrical activity, calcium handling, contraction, heart mechanics, and circulation. My immediate goal is much smaller: one understandable equation, explicit assumptions, and proofs that can actually be checked.

## Notes based on the setup work

The project is organized around those topics under `CardioLean/`. `CardioLean.lean` imports the modules as the library entry point. The future modules explain their intended roles without inventing definitions. The first mathematical implementation belongs in `CardioLean/Contraction/Hill.lean`.

Lean 4 was chosen because it can check whether a formal proof establishes its stated mathematical conclusion. Mathlib supplies real numbers, algebra, inequalities, and proof tools, so this project can build on existing mathematics. Lake manages the pinned dependencies and compilation. GitHub Actions provides a repeatable place to run compilation when changes are pushed.

The concrete build result is recorded in [README.md](../README.md). A workflow file by itself is not evidence that a hosted CI run has passed.

## The first equation and its assumptions

The Hill force-velocity relationship is

$$
(F+a)(v+b)=(F_0+a)b.
$$

Expanding and subtracting terms gives

$$
(F+a)v=b(F_0-F).
$$

If `F + a ≠ 0`, dividing by `F + a` gives

$$
v(F)=\frac{b(F_0-F)}{F+a}.
$$

In this notation, `F` is force and `F₀` is interpreted as maximum isometric force for the selected model conditions. Velocity is positive for shortening. `a` has force units and `b` has velocity units. The initial Lean function uses real-number values expressed in compatible fixed units; it does not enforce physical dimensions.

The intended shortening range is `a > 0`, `b ≥ 0`, and `0 ≤ F ≤ F₀`. The force interval implies `F₀ ≥ 0`; a positive-width force interval and strict decrease would additionally require `F₀ > 0` and `b > 0`. These choices need scientific interpretation as well as mathematical bookkeeping. They are not conclusions established about real tissue by Lean.

The domain restrictions do several jobs:

- `a > 0` and `F ≥ 0` make `F + a` strictly positive, so division and inequality comparisons are justified.
- `F ≤ F₀` makes `F₀ - F` nonnegative; with `b ≥ 0`, this makes the velocity nonnegative.
- At `F = F₀`, the numerator is zero, giving zero shortening velocity.
- Comparing velocities at two forces requires controlling both denominators. Strict decrease needs additional positivity, including `b > 0`; if `b = 0`, every velocity in the intended range is zero.

Lean defines real division even when the denominator is zero. That convention does not give a physical interpretation to the singular case. The algebraic equivalence with the original equation needs the explicit nonzero-denominator hypothesis.

## Concepts to investigate in the proofs

The setup introduces functions of real variables, universal statements, hypotheses, inequalities, and equivalence between two forms of an equation. A proof of nonnegativity combines known signs of factors and a denominator. The endpoint calculation substitutes one force value. Monotonicity means that for any two admissible forces `F₁ ≤ F₂`, the corresponding velocities satisfy `v(F₂) ≤ v(F₁)`.

For an informal way to see the comparison, put the two fractions over their positive common denominator. The difference in velocities is

$$
v(F_1)-v(F_2)=
\frac{b(F_0+a)(F_2-F_1)}{(F_1+a)(F_2+a)}.
$$

The right-hand side is nonnegative under the stated range assumptions. This explanation is a guide to the mathematics; the exact machine-checked claim and proof strategy are in the Lean source, and build status is recorded separately.

I want to learn how Lean proof steps correspond to these paper calculations. In particular: how does Lean represent an assumption, why must a denominator's sign be proved, and how do algebra tactics produce proof terms? The implementation comments are a starting point for those questions.

## Questions I should investigate myself

- What preparation and measurement conditions did Hill study, and how do they differ from cardiac muscle? The original work concerns skeletal muscle; it is not evidence that this equation is a complete heart-contraction model.
- Which assumptions are needed by each theorem, and which are additional choices for a biological interpretation?
- How do force, stress, muscle length, and sarcomere length relate? What would change if force or velocity were normalized?
- What exactly do Lean's conventions for division mean at zero, and why should a physical domain exclude that point?
- What would count as evidence that a parameter choice describes a particular experimental preparation?
- How can I inspect a formal theorem and understand precisely what it does and does not say?

## What I should learn next

1. Work through real-number inequalities and rearranging fractions with nonzero or positive denominators.
2. Read the Hill source with the equation and experimental context in mind; record questions rather than assuming it transfers directly to the heart.
3. Walk through the Lean definition and proofs one line at a time, then try a small variation of a hypothesis and examine what breaks.

Mathematical proof and experimental validation answer different questions. A proof can establish a property of a chosen equation under explicit assumptions. It cannot establish by itself that the equation describes living heart tissue. I want future entries and corrections to keep that distinction visible.

Sources and further documentation: [REFERENCES.md](../REFERENCES.md), [model template](../docs/MODEL_TEMPLATE.md), and [roadmap](../ROADMAP.md).
