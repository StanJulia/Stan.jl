old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Binormal")
tmpstem = Pkg.dir("Stan", "Examples", "Binormal", "tmp", "binormal")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

include(Pkg.dir("Stan", "test", "test_utils.jl"))

clean_dir(tmpstem, 4)

include(Pkg.dir(ProjDir, "binormal.jl"))

clean_dir(tmpstem, 4)

isdir("tmp") && rm("tmp", recursive=true)

cd(old);