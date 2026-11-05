# Instructions for CardioLean contributors and coding agents

CardioLean is a learning journal and an experimental Lean 4 library maintained
by someone who is not a trained mathematician. Read `README.md`, `REFERENCES.md`,
`docs/MODEL_TEMPLATE.md`, the relevant model notes, and existing Lean code before
changing a model. Preserve the original personal introduction and learning focus.

## Correctness and scientific traceability

- Treat source files, complete Lean proofs, and identified original scientific
  publications as evidence. Clearly distinguish definitions, assumptions,
  conjectures, intended work, mathematical results, and experimental findings.
- Verify citation metadata and the actual equation in the source. Record equation
  numbers, pages, notation mappings, sign conventions, and all assumptions.
  Never fabricate citations, parameter values, physiological claims, or proofs.
- Map adopted equations and project-derived lemmas in `docs/SOURCE_MAP.md`,
  with precise paper locators and the actual Lean declaration names.
- Every model needs the nine sections in `docs/MODEL_TEMPLATE.md`: scientific
  source, biological interpretation, formulation, assumptions, units, Lean
  implementation, proof obligations, verification status, and limitations.
- Formal verification does not establish physiological accuracy or clinical
  usefulness. Do not describe mathematical consistency as experimental validation.
- Explain uncertain interpretations and possible conceptual mistakes plainly.
  Corrections and unanswered questions belong in the learning record.

## Lean implementation

- Prefer small readable definitions and proofs with explicit hypotheses. Introduce
  abstractions only when an implemented use case needs them. Use the module's
  `CardioLean.<Area>.<Topic>` namespace and focused Mathlib imports.
- Explain the mathematical argument and significant tactics in comments. State
  denominator conditions, signs, domains, and units before using a formula.
- Do not use `sorry`, `admit`, unsupported axioms, or proof-bypassing mechanisms
  to claim a theorem. Leave difficult proposed statements in documentation and
  explain what is missing. Standard Lean/Mathlib logical foundations are not
  new scientific assumptions; record any unusual dependencies explicitly.
- Lean real division is total, including at zero. A definition that elaborates
  everywhere is not evidence that its physical interpretation is valid everywhere.
- Use the pinned Lean module system: begin library files with `module`, make
  intended declarations public, and use `public import` for root reexports and
  dependencies whose declarations are part of the public API. Expose definition
  bodies with `@[expose]` only when downstream unfolding is intended.
- Add every new library module to `CardioLean.lean` so the default build checks it.
  Check standalone test modules explicitly in CI; do not create an import cycle.
  Unimplemented modules should contain only purpose/status documentation and an
  appropriate namespace, with imports only when justified.
- Preserve pinned, compatible toolchain and dependency revisions. Keep
  `lake-manifest.json` tracked; do not run dependency upgrades as incidental cleanup.
  Mathlib is the only direct mathematical dependency unless there is a clear need.

## Verification and reporting

From the repository root, run:

```bash
lake exe cache get
lake build
```

Check the changed Hill module directly when changing its proofs:

```bash
lake env lean CardioLean/Contraction/Hill.lean
```

Inspect build output and exit status. Never claim successful compilation without
actually running the relevant command on the final code. Record the environment,
toolchain, dependency revision, date, commands, and remaining failures. A locally
successful build is distinct from an observed GitHub Actions run.

Use only these verification categories: **Not started**, **Under investigation**,
**Formal definition completed**, **Proof in progress**, **Machine-checked proof
completed**, **Independently reviewed**. Apply them per definition or result.
Independent review requires an identified reviewer and scope; do not infer it
from compilation, an automated agent pass, or the presence of a citation.

## Learning, scope, and change hygiene

- Explain concepts with ordinary language and motivating examples. Do not assume
  professional mathematical training. Link definitions to their purpose.
- Journal prose may state intentions and questions in the author's voice, but do
  not fabricate personal experiences, insights, or understanding on their behalf.
  Label setup observations and proposed study questions distinctly.
- Keep initial work focused on foundations and the classical Hill relationship.
  Rice, Land, O'Hara–Rudy, and other complex models remain future study until
  explicitly requested and scientifically documented.
- Keep documentation synchronized with the exact implemented hypotheses and
  theorem names. Do not present documentation-only modules as formalized models.
- Preserve unrelated work and original source history. Do not expose credentials,
  authentication state, `.env` contents, or private keys in files or logs.
