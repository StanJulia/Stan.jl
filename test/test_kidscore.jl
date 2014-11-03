old = pwd()
ProjDir = Pkg.dir("Stan", "Examples","ARM", "Ch03", "Kid")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

include(Pkg.dir("Stan", "test", "test_utils.jl"))

clean_dir("kid", 4)

include(Pkg.dir(ProjDir, "kidscore.jl"))

clean_dir("kid", 4)

cd(old);