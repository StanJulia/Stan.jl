ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "NoMamba", "ARM", "Ch03", "Kid")
cd(ProjDir) do

  isdir("tmp") &&
    rm("tmp", recursive=true);

  include(joinpath(ProjDir, "kidscore.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

end # cd
