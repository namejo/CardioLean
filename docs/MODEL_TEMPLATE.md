# Model documentation template

Copy this file to `docs/models/<ModelName>.md` before introducing a model. Replace
all angle-bracket prompts. Keep unimplemented equations in documentation rather
than inventing Lean definitions to fill a module. Link the source file from its
Lean module documentation.

## 1. Scientific source

- **Reference key:** <entry in REFERENCES.md>
- **Original publication:** <authors, title, year, journal/book, volume, pages>
- **Stable identifier:** <verified DOI or publisher/repository URL>
- **Exact location:** <equation number, printed page, section; include PDF page if useful>
- **Evidence consulted:** <original text, supplement, correction, data; access date>
- **Notation mapping:** <how original symbols map to this project's symbols>

Verify bibliographic details and read the relevant equation. If only a secondary
source is available, identify it and leave the original interpretation under
investigation. Do not invent missing citation details.

## 2. Biological interpretation

<Explain in plain language what is represented and what is deliberately omitted.>

Identify species, tissue, experimental conditions, sign conventions, and intended
regime when these are supported by the source. Separate what the source reports
from the project's proposed interpretation. Explain why this model is useful for
learning or for a later cardiac model.

## 3. Mathematical formulation

<Write the precise equations, variable domains, parameter meanings, and any
initial/boundary conditions. Define every symbol.>

Show any rearrangement used in Lean. Explain required side conditions, especially
nonzero denominators, positivity, smoothness, and existence assumptions. State
whether a claim is a definition, a conditional theorem, a conjecture, or an open
question. Avoid using the word "proved" for a numerical observation.

## 4. Assumptions

| Assumption | Kind | Why needed | Source or project choice |
| --- | --- | --- | --- |
| <condition> | <mathematical / physiological / modeling> | <role> | <citation or explicit choice> |

Distinguish the biological regime from the weakest hypotheses needed by each
lemma. List parameter bounds and excluded cases. Do not silently infer an
empirical condition from a convenient mathematical assumption.

## 5. Physical units

| Quantity | Meaning | Dimension | Chosen unit |
| --- | --- | --- | --- |
| <symbol> | <meaning> | <dimension> | <unit> |

State whether quantities are dimensional or normalized and give conversion rules
for normalized variables. Record compatible units, velocity and flow signs, and
whether Lean enforces dimensions or they are a documented convention only.

## 6. Lean implementation

- **Module and namespace:** <path and namespace>
- **Definitions:** <names, types, and mapping to the equations>
- **Imports:** <why nontrivial dependencies are needed>
- **Representation decisions:** <real numbers, functions of time, structures, etc.>

Explain important tactics in accessible terms and give a short paper proof before
or beside each formal proof. Identify any mismatch between Lean's total
operations and the intended scientific domain, such as real division by zero.

## 7. Proof obligations

| Statement | Exact hypotheses | Lean declaration or missing work |
| --- | --- | --- |
| <property> | <conditions> | <declaration / proposed statement> |

Start small: algebraic consistency, signs, limiting cases, bounds, conservation,
then existence or stability where justified. An intended theorem is not a result.

## 8. Verification status

Use exactly these categories and apply them to individual items:

| Category | Meaning |
| --- | --- |
| Not started | Intended work only; no investigation or implementation claimed. |
| Under investigation | Reading, derivation, or exploratory work without a completed formal result. |
| Formal definition completed | A Lean definition represents the stated expression; no property follows from this label alone. |
| Proof in progress | A proposed theorem is being worked on; do not present it as established. |
| Machine-checked proof completed | Lean accepted the complete proof under recorded hypotheses and dependencies. |
| Independently reviewed | An identified reviewer separately checked the stated scope; record whether review covered mathematics, physiology, or code. |

| Item | Category | Evidence and scope |
| --- | --- | --- |
| <definition or theorem> | <category above> | <path, command, toolchain, date, result> |

Record exact build commands, toolchain and dependency revision, date, and failures.
If no build was run, say so. A machine check does not imply independent review.
Keep an additional **experimental-evidence record**: <what the source measured,
under which conditions, and which claims have no empirical support here>.

## 9. Limitations and open questions

<What do these definitions and proofs fail to establish? Which approximations,
parameter choices, units, source interpretations, or numerical methods remain open?>

A formal proof establishes a mathematical statement conditional on its hypotheses
and the trusted proof system. It does not establish physiological accuracy,
parameter suitability, experimental validity, clinical usefulness, or adequacy of
a model for a particular species or tissue. Keep these questions separate.

Record corrections with their reason and effect; preserve useful learning history
without leaving superseded claims looking current.
