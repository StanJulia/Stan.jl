######### Stan program example  ###########

using Stan

old = pwd()
ProjDir = homedir()*"/.julia/v0.3/Stan/Examples/Bernoulli"
cd(ProjDir)

stanmodel = Model(name="bernoulli");
data_file = "bernoulli.data.R"
samples_df = stan(stanmodel, data_file, ProjDir, diagnostics=true)

stan_summary("$(stanmodel.name)_samples_2.csv")

println()
read_stanfit(stanmodel)[1][:samples] |> display
println()

diags_2_df = read_stanfit("$(stanmodel.name)_diagnostics_2.csv")

println()
using StatsBase
println("Compare unconstrained diagnostics with sample_df results: \n")
println([logistic(diags_2_df[1:5, :theta]) samples_df[101:105, :theta]])
println()

cd(old)
