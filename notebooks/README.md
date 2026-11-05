# Exploration notebooks

Start with [the Hill chapter](../docs/models/Hill.md), then open
[hill-exploration.ipynb](hill-exploration.ipynb). Saved outputs make the notebook
readable on GitHub without starting a kernel. Parameters are synthetic examples;
plots and numerical assertions are not experimental evidence or formal proofs.

## Run on your machine or on Proxmox

From the repository root, create a separate environment (Python 3.13.5 was used
for the initial check):

```bash
python3 -m venv .venv-notebooks
.venv-notebooks/bin/python -m pip install -r notebooks/requirements.txt
.venv-notebooks/bin/python notebooks/execute.py
```

The runner starts a fresh Python kernel, executes every cell, and saves outputs
only after successful execution. It also regenerates
`docs/assets/hill-force-velocity.png`. Review that image and notebook outputs
when committing parameter changes. The three direct Python package versions
are pinned; transitive package versions are not locked.

For interactive editing, open the notebook in an existing Jupyter interface or
VS Code with its Jupyter extension, select this virtual environment as the kernel,
and use **Restart kernel and run all**. No notebook web server is started by the
commands above. The Lean build works without these optional Python packages.

The illustrative Python function checks the documented domain. It is not extracted
from Lean; keeping the formulas aligned requires review. Notebook execution does
not run Lean. To check the formal library separately:

```bash
lake exe cache get
lake build
```

Execution uses [NBClient](https://nbclient.readthedocs.io/en/latest/client.html);
figures use [Matplotlib](https://matplotlib.org/stable/).

## Windkessel follow-up

[windkessel-exploration.ipynb](windkessel-exploration.ipynb) studies a zero-inflow
pressure curve, equal-RC parameter pairs, and forward-Euler time steps. Read
[the model chapter](../docs/models/Windkessel.md) for sources and assumptions.
Using the same optional environment, execute it with:

```bash
.venv-notebooks/bin/python notebooks/execute.py windkessel-exploration.ipynb
```

This regenerates `docs/assets/windkessel-exploration.png`. The default command
without a notebook argument still executes the Hill notebook.

## Constant-input follow-up

[windkessel-constant-inflow.ipynb](windkessel-constant-inflow.ipynb) explores rising,
falling, and equilibrium curves, nonzero-input Euler steps, and a specific
equal-RC parameter comparison. Read [Chapter 3](../docs/models/WindkesselConstant.md)
for the conditional uniqueness proof and its assumptions. Run:

```bash
.venv-notebooks/bin/python notebooks/execute.py windkessel-constant-inflow.ipynb
```

This regenerates `docs/assets/windkessel-constant-inflow.png`. Numerical checks
do not prove uniqueness or general parameter identifiability.

## Passive stretching

[passive-viscoelasticity.ipynb](passive-viscoelasticity.ipynb) compares basic hold
and creep responses, a finite ramp–hold–return for a candidate parallel network,
pointwise power identities, harmonic loop areas, and the source-audit example.
Read [Chapter 4](../docs/models/PassiveViscoelasticity.md) and
[the unresolved source discrepancy](../docs/research/002-viscoelastic-source-audit.md).
Using the same optional environment:

```bash
.venv-notebooks/bin/python notebooks/execute.py passive-viscoelasticity.ipynb
```

This regenerates `docs/assets/passive-viscoelasticity.png`. Values are synthetic.
Ramp corners are excluded from ordinary-derivative power checks. The integrated
loop-area and complex-modulus formulas are not yet Lean theorems.
