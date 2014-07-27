######### Stan program example  ###########

using DataFrames, Stan

ProjDir = homedir()*"/.julia/v0.3/Stan/Examples/Bernoulli"
old = pwd()
cd(ProjDir)

stanmodel = Stanmodel(Optimize(), name="bernoulli");
data_file = "bernoulli.data.R"
df = stan(stanmodel, data_file, ProjDir)

println(df)
cd(old)
