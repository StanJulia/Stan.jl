######### Stan batch program example  ###########

using DataFrames, Stan
#using Distributions, MCMC, Gadfly

ProjDir = homedir()*"/.julia/v0.3/Stan/Examples/EightSchools"
old = pwd()
cd(ProjDir)

stanmodel = Stanmodel(name="schools8");
data_file = "schools8.data.R"
df = stan(stanmodel, data_file, ProjDir)

println(df)
showall(df[1:3, 7:24], true)
println()

cd(old)
