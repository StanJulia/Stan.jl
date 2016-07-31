ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "ARM", "Ch03", "Kid")
cd(ProjDir) do
println("Moving to directory: $(ProjDir)")

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(joinpath(ProjDir, "kidscore.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

end # cd
