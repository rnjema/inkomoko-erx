"""Synthetic CBS and IMS customer fixtures for the identity matching pipeline."""

from ierx.synthetic.generator import Fixture, generate
from ierx.synthetic.writers import write_fixture

__all__ = ["Fixture", "generate", "write_fixture"]
