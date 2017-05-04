ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "NoMamba", "BernoulliInitTheta")
cd(ProjDir) do

  isdir("tmp") &&
    rm("tmp", recursive=true);

  include(joinpath(ProjDir, "bernoulliinittheta.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

end # cd
