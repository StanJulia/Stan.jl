ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Dyes")
cd(ProjDir) do
println("Moving to directory: $(ProjDir)")

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(joinpath(ProjDir, "dyes.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

end # cd
