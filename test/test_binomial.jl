ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Binomial")
cd(ProjDir) do

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(joinpath(ProjDir, "binomial.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);


end # cd
