# friendly-rotary-phone (Python + Jupyter reset)

Clean reset of the project to a Python workflow managed by **uv**.

## Quick start

```bash
# from repo root
uv sync
uv run python -m ipykernel install --user --name friendly-rotary-phone --display-name "friendly-rotary-phone"
uv run jupyter lab
```

Open the notebooks in `notebooks/`.

## Project layout

- `pyproject.toml` — project + dependency config (uv)
- `src/friendly_rotary_phone/` — Python package
- `notebooks/` — Jupyter notebooks
- `tests/` — pytest tests

## Common commands

```bash
uv sync
uv run pytest
uv run ruff check .
uv run jupyter lab
```

## Notes

- This replaces the previous Elixir/Livebook setup.
- If you want to preserve old work, use git history (`git log`, `git checkout <commit>`).
