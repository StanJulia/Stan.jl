old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Bernoulli")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

include(Pkg.dir("Stan", "test", "test_utils.jl"))

clean_dir("bernoulli", 4)

include(Pkg.dir(ProjDir, "bernoulli.jl"))

clean_dir("bernoulli", 4, all=false)

include(Pkg.dir(ProjDir, "bernoulli_optimize.jl"))

clean_dir("bernoulli", 4, all=false)

include(Pkg.dir(ProjDir, "bernoulli_diagnose.jl"))

clean_dir("bernoulli", 4)
cd(old);