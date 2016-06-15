old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Binomial")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(Pkg.dir(ProjDir, "binomial.jl"))

cd(old)
