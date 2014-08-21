old = pwd()
dir = Pkg.dir("Stan")*"/Examples/Bernoulli/"
cd(dir)
println("Moving to directory: $(dir)")

for i in 1:8
  isfile("bernoulli_$(i).data.R") && rm("bernoulli_$(i).data.R")
  isfile("bernoulli_samples_$(i).csv") && rm("bernoulli_samples_$(i).csv")
  isfile("bernoulli_diagnostics_$(i).csv") && rm("bernoulli_diagnostics_$(i).csv")
  isfile("bernoulli_optimize_$(i).csv") && rm("bernoulli_optimize_$(i).csv")
  isfile("bernoulli_diagnose_$(i).csv") && rm("bernoulli_diagnose_$(i).csv")
end
isfile("bernoulli.cpp") && rm("bernoulli.cpp")
isfile("bernoulli") && rm("bernoulli")
isfile("bernoulli_build.log") && rm("bernoulli_build.log")
isfile("bernoulli_run.log") && rm("bernoulli_run.log")

include("$(dir)bernoulli.jl")
for i in 1:8
  isfile("bernoulli_$(i).data.R") && rm("bernoulli_$(i).data.R")
  isfile("bernoulli_samples_$(i).csv") && rm("bernoulli_samples_$(i).csv")
  isfile("bernoulli_diagnostics_$(i).csv") && rm("bernoulli_diagnostics_$(i).csv")
end

include("$(dir)bernoulli_optimize.jl")
for i in 1:8
  isfile("bernoulli_$(i).data.R") && rm("bernoulli_$(i).data.R")
  isfile("bernoulli_optimize_$(i).csv") && rm("bernoulli_optimize_$(i).csv")
end

include("$(dir)bernoulli_diagnose.jl")
for i in 1:8
  isfile("bernoulli_$(i).data.R") && rm("bernoulli_$(i).data.R")
  isfile("bernoulli_diagnose_$(i).csv") && rm("bernoulli_diagnose_$(i).csv")
end

isfile("bernoulli.cpp") && rm("bernoulli.cpp")
isfile("bernoulli") && rm("bernoulli")
isfile("bernoulli_build.log") && rm("bernoulli_build.log")
isfile("bernoulli_run.log") && rm("bernoulli_run.log")

cd(old);