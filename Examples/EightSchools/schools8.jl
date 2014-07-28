######### Stan batch program example  ###########

using Stan
#using Distributions, MCMC, Gadfly

ProjDir = homedir()*"/.julia/v0.3/Stan/Examples/EightSchools"
old = pwd()
cd(ProjDir)

stanmodel = Stanmodel(name="schools8");
data_file = "schools8.data.R"
chains = stan(stanmodel, data_file, ProjDir)

println()
chains[1][:samples] |> display
println()

cd(old)
