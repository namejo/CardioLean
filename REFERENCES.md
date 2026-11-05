# References

Only checked bibliographic details are listed. A reference explains provenance;
its presence does not mean CardioLean has formalized or validated the whole work.

## Scientific literature

**[Hill1938]** Hill, A. V. (1938). *The heat of shortening and the dynamic
constants of muscle*. Proceedings of the Royal Society of London. Series B —
Biological Sciences, **126**(843), 136–195. Published 10 October 1938.
[DOI: 10.1098/rspb.1938.0050](https://doi.org/10.1098/rspb.1938.0050).
[Original article scan hosted by NYU](https://math.nyu.edu/~peskin/eb_lecture_notes/Hill_AV_1938.pdf).

- Relevant location: printed p. 161 (PDF page 26), equations (1) and (2);
  dimensions of `a` are discussed on p. 160 and those of `b` on p. 161.
- The original uses `P` and `P₀` for load and isometric tension; CardioLean uses
  `F` and `F₀`. This is a notation change, not a new physiological model.
- The article concerns skeletal muscle experiments, including frog sartorius.
  Its inclusion here does not establish that this simple relation adequately
  describes cardiac muscle.
- Bibliographic metadata checked against the
  [Crossref DOI record](https://api.crossref.org/works/10.1098%2Frspb.1938.0050)
  and the equation checked in the original scan on 2026-11-05.

## Additional sources and investigated directions

**[Wang2003]** Wang, J.-J., O’Brien, A. B., Shrive, N. G., Parker, K. H., and
Tyberg, J. V. (2003). *Time-domain representation of ventricular-arterial coupling
as a windkessel and wave system*. American Journal of Physiology–Heart and
Circulatory Physiology, **284**(4), H1358–H1368.
[DOI](https://doi.org/10.1152/ajpheart.00175.2002).
[Author-hosted full text](https://kparker.bg-research.cc.ic.ac.uk/wave_intensity_web/pubs/Wang%20JJ%20Am%20J%20Physiol%202003.pdf).
Methods / Theory / Windkessel theory, printed H1359 (PDF page 2), equations
(1)–(3), including the resistive-outflow paragraph and zero-inflow specialization.
The follow-up also uses the general balance to derive a constant-input solution;
its integrating-factor uniqueness proof is a project derivation.
Only that selected component is represented in Lean.

**[Alastruey2010]** Alastruey, J. (2010). *On the Mechanics Underlying the
Reservoir-Excess Separation in Systemic Arteries and their Implications for Pulse
Wave Analysis*. Cardiovascular Engineering, **10**(4), 176–189.
[DOI and full text](https://doi.org/10.1007/s10558-010-9109-9).
Methodology / Reservoir-Excess Separation, equations (1)–(2), is the direct
notation reference for our balance and specialized zero/constant-inflow solutions.
The paper's distributed-vessel analysis and other results are not formalized.

**[WagnerKeizer1994]** Wagner, J., and Keizer, J. (1994). *Effects of rapid buffers
on Ca2+ diffusion and Ca2+ oscillations*. Biophysical Journal, **67**(1), 447–456.
[DOI](https://doi.org/10.1016/S0006-3495(94)80500-4).
[Primary article record and scan](https://pmc.ncbi.nlm.nih.gov/articles/PMC1225377/).
Metadata and abstract inspected; candidate for further reading, not a source
for an implemented equation or a claim of cardiac-specific validation.

**[SugaSagawa1974]** Suga, H., and Sagawa, K. (1974). *Instantaneous Pressure-Volume
Relationships and Their Ratio in the Excised, Supported Canine Left Ventricle*.
Circulation Research, **35**(1), 117–126.
[DOI](https://doi.org/10.1161/01.RES.35.1.117).
[PubMed record](https://pubmed.ncbi.nlm.nih.gov/4841253/).
Metadata checked; original full text still needs inspection before an equation
is adopted. No pressure–volume formalization is attributed to this paper yet.

All four entries were checked against Crossref metadata on 2026-11-05. Equation
inspection was completed only for the two Windkessel sources as stated above.
See [the source-to-Lean index](docs/SOURCE_MAP.md) and
[research decision tree](docs/research/001-next-directions.md).

## Lean and mathematical-library resources

**[TPIL4]** Avigad, J., de Moura, L., Kong, S., and Ullrich, S., with
contributions from the Lean Community. *Theorem Proving in Lean 4*.
[Official online text](https://lean-lang.org/theorem_proving_in_lean4/).
A living text, accessed 2026-11-05; useful for propositions, tactics, and axioms.

**[Mathlib]** The Lean mathematical library community. *Mathlib4*.
[Source repository](https://github.com/leanprover-community/mathlib4) and
[generated API documentation](https://leanprover-community.github.io/mathlib4_docs/).
A living software library, accessed 2026-11-05. The project's actual version is
recorded by `lakefile.toml`, `lean-toolchain`, and `lake-manifest.json`; current
online API documentation may describe a different revision.

**[LeanProjects]** Lean community. *Lean projects*.
[Official community project guide](https://leanprover-community.github.io/install/project.html).
A living guide, accessed 2026-11-05; covers Lake projects and Mathlib caches.

Complex-model module names reserve future study topics. No Rice, Land, or other
complex-model equation or bibliographic claim is introduced by those names.
