from pathlib import Path

from .generator import Generator


def make_sphinxdoc(game, out_dir: Path) -> None:
    """Generate the Sphinx documentation of a game"""

    gen = Generator('sphinxdoc', game=game, out_dir=out_dir)
    gen.template('api.rst')
