"""Run the Hill notebook from a fresh kernel and save its outputs."""
from pathlib import Path
import os
import sys

import nbformat
from nbclient import NotebookClient

# Ensure the kernel uses the same virtual environment as this runner.
os.environ["PATH"] = str(Path(sys.executable).parent) + os.pathsep + os.environ["PATH"]
path = Path(__file__).resolve().with_name("hill-exploration.ipynb")
notebook = nbformat.read(path, as_version=4)
nbformat.validate(notebook)
NotebookClient(
    notebook, timeout=120, kernel_name="python3",
    resources={"metadata": {"path": str(path.parent)}},
).execute()
nbformat.write(notebook, path)
print("Hill notebook executed successfully; outputs and chapter figure updated.")
