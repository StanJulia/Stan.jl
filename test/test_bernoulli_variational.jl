ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "NoMamba", "Bernoulli")
cd(ProjDir) do

  isdir("tmp") &&
    rm("tmp", recursive=true);

  include(joinpath(ProjDir, "bernoulli_variational.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

  println()
  println()
  
end # cd
