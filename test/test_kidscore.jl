old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "ARM", "Ch03", "Kid")
tmpstem = Pkg.dir("Stan", "Examples", "ARM", "Ch03", "Kid", "tmp", "kid")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

include(Pkg.dir("Stan", "test", "test_utils.jl"))

clean_dir(tmpstem, 4)

include(Pkg.dir(ProjDir, "kidscore.jl"))

clean_dir(tmpstem, 4)

isdir("tmp") && rm("tmp", recursive=true)

cd(old);