old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Bernoulli")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(Pkg.dir(ProjDir, "bernoulli.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(Pkg.dir(ProjDir, "bernoulli_optimize.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(Pkg.dir(ProjDir, "bernoulli_diagnose.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

cd(old)