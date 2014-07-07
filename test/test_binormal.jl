old = pwd()
dir = Pkg.dir("Stan")*"/Examples/Binormal/"
cd(dir)
println("Moving to directory: $(dir)")

for i in 1:8
  isfile("binormal_samples_$(i)_$(i).csv") && rm("binormal_samples_$(i).csv")
end
isfile("binormal.cpp") && rm("binormal.cpp")
isfile("binormal") && rm("binormal")
isfile("binormal_build.log") && rm("binormal_build.log")
isfile("binormal_run.log") && rm("binormal_run.log")

include("$(dir)binormal.jl")
for i in 1:8
  isfile("binormal_samples_$(i).csv") && rm("binormal_samples_$(i).csv")
end

isfile("binormal.cpp") && rm("binormal.cpp")
isfile("binormal") && rm("binormal")
isfile("binormal_build.log") && rm("binormal_build.log")
isfile("binormal_run.log") && rm("binormal_run.log")

cd(old);