old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "EightSchools")
cd(ProjDir)
println("Switched to directory: $(ProjDir)")

for i in 1:8
  isfile("schools8_$(i).data.R") && rm("schools8_$(i).data.R")
  isfile("schools8_samples_$(i).csv") && rm("schools8_samples_$(i).csv")
  isfile("schools8_diagnostics_$(i).csv") && rm("schools8_diagnostics_$(i).csv")
  isfile("schools8_optimize_$(i).csv") && rm("schools8_optimize_$(i).csv")
  isfile("schools8_diagnose_$(i).csv") && rm("schools8_diagnose_$(i).csv")
end
isfile("schools8.cpp") && rm("schools8.cpp")
isfile("schools8.stan") && rm("schools8.stan")
isfile("schools8") && rm("schools8")
isfile("schools8_build.log") && rm("schools8_build.log")
isfile("schools8_run.log") && rm("schools8_run.log")

include("$(ProjDir)/schools8.jl")

for i in 1:8
  isfile("schools8_$(i).data.R") && rm("schools8_$(i).data.R")
  isfile("schools8_samples_$(i).csv") && rm("schools8_samples_$(i).csv")
  isfile("schools8_diagnostics_$(i).csv") && rm("schools8_diagnostics_$(i).csv")
  isfile("schools8_optimize_$(i).csv") && rm("schools8_optimize_$(i).csv")
  isfile("schools8_diagnose_$(i).csv") && rm("schools8_diagnose_$(i).csv")
end
isfile("schools8.cpp") && rm("schools8.cpp")
isfile("schools8.stan") && rm("schools8.stan")
isfile("schools8") && rm("schools8")
isfile("schools8_build.log") && rm("schools8_build.log")
isfile("schools8_run.log") && rm("schools8_run.log")

cd(old);