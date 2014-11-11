old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "EightSchools")
tmpstem = Pkg.dir("Stan", "Examples", "EightSchools", "tmp", "kid")
cd(ProjDir)
println("Switched to directory: $(ProjDir)")

include(Pkg.dir("Stan", "test", "test_utils.jl"))

clean_dir(tmpstem, 4)

include(Pkg.dir(ProjDir, "schools8.jl"))

clean_dir(tmpstem, 4)

isdir("tmp") && rm("tmp", recursive=true)

cd(old);