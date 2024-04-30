julia-all: julia-up julia-pkgs

alias install-julia := julia-up

# Install Julia
julia-up:
  #!/usr/bin/env sh
  echo "Installing Juliaup - Julia version manager..."
  if ! command -v juliaup; then
    curl -fsSL https://install.julialang.org | sh -s -- --yes
  fi

julia-pkgs:
  #!/usr/bin/env sh
  if command -v julia; then
    julia packages.jl
  else
    echo "Julia not installed. Skipping packages installation."
  fi

julia-pluto:
  #!/usr/bin/env julia
  import Pluto;
  Pluto.run()