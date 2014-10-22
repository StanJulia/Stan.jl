old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Dyes")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

for i in 1:8
  isfile("dyes_$(i).data.R") && rm("dyes_$(i).data.R")
  isfile("dyes_samples_$(i).csv") && rm("dyes_samples_$(i).csv")
  isfile("dyes_diagnostics_$(i).csv") && rm("dyes_diagnostics_$(i).csv")
  isfile("dyes_optimize_$(i).csv") && rm("dyes_optimize_$(i).csv")
  isfile("dyes_diagnose_$(i).csv") && rm("dyes_diagnose_$(i).csv")
end
isfile("dyes.cpp") && rm("dyes.cpp")
isfile("dyes.stan") && rm("dyes.stan")
isfile("dyes") && rm("dyes")
isfile("dyes_build.log") && rm("dyes_build.log")
isfile("dyes_run.log") && rm("dyes_run.log")

include("$(ProjDir)/dyes.jl")
for i in 1:8
  isfile("dyes_$(i).data.R") && rm("dyes_$(i).data.R")
  isfile("dyes_samples_$(i).csv") && rm("dyes_samples_$(i).csv")
  isfile("dyes_diagnostics_$(i).csv") && rm("dyes_diagnostics_$(i).csv")
end
isfile("dyes.stan") && rm("dyes.stan")
isfile("dyes.cpp") && rm("dyes.cpp")
isfile("dyes") && rm("dyes")
isfile("dyes_build.log") && rm("dyes_build.log")
isfile("dyes_run.log") && rm("dyes_run.log")

cd(old);