module

import CardioLean.Mechanics.PlanarNetwork
import Mathlib.Tactic.NormNum

/-!
Assumption checks for the exploratory passive planar network. Values are
synthetic. These examples document important exclusions, not tissue validation.
-/

open CardioLean.Mechanics.PlanarNetwork

-- Endpoint order does not change the physical tensile force on the same node.
example (force : ℝ) :
    startForce (reverse (Edge.mk false true (1, 0))) force =
      finishForce (Edge.mk false true (1, 0)) force := by
  apply Prod.ext <;> simp [startForce, finishForce, reverse]

-- A nonzero simple shear can be invisible to every axial square-grid side.
example :
    dot (1, 0) (simpleShear 1 (1, 0) - simpleShear 1 (0, 0)) = 0 ∧
    dot (0, 1) (simpleShear 1 (1, 1) - simpleShear 1 (1, 0)) = 0 ∧
    dot (1, 0) (simpleShear 1 (1, 1) - simpleShear 1 (0, 1)) = 0 ∧
    dot (0, 1) (simpleShear 1 (0, 1) - simpleShear 1 (0, 0)) = 0 ∧
    simpleShear 1 (0, 1) ≠ simpleShear 1 (0, 0) := by
  norm_num [dot, simpleShear]

-- Fixed-direction infinitesimal kinematics are NOT finite-rotation mechanics:
-- the unit x-link's displacement under a 90-degree rotation is (-1,1), which
-- has linearized extension -1 although the true rotated length remains one.
example : extension (Edge.mk false true (1, 0))
    (fun node => if node then (-1, 1) else (0, 0)) = -1 := by
  norm_num [extension, dot]

-- A material modulus cannot be used as link stiffness without geometry: the
-- supplied direction must also be normalized for q to mean axial extension.
-- This check shows that doubling an unnormalized direction doubles the output.
example : extension (Edge.mk false true (2, 0))
    (fun node => if node then (1, 0) else (0, 0)) = 2 := by
  norm_num [extension, dot]

-- Positive parameter pairs can remain indistinguishable in one loading history:
-- qdot=q makes (k,c)=(2,3) and (1,4) give the same force for every q.
example (q : ℝ) :
    CardioLean.Mechanics.LinearViscoelastic.kelvinVoigtStress 2 3 q q =
      CardioLean.Mechanics.LinearViscoelastic.kelvinVoigtStress 1 4 q q := by
  have h := (proportional_rate_parameter_ambiguity 2 3 q 1 1).symm
  norm_num at h
  exact h

-- Nonnegative energy/dissipation is conditional on coefficient signs.
example : edgeEnergy (-1) 1 1 0 < 0 := by
  norm_num [edgeEnergy, CardioLean.Mechanics.LinearViscoelastic.springEnergy]
