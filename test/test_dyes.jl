old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Dyes")
tmpstem = Pkg.dir("Stan", "Examples", "Dyes", "tmp", "dyes")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

include(Pkg.dir("Stan", "test", "test_utils.jl"))

clean_dir(tmpstem, 4)

include(Pkg.dir(ProjDir, "dyes.jl"))

clean_dir(tmpstem, 4)

isdir("tmp") && rm("tmp", recursive=true)

cd(old);