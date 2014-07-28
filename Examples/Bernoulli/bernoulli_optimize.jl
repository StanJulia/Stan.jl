######### Stan program example  ###########

using Stan

ProjDir = homedir()*"/.julia/v0.3/Stan/Examples/Bernoulli"
old = pwd()
cd(ProjDir)

stanmodel = Stanmodel(Optimize(), name="bernoulli");
data_file = "bernoulli.data.R"
optim = stan(stanmodel, data_file, ProjDir);
optim[1] |> display

cd(old)
