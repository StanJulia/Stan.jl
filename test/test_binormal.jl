ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "NoMamba", "Binormal")
cd(ProjDir) do

  isdir("tmp") &&
    rm("tmp", recursive=true);

  include(joinpath(ProjDir, "binormal.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

end # cd
