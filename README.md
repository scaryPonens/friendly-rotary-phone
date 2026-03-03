# ML Lab - Elixir Machine Learning Project

A beginner-friendly Elixir project for machine learning workflows using Nx, EXLA, and Explorer with Livebook integration.

## Overview

This project provides a complete setup for machine learning development in Elixir with:

It now also includes an **ETS-inspired thesis reimplementation track** (temporal structs, active constraints, finite-state struct generation) under `lib/ml_lab/ets/`, designed to be explored from Livebook.
- **Nx**: Numerical computing library for multi-dimensional arrays and automatic differentiation
- **EXLA**: Accelerated Linear Algebra compiler (Google XLA) for Nx with CPU/GPU support
- **Explorer**: Fast dataframes for data manipulation and analysis
- **Livebook**: Interactive notebook environment (Jupyter-equivalent for Elixir)
- **Kino**: Interactive widgets and visualizations for Livebook
- **VegaLite**: Declarative data visualization

## Prerequisites

### Required

- **Elixir 1.16.x** or later (1.14+ supported, 1.16+ recommended)
- **Erlang/OTP 26.x** or later (OTP 25+ supported, OTP 26+ recommended)

### Recommended

- **asdf** or **mise** for version management
- **Git** for version control

### Installation

#### Using asdf

```bash
# Install asdf plugins
asdf plugin add erlang
asdf plugin add elixir

# Install specified versions (from .tool-versions)
asdf install

# Verify installation
elixir --version
```

#### Using mise (modern alternative to asdf)

```bash
# Install from .mise.toml
mise install

# Verify installation
elixir --version
```

#### Manual Installation

See official guides:
- Elixir: https://elixir-lang.org/install.html
- Erlang: https://www.erlang.org/downloads

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd friendly-rotary-phone
```

### 2. Install Dependencies

```bash
mix deps.get
```

**Note on EXLA Compilation**: The first time you install EXLA, it may take 10-30 minutes to compile XLA from source. Subsequent installs are cached.

### 3. Verify Installation

```bash
mix test
```

### 4. Format Check

```bash
mix format --check-formatted
```

## Working with Notebooks

### Installing Livebook

```bash
# Install Livebook as an Escript
mix escript.install hex livebook

# Or use Livebook Desktop (recommended for beginners)
# Download from: https://livebook.dev/
```

### Starting Livebook

#### Option 1: Livebook CLI

```bash
livebook server
```

Then open http://localhost:8080 in your browser.

#### Option 2: Livebook Desktop

1. Open Livebook Desktop
2. Navigate to the `notebooks/` folder in this project
3. Open `getting_started.livemd`

### Example Notebooks

- **`notebooks/getting_started.livemd`**: Complete tutorial covering:
  - Loading and manipulating data with Explorer dataframes
  - Data visualization with VegaLite
  - Building a simple linear regression model with Nx
  - Working with tensors and numerical operations
- **`notebooks/ets_intro.livemd`**: ETS thesis-inspired walkthrough:
  - Temporal struct generation with a finite-state machine
  - Active-constraint extension steps
  - Primitive/link inspection via Explorer dataframes

### Creating New Notebooks

```bash
# In the notebooks/ folder, create a new .livemd file
touch notebooks/my_experiment.livemd
```

Then edit it with Livebook or any text editor (Livebook notebooks are markdown files).

## Project Structure

```
ml_lab/
├── config/
│   ├── config.exs          # EXLA backend configuration
│   ├── dev.exs             # Development settings
│   ├── test.exs            # Test settings
│   └── prod.exs            # Production settings
├── lib/
│   ├── ml_lab.ex           # Main module
│   └── ml_lab/
│       ├── application.ex  # OTP application
│       └── ets/            # ETS reimplementation modules
├── notebooks/
│   ├── getting_started.livemd  # ML/Nx example notebook
│   └── ets_intro.livemd       # ETS walkthrough notebook
├── test/
│   ├── test_helper.exs
│   └── ml_lab_test.exs
├── .formatter.exs          # Code formatter config
├── .gitignore
├── .tool-versions          # asdf version pinning
├── .mise.toml              # mise version pinning
├── mix.exs                 # Project dependencies
└── README.md
```

## EXLA Backend Configuration

### CPU vs GPU

By default, EXLA uses the CPU backend. To use GPU acceleration:

#### CUDA (NVIDIA GPUs)

```bash
# Set before running
export XLA_TARGET=cuda118  # or cuda120 for CUDA 12.0
mix deps.compile exla --force
```

#### ROCm (AMD GPUs)

```bash
export XLA_TARGET=rocm
mix deps.compile exla --force
```

### Configuration Options

Edit `config/config.exs` to customize:

```elixir
# Use EXLA as default backend
config :nx, :default_backend, EXLA.Backend

# Or use a specific backend
config :nx, :default_backend, {EXLA.Backend, client: :cuda}
```

### Troubleshooting EXLA

If EXLA fails to compile:
1. Ensure you have a C++ compiler (gcc/clang)
2. Ensure you have Python 3 installed
3. Check the [EXLA docs](https://hexdocs.pm/exla) for platform-specific instructions

## Development

### Running Tests

```bash
# Run all tests
mix test

# Run specific test file
mix test test/ml_lab_test.exs

# Run with coverage
mix test --cover
```

### Code Formatting

```bash
# Format all code
mix format

# Check if code is formatted
mix format --check-formatted
```

### Interactive Shell

```bash
# Start IEx with project loaded
iex -S mix
```

Example session:
```elixir
iex> Nx.tensor([1, 2, 3])
#Nx.Tensor<
  s64[3]
  [1, 2, 3]
>
```

## Continuous Integration

This project includes GitHub Actions workflow for:
- ✅ Code formatting validation
- ✅ Running test suite
- ✅ Elixir/OTP version matrix testing

See `.github/workflows/ci.yml` for details.

## Common Tasks

### Adding New Dependencies

1. Add to `mix.exs`:
```elixir
{:new_package, "~> 1.0"}
```

2. Install:
```bash
mix deps.get
```

### Creating a New Module

```bash
# Create a new module file
touch lib/ml_lab/my_module.ex
```

### Loading CSV Data

```elixir
# In a Livebook notebook or IEx
alias Explorer.DataFrame, as: DF

df = DF.from_csv!("path/to/data.csv")
DF.head(df)
```

## Learning Resources

### Official Documentation

- [Nx](https://hexdocs.pm/nx): Numerical computing
- [EXLA](https://hexdocs.pm/exla): Compiler backend
- [Explorer](https://hexdocs.pm/explorer): Dataframes
- [Livebook](https://livebook.dev): Interactive notebooks
- [Kino](https://hexdocs.pm/kino): Notebook widgets

### Tutorials & Examples

- [Nx Guides](https://hexdocs.pm/nx/intro-to-nx.html)
- [Machine Learning in Elixir](https://pragprog.com/titles/smelixir/machine-learning-in-elixir/)
- [Livebook Samples](https://github.com/livebook-dev/livebook/tree/main/priv/samples)

## GPU Support (Optional)

### NVIDIA CUDA Setup

1. Install NVIDIA drivers and CUDA toolkit (11.8 or 12.0)
2. Set environment variable:
```bash
export XLA_TARGET=cuda118
```
3. Recompile EXLA:
```bash
mix deps.clean exla --build
mix deps.get
```

### AMD ROCm Setup

1. Install ROCm drivers and toolkit
2. Set environment variable:
```bash
export XLA_TARGET=rocm
```
3. Recompile EXLA:
```bash
mix deps.clean exla --build
mix deps.get
```

### Verifying GPU Usage

```elixir
# In IEx or Livebook
Nx.default_backend(EXLA.Backend)
EXLA.Client.get_supported_platforms()
# Should list :cuda or :rocm if available
```

## Troubleshooting

### Dependencies won't compile

```bash
# Clean and retry
mix deps.clean --all
mix deps.get
mix deps.compile
```

### EXLA compilation timeout

EXLA can take a long time to compile. Be patient or use pre-built binaries:
```bash
export ELIXIR_MAKE_TAR=https://github.com/elixir-nx/exla/releases/download/v0.6.0/exla-<target>.tar.gz
```

### Livebook can't find dependencies

Make sure to run Livebook from the project directory, or use `Mix.install/1` in the notebook.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `mix test`
5. Format code: `mix format`
6. Submit a pull request

## License

This project is licensed under the terms of the LICENSE file included in the repository.

## Acknowledgments

Built with:
- [Nx](https://github.com/elixir-nx/nx) - Numerical Elixir
- [EXLA](https://github.com/elixir-nx/nx/tree/main/exla) - XLA compiler
- [Explorer](https://github.com/elixir-explorer/explorer) - DataFrames
- [Livebook](https://github.com/livebook-dev/livebook) - Interactive notebooks
