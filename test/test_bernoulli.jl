old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Bernoulli")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

for i in 1:8
  isfile("bernoulli_$(i).data.R") && rm("bernoulli_$(i).data.R")
  isfile("bernoulli_samples_$(i).csv") && rm("bernoulli_samples_$(i).csv")
  isfile("bernoulli_diagnostics_$(i).csv") && rm("bernoulli_diagnostics_$(i).csv")
  isfile("bernoulli_optimize_$(i).csv") && rm("bernoulli_optimize_$(i).csv")
  isfile("bernoulli_diagnose_$(i).csv") && rm("bernoulli_diagnose_$(i).csv")
end
isfile("bernoulli.cpp") && rm("bernoulli.cpp")
isfile("bernoulli.stan") && rm("bernoulli.stan")
isfile("bernoulli") && rm("bernoulli")
isfile("bernoulli_build.log") && rm("bernoulli_build.log")
isfile("bernoulli_run.log") && rm("bernoulli_run.log")

include(Pkg.dir(ProjDir, "bernoulli.jl"))
for i in 1:8
  isfile("bernoulli_$(i).data.R") && rm("bernoulli_$(i).data.R")
  isfile("bernoulli_samples_$(i).csv") && rm("bernoulli_samples_$(i).csv")
  isfile("bernoulli_diagnostics_$(i).csv") && rm("bernoulli_diagnostics_$(i).csv")
end

include(Pkg.dir(ProjDir, "bernoulli_optimize.jl"))
for i in 1:8
  isfile("bernoulli_$(i).data.R") && rm("bernoulli_$(i).data.R")
  isfile("bernoulli_optimize_$(i).csv") && rm("bernoulli_optimize_$(i).csv")
end

include(Pkg.dir(ProjDir, "bernoulli_diagnose.jl"))
for i in 1:8
  isfile("bernoulli_$(i).data.R") && rm("bernoulli_$(i).data.R")
  isfile("bernoulli_diagnose_$(i).csv") && rm("bernoulli_diagnose_$(i).csv")
end

isfile("bernoulli.stan") && rm("bernoulli.stan")
isfile("bernoulli.cpp") && rm("bernoulli.cpp")
isfile("bernoulli") && rm("bernoulli")
isfile("bernoulli_build.log") && rm("bernoulli_build.log")
isfile("bernoulli_run.log") && rm("bernoulli_run.log")

cd(old);