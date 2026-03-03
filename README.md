# friendly-rotary-phone (Python + Jupyter + uv)

Thesis-inspired ETS implementation in Python, with Jupyter notebooks for exploration.

## What is implemented

- ETS core domain model:
  - primitives
  - temporal structs (graph-like)
  - active constraints
- Class representation + struct-generating finite-state machine
- Deterministic transducer for symbolic spatial program emission
- Algorithm helpers:
  - struct linking
  - primitive attachment
  - single-level substruct extraction
  - partial-order cycle check
- Graphviz DOT export for machine visualization

## Project layout

- `pyproject.toml` — uv-managed project config
- `src/friendly_rotary_phone/ets.py` — core ETS + FSM + transducer
- `src/friendly_rotary_phone/examples.py` — Bubble Man example definitions
- `src/friendly_rotary_phone/algorithms.py` — thesis-inspired helper algorithms
- `src/friendly_rotary_phone/graphviz.py` — DOT export
- `tests/test_ets.py` — pytest suite
- `notebooks/01_ets_starter.ipynb` — starter walkthrough

## Quick start

```bash
cd friendly-rotary-phone
uv sync
uv run pytest
uv run jupyter lab
```

Then open `notebooks/01_ets_starter.ipynb`.

## Notes

- This repo is now fully Python/Jupyter based.
- Elixir/Livebook implementation was intentionally removed as part of the reset.
