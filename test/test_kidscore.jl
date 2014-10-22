old = pwd()
ProjDir = Pkg.dir("Stan", "Examples","ARM", "Ch03", "Kid")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

for i in 1:8
  isfile("kid_$(i).data.R") && rm("kid_$(i).data.R")
  isfile("kid_samples_$(i).csv") && rm("kid_samples_$(i).csv")
  isfile("kid_diagnostics_$(i).csv") && rm("kid_diagnostics_$(i).csv")
  isfile("kid_optimize_$(i).csv") && rm("kid_optimize_$(i).csv")
  isfile("kid_diagnose_$(i).csv") && rm("kid_diagnose_$(i).csv")
end
isfile("kid.cpp") && rm("kid.cpp")
isfile("kid.stan") && rm("kid.stan")
isfile("kid") && rm("kid")
isfile("kid_build.log") && rm("kid_build.log")
isfile("kid_run.log") && rm("kid_run.log")

include(pwd()*"/kidscore.jl")

for i in 1:8
  isfile("kid_$(i).data.R") && rm("kid_$(i).data.R")
  isfile("kid_samples_$(i).csv") && rm("kid_samples_$(i).csv")
  isfile("kid_diagnostics_$(i).csv") && rm("kid_diagnostics_$(i).csv")
  isfile("kid_optimize_$(i).csv") && rm("kid_optimize_$(i).csv")
  isfile("kid_diagnose_$(i).csv") && rm("kid_diagnose_$(i).csv")
end
isfile("kid.cpp") && rm("kid.cpp")
isfile("kid.stan") && rm("kid.stan")
isfile("kid") && rm("kid")
isfile("kid_build.log") && rm("kid_build.log")
isfile("kid_run.log") && rm("kid_run.log")

cd(old);