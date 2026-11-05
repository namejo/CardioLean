# 003 — From a force–velocity curve to a first circulation component

*Repository-work record and study prompts, 2026-11-05. This entry does not claim
that I have personally read the papers or mastered the mathematics below.*

## Completed work available to study

The Hill zero-load and bound exercises now have checked proofs. The
[research tree](../docs/research/001-next-directions.md) compares circulation,
calcium, and ventricular-mechanics directions. It selects a small zero-inflow
Windkessel model as a first differential-equation example.

[The new chapter](../docs/models/Windkessel.md) documents the source equations,
fixed-parameter assumptions, units, and Lean correspondence. The Lean proofs
verify the explicit pressure function, rather than assuming a plotted curve
is a solution. The notebook explores pressure-only parameter ambiguity and
shows a numerical approximation crossing below a bound satisfied by the exact curve.

## Questions I want to investigate

- Can I explain why a function must satisfy both the derivative equation and its initial condition?
- Why does a nonzero reference pressure matter? Why is it the pressure difference that falls to exp(-1) after one RC time?
- How can two different R,C pairs produce exactly the same pressure curve, and what extra measurements would distinguish them?
- What would a uniqueness theorem add beyond checking this candidate?
- Why can a numerical time step violate a physical-domain bound even when the continuous model preserves it?
- Which additional geometry and volume equations would connect muscle shortening to ventricular flow?

## My own reading and corrections

Space for dated derivations, reading notes, failed attempts, and questions.
[The source map](../docs/SOURCE_MAP.md) distinguishes paper equations from the
project's derived lemmas. A successful Lean proof does not answer whether this
model adequately represents an experiment or a human heart.
