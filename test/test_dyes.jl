ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Mamba", "Dyes")
cd(ProjDir) do

  isdir("tmp") &&
    rm("tmp", recursive=true);

  include(joinpath(ProjDir, "dyes.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

end # cd
