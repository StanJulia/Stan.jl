######## Stan diagnose example  ###########

using Stan

ProjDir = homedir()*"/.julia/v0.3/Stan/Examples/Bernoulli"
old = pwd()
cd(ProjDir)

# Shows an example of updating a Gradient setting.
stanmodel = Model(Diagnose(Gradient(epsilon=1e-6)), name="bernoulli");
data_file = "bernoulli.data.R"
diagnose = stan(stanmodel, data_file, ProjDir)

cd(old)

diagnose