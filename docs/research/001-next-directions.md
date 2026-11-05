# Research decision tree after the Hill example

Explored on 2026-11-05. This is a record of candidate directions and evidence,
not a claim to have formalized a complete heart. The selection favors small
results whose assumptions can be understood and checked.

```text
CardioLean: from one force–velocity curve toward coupled models
├── Contraction: Hill (1938)
│   └── Zero-load velocity and interval bounds → implemented this session
├── Arterial circulation: Wang (2003), Alastruey (2010)
│   ├── Zero-inflow two-element Windkessel → selected and implemented
│   └── Nonzero inflow, uniqueness, volume/valve interfaces → next work
├── Calcium: Wagner & Keizer (1994)
│   └── Buffering and diffusion → reading candidate; no equations adopted yet
└── Ventricular mechanics: Suga & Sagawa (1974)
    └── Pressure–volume relations → candidate; original full text still needed
```

## Evidence and decision

| Direction | Primary source checked | Decision and prerequisite |
|---|---|---|
| Strengthen Hill | Existing verified Hill1938 equation and Lean implementation | Complete the zero-load/bound exercises; no new physiological assumption |
| First dynamic arterial component | Wang2003 full text, p. H1359, equations (1)–(3); Alastruey2010 full text, equations (1)–(2) | Implement a zero-inflow solution and verify its derivative, flow balance, bounds, and time constant |
| Calcium buffers | WagnerKeizer1994 metadata and abstract; full-text scan located | Under investigation: read the actual reaction equations and assumptions before defining a binding or diffusion model; this is not a cardiac-specific validation source |
| Ventricular pressure–volume model | SugaSagawa1974 DOI/Crossref and PubMed metadata | Under investigation: inspect the original equations, offset-volume definition, preparation, and limits before implementation; no equation copied from a secondary summary |

References and stable links: [REFERENCES.md](../../REFERENCES.md).

The Windkessel branch was selected because it adds differentiation and a genuine
flow-balance check with one state variable. A time-dependent input is allowed by
the balance definition, but only the zero-input closed form is proved here.
This is a choice of learning scope, not a ranking of biological importance.
The reservoir/wave separation in the cited papers is beyond this implementation;
we do not assume that all their interpretations follow from the selected equation.

## What is still needed to model a coupled heart?

These are proposed engineering and mathematical prerequisites, not completed results:

1. **States and interfaces.** Decide which pressures, volumes, concentrations, and
   muscle variables each component exposes. Specify compatible units and signs.
2. **A chamber and valve model.** Define a volume balance and the pressure–volume
   relationship, then specify when valves conduct and what happens at switching times.
3. **A contraction-to-chamber map.** Hill gives muscle shortening velocity, whereas
   Windkessel expects volume inflow. Geometry and mechanical assumptions are needed;
   directly identifying those quantities would mix different dimensions.
4. **Solution theory.** Verify initial conditions, existence/uniqueness where
   appropriate, admissible-state preservation, and behavior across switching boundaries.
5. **Parameters and evidence.** Identify species, preparation, estimation procedure,
   uncertainty, and experimental data. The same-RC theorem already demonstrates why
   one zero-inflow pressure curve is insufficient to identify R and C separately.
6. **Numerical fidelity.** Relate an implemented numerical scheme to the continuous
   equations. The notebook's large-step Euler example shows why a plausible curve
   and a few sample checks cannot establish preservation of mathematical bounds.

## Suggested next branch

First study uniqueness or constant-input forcing in the same one-compartment
model. Then investigate a volume-conserving chamber/valve interface using an
original source. Calcium, electrophysiology, detailed contraction, and geometry
remain separate research tasks; no Rice, Land, or coupled-heart model is implemented.

Each adopted equation must get a model chapter and an entry in
[SOURCE_MAP.md](../SOURCE_MAP.md) distinguishing source equations from project-derived lemmas.
