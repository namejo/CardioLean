## About this project

CardioLean is my personal learning journal about the mathematics of the human heart and how mathematical models can be formalized using Lean 4.

**I am not a trained mathematician.**

I started this project because I want to understand the mathematical foundations of cardiac physiology, from muscle contraction and electrophysiology to the mechanics of the heart.

My goal is to learn by studying scientific papers, understanding their equations, and attempting to formalize their mathematical properties in Lean.

This repository documents my learning process, including experiments, incomplete work, mistakes, corrections, and discoveries.

### Corrections are very welcome!

If you find any mathematical errors, incorrect physiological assumptions, missing references, or mistakes in my Lean code, **please open a GitHub Issue or submit a pull request**.

Constructive criticism, explanations, and learning resources are greatly appreciated.

I hope this project can eventually become a useful collection of formally verified mathematical properties of cardiac models.

Until then, it is primarily a place to learn, experiment, and improve.

## Build and explore

The project uses Lean 4.35.0, Lake (Lean's build tool), and Mathlib v4.35.0 (a community mathematics library). The Lean version is pinned in `lean-toolchain`; the Mathlib revision is pinned in `lakefile.toml` and resolved, together with its dependencies, in `lake-manifest.json`. Keep these files together when updating versions.

Install [Lean using the official instructions](https://lean-lang.org/install/), then run these commands in this existing repository:

```bash
lake exe cache get
lake build
```

The first command downloads precompiled Mathlib files. The second checks the library, including every planned module imported by `CardioLean.lean`. A successful build establishes that Lean accepts the included definitions and proofs against the pinned dependencies. It does not establish that an equation accurately describes heart physiology. The GitHub Actions workflow in [`.github/workflows/lean.yml`](.github/workflows/lean.yml) repeats these checks on pushes and pull requests.

**Setup verification (2026-11-05):** `lake exe cache get`, `lake build`, and a direct Lean check of `Hill.lean` succeeded on Proxmox with the pinned versions. All six theorem declarations below were checked. See [the verification record](docs/VERIFICATION.md) for the environment and limits of these checks. Hosted CI is configured; its result must be checked separately.

## Repository map

```text
CardioLean.lean               Library entry point, importing all planned modules
CardioLean/
  Foundations/               Units, differential equations, conservation, parameters
  Electrophysiology/          Nernst equation, channels, membrane and action potentials
  Calcium/                   Transport, binding, conservation
  Contraction/               Hill example; future CrossBridge, Rice2008, Land2017 modules
  Mechanics/                 Elasticity, tissue stress, ventricular mechanics
  Circulation/               Windkessel, pressure-volume relationships, flow conservation
  Models/                    Future cell, heart, and coupled model integration
journal/                     Learning notes and open questions
  001-getting-started.md
docs/MODEL_TEMPLATE.md       Scientific and mathematical documentation checklist
```

The initial scope is small: one algebraic force-velocity example. Modules other than [Hill.lean](CardioLean/Contraction/Hill.lean) document intended purposes; they do not yet implement the corresponding cardiac models.

## First example: Hill's force-velocity relationship

The classical relationship is

$$
(F+a)(v+b)=(F_0+a)b,
\qquad
v(F)=\frac{b(F_0-F)}{F+a}.
$$

Here force is `F`, isometric force is `F₀`, and positive velocity means shortening. This first formalization uses real numbers in fixed, compatible units: `F`, `F₀`, and `a` have force units; `v` and `b` have velocity units. Lean does not yet check dimensions.

For the intended shortening range, assume `a > 0`, `b ≥ 0`, and `0 ≤ F ≤ F₀`. These conditions make the denominator positive and the numerator nonnegative. Physically interpreting `F₀` as a maximum isometric force is a model assumption, not a conclusion of algebra. For strict decrease, require `b > 0`; a nondegenerate force interval is needed to compare two distinct admissible forces. Each Lean theorem states its own hypotheses; some algebraic results need fewer assumptions than this interpretation.

The implementation contains the following statements in the namespace `CardioLean.Contraction.Hill`:

| Statement | Purpose |
| --- | --- |
| `denominator_pos` | Prove `F + a > 0` from `a > 0` and `F ≥ 0`. |
| `equation_iff_velocity` | Connect the original equation to the quotient when `F + a ≠ 0`. |
| `velocity_nonneg` | Prove nonnegative velocity on the intended shortening range. |
| `velocity_at_isometric` | Show that substituting `F₀` gives zero. |
| `velocity_antitoneOn` | Show that increasing force cannot increase velocity on `[0, F₀]`. |
| `velocity_strictAntiOn` | Show strict decrease when `b > 0`. |

Read the implementation comments and [Hill model notes](docs/models/Hill.md) for the exact hypotheses and proof strategies. Build verification is recorded above.

Hill's original work studied skeletal muscle. Using this relationship as a learning example does not validate its applicability to cardiac muscle. Source details and links are in [REFERENCES.md](REFERENCES.md).

## Learning and contributing

Start with [the first journal entry](journal/001-getting-started.md), [the roadmap](ROADMAP.md), and [the model documentation template](docs/MODEL_TEMPLATE.md). The journal distinguishes completed repository work from questions to investigate; draft notes should not be read as evidence of personal understanding.

[CONTRIBUTING.md](CONTRIBUTING.md) explains how to report mistakes, clarify assumptions, suggest literature, and improve explanations or Lean proofs. [AGENTS.md](AGENTS.md) gives persistent instructions to coding agents. Corrections should remain visible in the journal so that the repository can document how the work changes over time.

Mathematical proof status and experimental evidence must be recorded separately. An accepted Lean proof verifies a precise mathematical statement under stated assumptions; a biological interpretation still needs scientific evidence and critical review.
