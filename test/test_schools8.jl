ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "NoMamba", "EightSchools")
cd(ProjDir) do

  isdir("tmp") &&
    rm("tmp", recursive=true);

  include(joinpath(ProjDir, "schools8.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

end # cd
