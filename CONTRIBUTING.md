# Contributing to CardioLean

CardioLean is a learning journal and an experimental Lean 4 library maintained by someone who is not a trained mathematician. Constructive corrections and accessible explanations are central contributions. Questions are welcome even when you do not have a proposed fix.

## Report a mistake or ask a question

Open an issue using the mathematical-error or learning-question template. Link the file, theorem, equation, or journal passage. Explain the concern in plain language; provide a counterexample or corrected statement when possible. A suspected error is useful even if its cause is uncertain.

Contributions can:

- Identify mathematical mistakes, missing domain restrictions, or omitted assumptions.
- Correct physiological interpretations and explain what evidence supports the correction.
- Suggest relevant original papers with verifiable bibliographic details, DOI or stable link, and the relevant equation or page.
- Improve Lean proofs while preserving their exact meaning and making their strategy easier to follow.
- Explain a difficult concept through a small example or a clearly labeled informal argument.
- Separate established results, chosen assumptions, conjectures, and work that remains incomplete.

Keep mathematical and physiological objections distinct. For example, a proof may be valid while its assumptions are inappropriate for a biological system. Formal verification alone does not establish physiological accuracy or experimental validity.

## Propose a change

1. Describe the problem and intended result in an issue or pull request. Small focused changes are easiest to review.
2. Read [AGENTS.md](AGENTS.md), the relevant source comments, and [docs/MODEL_TEMPLATE.md](docs/MODEL_TEMPLATE.md).
3. State all mathematical and physiological assumptions. Explain sign conventions, domains, units, and the correspondence between scientific and Lean notation.
4. For scientific claims, cite the original source and identify the relevant equation, section, or page. Do not infer cardiac validity from a general muscle model.
5. Add readable Lean code and comments explaining the reasoning. Avoid unnecessary abstractions and dependencies. Do not use `sorry`, `admit`, or new axioms to present unfinished work as proved.
6. Run the following commands from the repository root and report their actual outcome:

   ```bash
   lake exe cache get
   lake build
   ```

7. Update affected documentation and verification statuses. If you could not run a check, say why and what still needs checking.

The Lean toolchain and Mathlib dependency are pinned. Routine contributions should use those pins. A dependency update should be a deliberate change to the toolchain, dependency specification, and manifest together, followed by a complete build.

## Record evidence and corrections

Use the verification categories in the model template exactly: **Not started**, **Under investigation**, **Formal definition completed**, **Proof in progress**, **Machine-checked proof completed**, and **Independently reviewed**. Assign status to individual definitions or statements when their progress differs. Independent review needs an identifiable reviewer and scope; it is not implied by a successful build.

A machine-checked theorem has been accepted by Lean under its stated assumptions. Experimental support must be described in a separate evidence section, including the preparation, measurements, and limits of the study. An informal calculation, simulation, or plausible physiological explanation is not a formal proof.

When correcting a substantive mistake, explain the previous claim, the correction, and its effect on proofs or interpretation. Add a dated journal correction when appropriate. Keep the author's personal introduction and learning-oriented voice intact; do not invent personal experiences or claim understanding on the author's behalf.
