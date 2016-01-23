using BinDeps

@BinDeps.setup
cmdstan = library_dependency("cmdstan")

@osx_only begin
    if Pkg.installed("Homebrew") === nothing
        error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
    end
    
    using Homebrew
    provides( Homebrew.HB, "cmdstan", cmdstan, os = :Darwin )
end
