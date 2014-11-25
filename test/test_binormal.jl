old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Binormal")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(Pkg.dir(ProjDir, "binormal.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

cd(old);