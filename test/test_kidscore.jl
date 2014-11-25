old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "ARM", "Ch03", "Kid")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(Pkg.dir(ProjDir, "kidscore.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

cd(old);