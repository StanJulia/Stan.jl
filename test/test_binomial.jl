ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Mamba", "Binomial")
cd(ProjDir) do

  isdir("tmp") &&
    rm("tmp", recursive=true);

  include(joinpath(ProjDir, "binomial.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

end # cd
