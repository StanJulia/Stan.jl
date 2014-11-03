old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Dyes")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

include(Pkg.dir("Stan", "test", "test_utils.jl"))

clean_dir("dyes", 4)

include(Pkg.dir(ProjDir, "dyes.jl"))

clean_dir("dyes", 4)

cd(old);