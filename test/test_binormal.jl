old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Binormal")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

include(Pkg.dir("Stan", "test", "test_utils.jl"))

clean_dir("binormal", 4)

include(Pkg.dir(ProjDir, "binormal.jl"))

clean_dir("binormal", 4)

cd(old);