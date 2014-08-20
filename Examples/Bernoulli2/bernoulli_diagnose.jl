######## Stan diagnose example  ###########

using Stan

ProjDir = homedir()*"/.julia/v0.3/Stan/Examples/Bernoulli"
old = pwd()
cd(ProjDir)

# Shows an example of updating a Gradient setting.
stanmodel = Stanmodel(Diagnose(Gradient(epsilon=1e-6)), name="bernoulli");
data_file = "bernoulli.data.R"
diags = stan(stanmodel, data_file, ProjDir);
diags[1][:diagnose] |> display

cd(old)
