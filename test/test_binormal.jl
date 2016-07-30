ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Binormal")
cd(ProjDir) do
println("Moving to directory: $(ProjDir)")

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(joinpath(ProjDir, "binormal.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

end # cd
