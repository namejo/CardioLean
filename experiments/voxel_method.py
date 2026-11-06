"""Synthetic checks for a 2D precursor to an MRI-informed voxel model.

Run with the optional notebook environment, from any directory:
    python experiments/voxel_method.py

This script is project-derived exploratory mathematics. It does not load MRI,
identify patient parameters, integrate tissue dynamics, or prove Lean theorems.
The lattice and eight-coefficient continuum example are DIFFERENT toy models.
The latter is not four independently fitted pixel sides. See the model chapter.
"""

from __future__ import annotations

import json
from pathlib import Path
import platform

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


ROOT = Path(__file__).resolve().parents[1]
PARAMETER_NAMES = ["C11", "C22", "C12", "C66", "D11", "D22", "D12", "D66"]


def spectrum(matrix: np.ndarray) -> dict:
    """SVD diagnostics; rank is a numerical result under the stated tolerance.

    All inverse-design inputs below are nondimensionalized before using this.
    A finite condition number is reported only when all columns are independent.
    """
    singular = np.linalg.svd(matrix, compute_uv=False)
    tolerance = max(matrix.shape) * np.finfo(float).eps * singular[0]
    rank = int(np.count_nonzero(singular > tolerance))
    return {
        "rows": int(matrix.shape[0]),
        "columns": int(matrix.shape[1]),
        "rank": rank,
        "nullity": int(matrix.shape[1] - rank),
        "tolerance": float(tolerance),
        "singular_values": singular.tolist(),
        "full_column_rank_condition_number": (
            float(singular[0] / singular[-1]) if rank == matrix.shape[1] else None
        ),
    }


def lattice(n: int, diagonals: bool) -> tuple[np.ndarray, np.ndarray, np.ndarray, list]:
    """Unit-square axial graph with unique links and an explicit toy calibration.

    B maps corner displacements to axial extensions. Each horizontal/vertical
    outer-boundary link gets half weight, because it belongs to one cell rather
    than two. Diagonals each get weight 1/2. This makes the chosen affine patch
    energies independent of grid spacing. It does NOT establish a general
    continuum limit or a match to a prescribed isotropic/orthotropic material.
    Coordinates and stiffness are in arbitrary consistent normalized units.
    """
    if n < 2:
        raise ValueError("At least two nodes per coordinate are required.")
    points = np.array([(i / (n - 1), j / (n - 1)) for j in range(n) for i in range(n)])
    links = []
    weights = []
    for j in range(n):
        for i in range(n - 1):
            links.append((j * n + i, j * n + i + 1))
            weights.append(0.5 if j in (0, n - 1) else 1.0)
    for j in range(n - 1):
        for i in range(n):
            links.append((j * n + i, (j + 1) * n + i))
            weights.append(0.5 if i in (0, n - 1) else 1.0)
    if diagonals:
        for j in range(n - 1):
            for i in range(n - 1):
                links.extend([(j * n + i, (j + 1) * n + i + 1),
                              (j * n + i + 1, (j + 1) * n + i)])
                weights.extend([0.5, 0.5])
    compatibility = np.zeros((len(links), 2 * len(points)))
    for row, (i, j) in enumerate(links):
        direction = points[j] - points[i]
        direction /= np.linalg.norm(direction)
        compatibility[row, 2 * i:2 * i + 2] = -direction
        compatibility[row, 2 * j:2 * j + 2] = direction
    return points, compatibility, np.array(weights), links


def graph_checks() -> tuple[dict, dict]:
    results = {}
    drawing = {}
    for diagonals, label in [(False, "four_neighbor"), (True, "with_diagonals")]:
        points, b, k, links = lattice(3, diagonals)
        translation = np.tile([0.2, -0.4], (len(points), 1)).reshape(-1)
        # This is an infinitesimal rotation field, not a finite rotation matrix.
        rotation = np.column_stack((-points[:, 1], points[:, 0])).reshape(-1)
        extension = np.column_stack((0.1 * points[:, 0], np.zeros(len(points)))).reshape(-1)
        shear = np.column_stack((0.1 * points[:, 1], np.zeros(len(points)))).reshape(-1)
        energies = {name: float(0.5 * np.dot(k, (b @ displacement) ** 2))
                    for name, displacement in [("extension", extension), ("shear", shear)]}
        assert np.max(np.abs(b @ translation)) < 1e-14
        assert np.max(np.abs(b @ rotation)) < 1e-14
        stiffness = b.T @ (k[:, None] * b)
        # Fix lower-left x/y and lower-right y: three rigid-body freedoms.
        fixed = [0, 1, 2 * (3 - 1) + 1]
        free = np.array([d for d in range(stiffness.shape[0]) if d not in fixed])
        constrained = stiffness[np.ix_(free, free)]
        free_spectrum = spectrum(stiffness)
        constrained_spectrum = spectrum(constrained)
        assert free_spectrum["nullity"] == (3 if diagonals else 6)
        assert constrained_spectrum["nullity"] == (0 if diagonals else 3)
        assert energies["extension"] > 0
        if diagonals:
            assert energies["shear"] > 0
        else:
            assert energies["shear"] == 0

        # Instantaneous supplied q, qdot, z and zdot; not a time integrator.
        displacement = extension + shear
        velocity = np.linspace(-0.2, 0.3, len(displacement))
        q, qdot = b @ displacement, b @ velocity
        z = np.linspace(-0.04, 0.06, len(links))
        k0, c0, k1, c1 = k, 0.3 * k, 0.7 * k, 0.9 * k
        zdot = k1 * (qdot - z / c1)
        force = k0 * q + c0 * qdot + z
        storage_rate = k0 * q * qdot + (z / k1) * zdot
        dissipation = c0 * qdot ** 2 + z ** 2 / c1
        edge_residual = force * qdot - storage_rate - dissipation
        internal = -b.T @ force
        force_pairs = internal.reshape(-1, 2).sum(axis=0)
        virtual_work_residual = np.dot(internal, velocity) + np.dot(force, qdot)
        # Choose a consistent force/acceleration tuple to check the dynamic sign.
        acceleration = np.linspace(0.05, -0.02, len(displacement))
        mass = np.full(len(displacement), 0.2)
        external = mass * acceleration + b.T @ force
        kinetic_rate = np.dot(mass * acceleration, velocity)
        energy_balance_residual = (
            np.dot(external, velocity) - kinetic_rate
            - np.sum(storage_rate) - np.sum(dissipation)
        )
        assert np.all(dissipation >= 0)
        assert np.max(np.abs(edge_residual)) < 1e-13
        assert np.linalg.norm(force_pairs) < 1e-13
        assert abs(virtual_work_residual) < 1e-13
        assert abs(energy_balance_residual) < 1e-13
        results[label] = {
            "nodes": len(points), "links": len(links),
            "energy": energies,
            "free_stiffness": free_spectrum,
            "constrained_stiffness": constrained_spectrum,
            "max_translation_extension": float(np.max(np.abs(b @ translation))),
            "max_infinitesimal_rotation_extension": float(np.max(np.abs(b @ rotation))),
            "max_edge_power_residual": float(np.max(np.abs(edge_residual))),
            "paired_force_sum_norm": float(np.linalg.norm(force_pairs)),
            "virtual_work_residual": float(virtual_work_residual),
            "dynamic_power_residual": float(energy_balance_residual),
        }
        drawing[label] = (points, links, stiffness)

    # An affine patch check only: no general mesh-convergence theorem is implied.
    refinement = []
    for n in [2, 3, 5, 9]:
        points, b, k, _ = lattice(n, True)
        extension = np.column_stack((0.1 * points[:, 0], np.zeros(len(points)))).reshape(-1)
        shear = np.column_stack((0.1 * points[:, 1], np.zeros(len(points)))).reshape(-1)
        refinement.append({
            "nodes_per_axis": n,
            "extension_energy": float(0.5 * np.dot(k, (b @ extension) ** 2)),
            "shear_energy": float(0.5 * np.dot(k, (b @ shear) ** 2)),
        })
    assert all(abs(row["extension_energy"] - 0.0075) < 1e-14 for row in refinement)
    assert all(abs(row["shear_energy"] - 0.0025) < 1e-14 for row in refinement)
    results["affine_patch_refinement"] = refinement
    return results, drawing


def voxel_topology_checks() -> dict:
    """Small 3D geometric check, independent of the planar constitutive fit.

    Nearest axial links are compared with all local face/body diagonal links.
    Positive link weights are set to one for this topology test. No 3D material
    calibration, voxel constitutive tensor, near-incompressibility, or refinement
    result is implied. Current Lean network declarations remain planar.
    """
    n = 3
    integer_points = np.array([(i, j, k) for k in range(n) for j in range(n) for i in range(n)])
    points = integer_points / (n - 1)
    results = {}
    for diagonals, label in [(False, "six_neighbor"), (True, "face_and_body_diagonals")]:
        links = []
        for i in range(len(points)):
            for j in range(i + 1, len(points)):
                step = np.abs(integer_points[j] - integer_points[i])
                local = np.max(step) == 1
                axial = np.sum(step) == 1
                if local and (diagonals or axial):
                    links.append((i, j))
        b = np.zeros((len(links), 3 * len(points)))
        for row, (i, j) in enumerate(links):
            direction = points[j] - points[i]
            direction /= np.linalg.norm(direction)
            b[row, 3 * i:3 * i + 3] = -direction
            b[row, 3 * j:3 * j + 3] = direction
        translation = np.tile([0.2, -0.4, 0.1], (len(points), 1)).reshape(-1)
        rotation = np.cross(np.array([0.1, 0.2, 0.3]), points).reshape(-1)
        shear = np.column_stack((0.1 * points[:, 1], np.zeros((len(points), 2)))).reshape(-1)
        assert np.max(np.abs(b @ translation)) < 1e-14
        assert np.max(np.abs(b @ rotation)) < 1e-14
        stiffness = b.T @ b
        # Origin fixed xyz, +x corner fixed yz, +y corner fixed z.
        fixed = [0, 1, 2, 3 * (n - 1) + 1, 3 * (n - 1) + 2,
                 3 * n * (n - 1) + 2]
        free = np.array([index for index in range(3 * len(points)) if index not in fixed])
        free_diagnostic = spectrum(stiffness)
        constrained_diagnostic = spectrum(stiffness[np.ix_(free, free)])
        energy = float(0.5 * np.dot(b @ shear, b @ shear))
        assert free_diagnostic["nullity"] == (6 if diagonals else 27)
        assert constrained_diagnostic["nullity"] == (0 if diagonals else 21)
        assert (energy > 0) if diagonals else (energy == 0)
        results[label] = {
            "nodes": len(points), "links": len(links),
            "free_stiffness": free_diagnostic,
            "constrained_stiffness": constrained_diagnostic,
            "simple_shear_energy": energy,
            "max_translation_extension": float(np.max(np.abs(b @ translation))),
            "max_infinitesimal_rotation_extension": float(np.max(np.abs(b @ rotation))),
        }
    results["scope"] = "3D topology sanity check only; unit positive link weights, no identified 3D tissue constitutive law or MRI processing."
    return results


def constitutive_matrices(theta: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """Engineering shear: e=(eps_xx,eps_yy,gamma_xy), s=(s_xx,s_yy,tau_xy)."""
    c11, c22, c12, c66, d11, d22, d12, d66 = theta
    return (np.array([[c11, c12, 0], [c12, c22, 0], [0, 0, c66]]),
            np.array([[d11, d12, 0], [d12, d22, 0], [0, 0, d66]]))


def design(strain: np.ndarray, strain_rate: np.ndarray) -> np.ndarray:
    """Map the SAME eight material coefficients to all supplied stress samples.

    Rows are [sigma_xx(t0), sigma_yy(t0), tau_xy(t0), sigma_xx(t1), ...].
    This uses known synthetic stresses, unlike an MRI displacement inverse model.
    """
    if strain.shape != strain_rate.shape or strain.shape[1] != 3:
        raise ValueError("strain and strain_rate must both have shape (samples, 3)")
    out = np.zeros((3 * len(strain), 8))
    for sample, (eps, rate) in enumerate(zip(strain, strain_rate)):
        ex, ey, gamma = eps
        vx, vy, gamma_rate = rate
        out[3 * sample] = [ex, 0, ey, 0, vx, 0, vy, 0]
        out[3 * sample + 1] = [0, ey, ex, 0, 0, vy, vx, 0]
        out[3 * sample + 2] = [0, 0, 0, gamma, 0, 0, 0, gamma_rate]
    return out


def inverse_checks() -> tuple[dict, dict]:
    theta = np.array([3.0, 2.0, 0.4, 0.7, 0.9, 0.6, 0.1, 0.3])
    c, d = constitutive_matrices(theta)
    assert np.min(np.linalg.eigvalsh(c)) > 0
    assert np.min(np.linalg.eigvalsh(d)) > 0
    time = np.linspace(0, 3, 121)  # time / t_ref
    strain = np.column_stack((np.sin(1.3 * time),
                              0.7 * np.sin(0.9 * time + 0.4),
                              0.5 * np.sin(1.7 * time - 0.2)))
    rate = np.column_stack((1.3 * np.cos(1.3 * time),
                            0.63 * np.cos(0.9 * time + 0.4),
                            0.85 * np.cos(1.7 * time - 0.2)))
    all_modes = design(strain, rate)
    stress = strain @ c.T + rate @ d.T
    assert np.max(np.abs(all_modes @ theta - stress.reshape(-1))) < 1e-13
    no_shear_strain, no_shear_rate = strain.copy(), rate.copy()
    no_shear_strain[:, 2] = 0
    no_shear_rate[:, 2] = 0
    no_shear = design(no_shear_strain, no_shear_rate)
    no_shear_stress = (no_shear @ theta).reshape(-1, 3)

    # 90-degree re-expression of the same stress equations: s' = S s.
    # Its rows still refer to theta in the ORIGINAL material coordinate system.
    rotate90 = np.array([[0, 1, 0], [1, 0, 0], [0, 0, -1]])
    rotated_design = np.einsum("ab,nbp->nap", rotate90,
                               no_shear.reshape(-1, 3, 8)).reshape(-1, 8)
    rotated_stress = no_shear_stress @ rotate90.T
    assert np.max(np.abs(rotated_design @ theta - rotated_stress.reshape(-1))) < 1e-13
    duplicated_views = np.vstack((no_shear, rotated_design))
    # Check the constitutive coordinate transformation independently.
    rotated_c = rotate90 @ c @ rotate90.T
    rotated_d = rotate90 @ d @ rotate90.T
    transformed_stress = (strain @ rotate90.T) @ rotated_c.T + (rate @ rotate90.T) @ rotated_d.T
    assert np.max(np.abs(transformed_stress - stress @ rotate90.T)) < 1e-13
    assert np.max(np.abs(np.sum(stress * rate, axis=1)
                         - np.sum((stress @ rotate90.T) * (rate @ rotate90.T), axis=1))) < 1e-13

    no_shear_summary = spectrum(no_shear)
    repeated_summary = spectrum(duplicated_views)
    full_summary = spectrum(all_modes)
    assert no_shear_summary["rank"] == 6
    assert repeated_summary["rank"] == 6
    assert full_summary["rank"] == 8
    alternative = theta.copy()
    alternative[[3, 7]] += [0.5, 0.2]
    assert np.max(np.abs(no_shear @ alternative - no_shear @ theta)) < 1e-13
    recovered = np.linalg.lstsq(all_modes, stress.reshape(-1), rcond=None)[0]
    parameter_error = float(np.max(np.abs(recovered - theta)))
    assert parameter_error < 1e-12

    # Positive C and D: pointwise material power = storage rate + loss.
    storage_rate = np.einsum("ni,ij,nj->n", strain, c, rate)
    loss = np.einsum("ni,ij,nj->n", rate, d, rate)
    power = np.sum(stress * rate, axis=1)
    assert np.all(loss >= 0)
    tensor_residual = float(np.max(np.abs(power - storage_rate - loss)))
    assert tensor_residual < 1e-13

    # Separate measurement-geometry illustration, not a material-parameter fit.
    # A new independently measured y/z projection can reveal a missing z component.
    hxy = np.array([[1., 0, 0], [0, 1., 0]])
    hyz = np.array([[0, 1., 0], [0, 0, 1.]])
    screen_rotation = np.array([[0., -1], [1., 0]])
    geometry = {
        "single_xy_projection_rank": int(np.linalg.matrix_rank(hxy)),
        "same_projection_reexpressed_rank": int(np.linalg.matrix_rank(np.vstack((hxy, screen_rotation @ hxy)))),
        "independently_observed_xy_and_yz_rank": int(np.linalg.matrix_rank(np.vstack((hxy, hyz)))),
        "scope": "Idealized displacement projectors; an additional encoded component is assumed, not supplied by rotating an image.",
    }
    assert list(geometry.values())[:3] == [2, 2, 3]

    q = np.exp(time)
    collinear = np.column_stack((q, q))  # qdot = q / t_ref
    pair_a, pair_b = np.array([2., 3.]), np.array([3., 2.])
    assert np.max(np.abs(collinear @ pair_a - collinear @ pair_b)) < 1e-13
    # If the load scale is unknown, scaling C,D and the stress preserves strain.
    alpha = 2.5
    scaled_stress = strain @ (alpha * c).T + rate @ (alpha * d).T
    assert np.max(np.abs(scaled_stress - alpha * stress)) < 1e-13

    results = {
        "model": "Illustrative planar orthotropic Kelvin-Voigt; not a fitted myocardial constitutive law or four independent pixel sides.",
        "parameter_order": PARAMETER_NAMES,
        "normalization": {
            "strain_reference": 0.01, "stress_reference_Pa": 100.0, "time_reference_s": 1.0,
            "elastic_coefficient_reference_Pa": 10000.0,
            "viscous_coefficient_reference_Pa_s": 10000.0,
            "note": "All design-matrix and parameter values are nondimensional; shear strain is engineering gamma_xy=2*eps_xy.",
        },
        "true_coefficients": theta.tolist(), "recovered_coefficients": recovered.tolist(),
        "elastic_matrix_eigenvalues": np.linalg.eigvalsh(c).tolist(),
        "viscous_matrix_eigenvalues": np.linalg.eigvalsh(d).tolist(),
        "no_shear": no_shear_summary,
        "same_no_shear_data_plus_90_degree_reexpression": repeated_summary,
        "independent_normal_shear_and_rate_histories": full_summary,
        "maximum_recovery_error": parameter_error,
        "no_shear_invisible_parameters": ["C66", "D66"],
        "maximum_tensor_power_residual": tensor_residual,
        "single_KV_collinear_history_rank": spectrum(collinear)["rank"],
        "single_KV_indistinguishable_pairs": [pair_a.tolist(), pair_b.tolist()],
        "unknown_stress_scale_factor_example": alpha,
        "observation_geometry": geometry,
        "scope": "Known synthetic stresses AND strains/rates. This is not inversion of MRI displacements, not an uncertainty analysis, and not a global nonlinear identifiability proof.",
    }
    return results, {"theta": theta, "recovered": recovered}


def figure(graph: dict, drawing: dict, inverse: dict, fitted: dict):
    fig, axes = plt.subplots(2, 3, figsize=(16, 9), constrained_layout=True)
    for ax, label, title in [(axes[0, 0], "four_neighbor", "Axial square grid"),
                             (axes[0, 1], "with_diagonals", "Grid with both diagonals")]:
        points, links, _ = drawing[label]
        deformed = points + np.column_stack((0.35 * points[:, 1], np.zeros(len(points))))
        for number, (i, j) in enumerate(links):
            ax.plot(points[[i, j], 0], points[[i, j], 1], color="0.75", lw=1,
                    label="Reference" if number == 0 else None)
            ax.plot(deformed[[i, j], 0], deformed[[i, j], 1], color="#1a6784", lw=1.5,
                    label="Shear displacement (magnified)" if number == 0 else None)
        ax.scatter(deformed[:, 0], deformed[:, 1], color="#1a6784", s=16)
        ax.set_aspect("equal")
        ax.set_title(title)
        ax.set_xlabel("Reference x / domain width")
        ax.set_ylabel("Reference y / domain height")
        ax.legend(fontsize=8, loc="upper left")
    ax = axes[0, 2]
    x = np.arange(2)
    for offset, label, title, color in [(-0.18, "four_neighbor", "Axial", "#b15b43"),
                                       (0.18, "with_diagonals", "Diagonals", "#1a6784")]:
        ax.bar(x + offset, [graph[label]["energy"]["extension"], graph[label]["energy"]["shear"]],
               width=0.36, label=title, color=color)
    ax.set_xticks(x, ["Extension", "Shear"])
    ax.set_ylabel("Stored energy / chosen reference energy")
    ax.set_title("Same small deformation amplitude: 0.1")
    ax.legend()
    ax = axes[1, 0]
    for label, title, color in [("four_neighbor", "Axial: 6 zero modes", "#b15b43"),
                                 ("with_diagonals", "Diagonals: 3 zero modes", "#1a6784")]:
        eigenvalues = np.linalg.eigvalsh(drawing[label][2])
        ax.semilogy(np.arange(1, len(eigenvalues) + 1), np.maximum(eigenvalues, 1e-15),
                    "o-", ms=4, label=title, color=color)
    ax.set_xlabel("Eigenvalue index")
    ax.set_ylabel("Stiffness eigenvalue (floor shown at 1e-15)")
    ax.set_title("Unconstrained grid: rigidity matters")
    ax.legend(fontsize=8)
    ax = axes[1, 1]
    ranks = [inverse["no_shear"]["rank"],
             inverse["same_no_shear_data_plus_90_degree_reexpression"]["rank"],
             inverse["independent_normal_shear_and_rate_histories"]["rank"]]
    ax.bar(range(3), ranks, color=["#b15b43", "#b15b43", "#1a6784"])
    ax.axhline(8, color="0.4", ls="--", lw=1)
    ax.set_xticks(range(3), ["Normal modes\n(no shear)", "+ 90-degree\nre-expression", "+ independent\nshear history"])
    ax.set_ylim(0, 9)
    ax.set_yticks(range(0, 9, 2))
    ax.set_ylabel("Numerical design-matrix rank / 8 unknowns")
    ax.set_title("More displayed views need not add information")
    ax = axes[1, 2]
    x = np.arange(8)
    ax.bar(x - 0.18, fitted["theta"], 0.36, label="Known synthetic value", color="0.65")
    ax.bar(x + 0.18, fitted["recovered"], 0.36, label="Recovered with all modes", color="#1a6784")
    ax.set_xticks(x, PARAMETER_NAMES, rotation=45)
    ax.set_ylabel("Nondimensional material coefficient")
    ax.set_title("Exact, noise-free fit with known stress")
    ax.legend(fontsize=8)
    fig.suptitle("Voxel-method precursor: synthetic 2D mechanics and parameter identification", fontsize=16)
    return fig


def run_exploration(save: bool = True) -> tuple[dict, object]:
    """Run every numerical assertion and return the report and Matplotlib figure."""
    graph, drawing = graph_checks()
    voxel3d = voxel_topology_checks()
    inverse, fitted = inverse_checks()
    report = {
        "status": "Under investigation",
        "evidence_kind": "Deterministic synthetic numerical experiment; not a formal proof or physiological validation.",
        "environment": {"python": platform.python_version(), "numpy": np.__version__,
                        "matplotlib": matplotlib.__version__},
        "graph": graph,
        "voxel_topology_3d": voxel3d,
        "inverse": inverse,
        "limitations": [
            "Planar material/network precursor plus a 3D connectivity sanity check; no 3D constitutive voxel model, MRI import, segmentation, or registration.",
            "Lattice calibration and orthotropic continuum example are separate project choices.",
            "No patient data, fitted biological parameters, active contraction, or tissue validation.",
            "No finite-rotation invariance, arbitrary-mask rigidity theorem, or continuum convergence result.",
            "No dynamic time integration, numerical stability proof, or Maxwell parameter-recovery experiment.",
            "Pointwise power checks use supplied consistent rates, not a proved trajectory or integrated inequality.",
            "The eight-parameter fit assumes known stresses and strain/rate histories, unlike a full MRI inverse problem.",
            "No measurement-noise study, unknown-reference estimation, or global nonlinear uniqueness proof.",
        ],
    }
    fig = figure(graph, drawing, inverse, fitted)
    if save:
        plot = ROOT / "docs/assets/voxel-method.png"
        results = ROOT / "docs/research/voxel-method-results.json"
        plot.parent.mkdir(parents=True, exist_ok=True)
        results.parent.mkdir(parents=True, exist_ok=True)
        fig.savefig(plot, dpi=160)
        results.write_text(json.dumps(report, indent=2, sort_keys=True, allow_nan=False) + "\n")
    return report, fig


if __name__ == "__main__":
    report, fig = run_exploration()
    print(json.dumps({
        "grid_free_nullities": {key: report["graph"][key]["free_stiffness"]["nullity"]
                                for key in ["four_neighbor", "with_diagonals"]},
        "grid_constrained_nullities": {key: report["graph"][key]["constrained_stiffness"]["nullity"]
                                       for key in ["four_neighbor", "with_diagonals"]},
        "3d_free_nullities": {key: report["voxel_topology_3d"][key]["free_stiffness"]["nullity"]
                               for key in ["six_neighbor", "face_and_body_diagonals"]},
        "3d_constrained_nullities": {key: report["voxel_topology_3d"][key]["constrained_stiffness"]["nullity"]
                                      for key in ["six_neighbor", "face_and_body_diagonals"]},
        "inverse_ranks": [report["inverse"][key]["rank"] for key in ["no_shear", "same_no_shear_data_plus_90_degree_reexpression", "independent_normal_shear_and_rate_histories"]],
        "max_parameter_error": report["inverse"]["maximum_recovery_error"],
        "observation_geometry": report["inverse"]["observation_geometry"],
    }, indent=2))
    plt.close(fig)
