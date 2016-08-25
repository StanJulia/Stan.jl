ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Bernoulli")
cd(ProjDir) do

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(joinpath(ProjDir, "bernoulli.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(joinpath(ProjDir, "bernoulli_optimize.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(joinpath(ProjDir, "bernoulli_diagnose.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(joinpath(ProjDir, "bernoulli_variational.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

end # cd
