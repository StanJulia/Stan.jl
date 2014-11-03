function clean_dir(name::String, N=8; all=true)
  for i in 1:N
    isfile("$(name)_$(i).data.R") && rm("$(name)_$(i).data.R")
    isfile("$(name)_samples_$(i).csv") && rm("$(name)_samples_$(i).csv")
    isfile("$(name)_diagnostics_$(i).csv") && rm("$(name)_diagnostics_$(i).csv")
    isfile("$(name)_optimize_$(i).csv") && rm("$(name)_optimize_$(i).csv")
    isfile("$(name)_diagnose_$(i).csv") && rm("$(name)_diagnose_$(i).csv")
  end
  if all
    isfile("$(name).cpp") && rm("$(name).cpp")
    isfile("$(name).stan") && rm("$(name).stan")
    isfile("$(name)") && rm("$(name)")
    isfile("$(name)_build.log") && rm("$(name)_build.log")
    isfile("$(name)_run.log") && rm("$(name)_run.log")
  end
end

