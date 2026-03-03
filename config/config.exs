import Config

# Configure EXLA as the default backend for Nx
# EXLA provides CPU and GPU acceleration for numerical computations
config :nx, :default_backend, EXLA.Backend

# EXLA compiler options
# - client: :host uses CPU, :cuda or :rocm for GPU
# - Set XLA_TARGET environment variable for specific targets
config :nx, :default_defn_options, compiler: EXLA

# Environment-specific configuration
import_config "#{config_env()}.exs"
