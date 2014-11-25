old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "EightSchools")
cd(ProjDir)
println("Switched to directory: $(ProjDir)")

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(Pkg.dir(ProjDir, "schools8.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

cd(old);