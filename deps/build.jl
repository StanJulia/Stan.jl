using BinDeps
  
@BinDeps.setup
cmdstan = library_dependency("homebrew/science/cmdstan")

if Sys.isapple()
    using Homebrew
    
    provides(Homebrew.HB, "homebrew/science/cmdstan", cmdstan, os = :Darwin)
end
