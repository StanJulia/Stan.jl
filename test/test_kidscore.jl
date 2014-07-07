old = pwd()
dir = Pkg.dir("Stan")*"/Examples/ARM/Ch03/Kid/"
cd(dir)
println("Moving to directory: $(dir)")

for i in 1:8
  isfile("kid_samples_$(i).csv") && rm("kid_samples_$(i).csv")
  isfile("kid_diagnostics_$(i).csv") && rm("kid_diagnostics_$(i).csv")
end
isfile("kid") && rm("kid")
isfile("kid.cpp") && rm("kid.cpp")
isfile("kid.d") && rm("kid.d")
isfile("kid_build.log") && rm("kid_build.log")
isfile("kid_run.log") && rm("kid_run.log")

include(pwd()*"/kidscore.jl")

for i in 1:8
  isfile("kid_samples_$(i).csv") && rm("kid_samples_$(i).csv")
  isfile("kid_diagnostics_$(i).csv") && rm("kid_diagnostics_$(i).csv")
end
isfile("kid") && rm("kid")
isfile("kid.cpp") && rm("kid.cpp")
isfile("kid.d") && rm("kid.d")
isfile("kid_build.log") && rm("kid_build.log")
isfile("kid_run.log") && rm("kid_run.log")

cd(old);