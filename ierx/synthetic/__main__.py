"""Command line: ``python -m ierx.synthetic --people 200 --seed 4950``."""

from pathlib import Path
import shutil

from loguru import logger
import typer

from ierx.config import RAW_DATA_DIR
from ierx.synthetic.generator import DEFAULT_PEOPLE, DEFAULT_SEED, MIN_PEOPLE, generate
from ierx.synthetic.writers import write_fixture

app = typer.Typer(add_completion=False)
GENERATED = ("README.md", "load_local.sh", "load", "extracts", "evaluation", "invalid")


@app.command()
def main(
    people: int = typer.Option(DEFAULT_PEOPLE, min=MIN_PEOPLE, help="Fictional people to create."),
    seed: int = typer.Option(
        DEFAULT_SEED, help="Random seed; the same seed gives the same files."
    ),
    out: Path = typer.Option(RAW_DATA_DIR / "synthetic", help="Output folder."),
    overwrite: bool = typer.Option(False, help="Replace files from an earlier run in OUT."),
):
    """Generate synthetic CBS and IMS seed data with a separate answer key."""
    if out.exists() and any(out.iterdir()):
        if not overwrite:
            raise typer.BadParameter(f"{out} is not empty; pass --overwrite to replace it")
        for name in GENERATED:
            target = out / name
            if target.is_dir():
                shutil.rmtree(target)
            elif target.exists():
                target.unlink()
    logger.info(f"Generating {people} people with seed {seed}")
    meta = write_fixture(generate(people, seed), out, people)
    for key, n in meta["row_counts"].items():
        logger.info(f"{key}: {n} rows")
    logger.success(f"Wrote synthetic seed data to {out}")


if __name__ == "__main__":
    app()
