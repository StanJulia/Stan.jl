ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "NoMamba", "BernoulliScalar")
cd(ProjDir) do

  isdir("tmp") &&
    rm("tmp", recursive=true);

  include(joinpath(ProjDir, "bernoulliscalar.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

end # cd
