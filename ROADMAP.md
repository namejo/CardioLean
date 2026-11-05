# Roadmap

CardioLean should grow through small examples whose assumptions, sources, and proof status are understandable. This is a sequence of learning milestones, not a claim that complete cardiac formalization is within reach.

## Milestone 1 — A working foundation and the Hill example

- Pin a compatible Lean 4 toolchain and Mathlib dependency; build with Lake and add compilation CI.
- Preserve the personal introduction and establish the learning journal, contribution guidance, bibliography, and model template.
- Create the planned module tree with honest descriptions of unimplemented work.
- Define Hill shortening velocity over the real numbers with explicit units and domain assumptions in documentation.
- Check the rearrangement, nonnegativity, isometric endpoint, and monotonicity proofs in Lean.
- Explain the algebra and tactics, inspect the build result, and record what remains unreviewed.
- Investigate basic foundations before implementing them: positive quantities, dimensional consistency, functions, and inequalities.

See [README.md](README.md) for the current setup verification record and [Hill.lean](CardioLean/Contraction/Hill.lean) for exact theorem statements. A completed proof is not a validation of the model for heart muscle.

## Milestone 2 — Review and strengthen one small model

- Obtain mathematical review of the Hill statements and assumptions.
- Read the original Hill paper and document how its experimental context differs from cardiac contraction.
- Study boundary cases, strict versus weak monotonicity, and the role of positive denominators.
- Decide whether a small units representation or a parameter structure would clarify the work; introduce either only when there is a concrete benefit.
- Add journal notes and corrections grounded in completed work and the author's own questions.

## Milestone 3 — Learn differential equations and conservation

- Study derivatives and what it means for a function to solve an ordinary differential equation.
- Select one elementary, scientifically sourced example with a clear domain and units.
- Formalize a conservation or balance statement only after specifying what is conserved and which exchanges are included.
- Separate definitions, existence or uniqueness questions, and properties of particular solutions.

## Milestone 4 — Add one physiology topic at a time

- Choose an introductory electrophysiology, calcium, or circulation relationship after reviewing original literature.
- Write the model documentation before expanding the Lean implementation.
- State the biological setting, units, mathematical assumptions, and a small set of feasible proof obligations.
- Obtain scientific feedback on the interpretation and mathematical feedback on the formal statements.

The module names reserve space for these topics; they do not assert that their equations or assumptions have been chosen.

## Milestone 5 — Consider coupled models after the prerequisites

Rice2008, Land2017, cross-bridge dynamics, ventricular mechanics, and coupled heart models remain future work. Before implementing any of them, establish the underlying equations, source traceability, unit conventions, and tractable proof goals. O'Hara–Rudy and other complex cell models are outside the initial setup.

Experimental comparison, numerical simulation, mathematical proof, and independent review should continue to have separate records throughout these milestones.

## Progress after the initial setup — 2026-11-05

The Hill zero-load velocity and bounds exercises are now checked. The first
dynamic component is a zero-inflow two-element Windkessel with verified
derivative, balance, initial value, bounds, nonincrease, time constant, and
same-RC equality. This is a small step in milestone 3, not completion of that
milestone or a coupled heart model.

See [the research tree](docs/research/001-next-directions.md),
[source mapping](docs/SOURCE_MAP.md), and [Windkessel chapter](docs/models/Windkessel.md).
Next candidates are uniqueness or constant nonzero inflow, followed by a sourced
volume/valve interface. Calcium buffering and ventricular pressure–volume papers
remain reading candidates; their equations have not been adopted.
