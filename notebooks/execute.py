"""Run an exploration notebook from a fresh kernel and save its outputs."""
from pathlib import Path
import argparse
import os
import sys

import nbformat
from nbclient import NotebookClient

# Ensure the kernel uses the same virtual environment as this runner.
os.environ["PATH"] = str(Path(sys.executable).parent) + os.pathsep + os.environ["PATH"]
parser = argparse.ArgumentParser(description="Execute a CardioLean exploration notebook.")
parser.add_argument("notebook", nargs="?", default="hill-exploration.ipynb",
                    choices=["hill-exploration.ipynb", "windkessel-exploration.ipynb",
                             "windkessel-constant-inflow.ipynb", "passive-viscoelasticity.ipynb",
                             "voxel-method.ipynb"])
args = parser.parse_args()
path = Path(__file__).resolve().with_name(args.notebook)
notebook = nbformat.read(path, as_version=4)
nbformat.validate(notebook)
NotebookClient(
    notebook, timeout=120, kernel_name="python3",
    resources={"metadata": {"path": str(path.parent)}},
).execute()
nbformat.write(notebook, path)
print(f"{path.name} executed successfully; outputs and chapter figure updated.")
