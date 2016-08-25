ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "EightSchools")
cd(ProjDir) do

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(joinpath(ProjDir, "schools8.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

end # cd
