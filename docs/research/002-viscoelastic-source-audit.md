# Source audit: Maxwell/Kelvin–Voigt network and a coefficient discrepancy

Date: 2026-11-05. **Issue status: Under investigation.** This is an internal
mathematical comparison, not an erratum or a claim that the experiments are invalid.
No message has been sent to the authors.

## Evidence consulted

Caporizzo et al. (2018), DOI [10.1016/j.bpj.2018.09.019](https://doi.org/10.1016/j.bpj.2018.09.019),
[PMC full text](https://pmc.ncbi.nlm.nih.gov/articles/PMC6224693/).
The online HTML/MathML of equation (4), Methods / Mathematical model for myocyte
contractility, was inspected directly. Figure 2D was visually inspected: E₁ and
η₁ are parallel branches, alongside a series E₂–η₂ branch. Figure 3B identifies
the same network. The publisher PDF and possible corrections have not been verified.

## Independent derivation from the stated topology

We assume the standard constant-parameter element laws, small uniaxial strain,
and common effective reference measures. Let z be the Maxwell branch stress:

$$\sigma=E_1\varepsilon+\eta_1\dot\varepsilon+z,\qquad
\dot z=E_2\dot\varepsilon-(E_2/\eta_2)z.$$

Differentiate the stress-sum equation and eliminate z. The resulting equation is

$$\eta_1\eta_2\ddot\varepsilon+
\underbrace{(E_1\eta_2+E_2\eta_2+E_2\eta_1)}_{b_{network}}\dot\varepsilon+
E_1E_2\varepsilon=E_2\sigma+\eta_2\dot\sigma.$$

The currently displayed HTML equation (4) instead has
`b_displayed = E₂η₂ + E₁η₁ + E₂η₁`.
Thus `b_network - b_displayed = E₁(η₂-η₁)` under these labels.
This is a mathematical mismatch under our explicit branch-law interpretation.
We do not silently import the displayed coefficient as a scientific axiom.

## Reproducible check

Take E₁=E₂=η₁=1, η₂=2, ε=0, ε̇=1, ε̈=0, z=0, ż=1. The branch equations give
σ=1 and σ̇=2. The network equation has left side 5 and right side 5.
The displayed coefficient instead gives left side 4 with the same right side 5.
All parameters are positive; the example is not a zero-parameter singularity.
These are synthetic pointwise algebraic values, not experimental measurements.
Use Pa, Pa·s, and seconds for compatible stress, viscosity, and rate units.

`parallel_second_order` in [LinearViscoelastic.lean](../../CardioLean/Mechanics/LinearViscoelastic.lean)
checks the elimination from supplied rates. [ModelChecks.lean](../../test/ModelChecks.lean)
checks the numeric example. This proves neither the differentiability nor the
existence of histories for every supplied pointwise tuple.

## What remains unresolved

The cause could involve a transcription/typesetting issue, a different intended
constitutive interpretation, or a formula error. Inspecting the publisher PDF,
corrections, and the authors' intended derivation is needed before classifying it.
Equation (3) is also not adopted here as a general time-domain Maxwell law.
Its instantaneous algebraic expression must not replace the differential internal-state
law without an additional justified assumption. We have not audited equations
(2), (3), or (7) in full, nor reproduced the paper's parameter fits.

The implementation uses explicitly derived passive branch laws and labels its
results as project derivations. It does not claim to reproduce the complete
published cardiomyocyte contractility model.
