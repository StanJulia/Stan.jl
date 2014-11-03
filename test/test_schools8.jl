old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "EightSchools")
cd(ProjDir)
println("Switched to directory: $(ProjDir)")

include(Pkg.dir("Stan", "test", "test_utils.jl"))

clean_dir("schools8", 4)

include(Pkg.dir(ProjDir, "schools8.jl"))

clean_dir("schools8", 4)

cd(old);