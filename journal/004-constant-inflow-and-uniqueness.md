# 004 — Constant input and uniqueness

*Completed-work record and personal study prompts, 2026-11-05. This entry does
not claim that I have personally read the sources or mastered these concepts.*

## Work now available

[Chapter 3](../docs/models/WindkesselConstant.md) extends the same paper-based
balance to constant inflow. The equilibrium is pOut+R*q. The checked curve stays
between its initial pressure and equilibrium for nonnegative elapsed time.
Additional proofs establish nondecrease below equilibrium, nonincrease above it,
and conditional uniqueness on an observed interval.

The uniqueness argument compares two candidate solutions with the same parameters
and input. Their difference, multiplied by exp(t/(RC)), has zero derivative.
The mean-value theorem then makes that weighted difference constant.
[The notebook](../notebooks/windkessel-constant-inflow.ipynb) illustrates numerical
cases; the proof itself is in Lean, not established by the plots.

## Questions I want to answer myself

- Can I derive the new equilibrium from the flow balance without looking at the solution?
- Why can nonzero inflow coexist with falling pressure?
- Why does the input disappear when subtracting two solutions?
- What does existence add, and what does uniqueness add?
- Why does proving uniqueness with fixed R,C say nothing by itself about fitting R,C?
- Why do endpoint derivatives and continuity matter when introducing valve switching?

## My own reading and corrections

Space for dated calculations, attempted explanations, paper-reading notes, and
corrections. The general-input existence problem and switching interfaces remain
open. Mathematical correctness of this component is separate from experimental
validation of a cardiac model.
