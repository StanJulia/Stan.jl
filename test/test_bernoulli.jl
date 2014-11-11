old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Bernoulli")
tmpstem = Pkg.dir("Stan", "Examples", "Bernoulli", "tmp", "bernoulli")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

include(Pkg.dir("Stan", "test", "test_utils.jl"))

clean_dir(tmpstem, 4)

include(Pkg.dir(ProjDir, "bernoulli.jl"))

clean_dir(tmpstem, 4, all=false)

include(Pkg.dir(ProjDir, "bernoulli_optimize.jl"))

clean_dir(tmpstem, 4, all=false)

include(Pkg.dir(ProjDir, "bernoulli_diagnose.jl"))

clean_dir(tmpstem, 4)

isdir("tmp") && rm("tmp", recursive=true)

cd(old)