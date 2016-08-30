using BinDeps

@BinDeps.setup
cmdstan = library_dependency("cmdstan")

function install_cmdstan()
  if Pkg.installed("Homebrew") === nothing
      error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
  end
  
  using Homebrew
  provides( Homebrew.HB, "homebrew/science/cmdstan", cmdstan, os = :Darwin )
end  
  
@static is_apple() ? install_cmdstan() : Nothing
