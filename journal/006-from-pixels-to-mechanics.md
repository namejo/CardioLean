# 006 — From image regions to a mechanical model

*Learning scaffold and completed-work record, 2026-11-06. The author proposed an
MRI-informed pixel/voxel model and asked for exploration before giving feedback.
The questions below do not claim personal reading, understanding or agreement.*

## What is available to study

[Chapter 5](../docs/models/VoxelMechanics.md) separates image geometry, a mechanical
discretization, a material law, and parameter estimation.
The [literature guide](../docs/research/003-voxel-method-literature.md) records
which original sources were inspected and which remain abstract-only candidates.

The new Lean module studies a planar axial network and its energy accounting.
The [notebook](../notebooks/voxel-method.ipynb) tests grid shear and an illustrative
eight-parameter material fit using synthetic data. Those two constructions are
different models; neither is fitted to MRI or validated tissue.

The 90-degree-view question has a concrete experiment: re-expressing existing
observations does not add parameter directions, while a genuinely additional
measured displacement component can add information. Different loading histories
can reveal material behavior absent from the original data.

## Questions I want to work through myself

- What exactly is stored in a pixel: an image value, a material label, a displacement,
  or a material parameter?
- Can I explain why a square axial grid misses small shear?
- Why does nonnegative energy not guarantee a unique equilibrium?
- How do spring stiffness and material modulus change differently when a grid is refined?
- What does a singular value tell me about which parameters an experiment can distinguish?
- Which MRI acquisition would supply motion components, and which loading information
  would still be missing?
- Why do four links with two coefficients differ from a tensor law with eight coefficients?
- Which additional assumptions would let a 2D slice represent a 3D tissue region?

## Space for my own feedback

No response is assumed. Useful decisions to record later are the specimen or
ventricular region, available MRI sequences, pressure/force information, intended
deformation range, and whether the first goal is forward prediction or parameter
identification. Corrections should record what changed and why.
