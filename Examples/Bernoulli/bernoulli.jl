######### Stan program example  ###########

using Stan

old = pwd()
ProjDir = homedir()*"/.julia/v0.3/Stan/Examples/Bernoulli"
cd(ProjDir)

stanmodel = Model(name="bernoulli");
data_file = "bernoulli.data.R"
samples_df = stan(stanmodel, data_file, ProjDir, diagnostics=true)

stan_summary("$(stanmodel.name)_samples_2.csv")
res = read_stanfit(stanmodel);

println("$(stanmodel.noofchains) chains: ")
for i in 1:stanmodel.noofchains
  res[i] |> display
  println()
end

println()
res[1][:samples] |> display
println()
res[1][:diagnostics] |> display
println()

diags_1_df = read_stanfit("$(stanmodel.name)_diagnostics_1.csv")

println()
using StatsBase
println("Compare unconstrained diagnostics with sample_df results: \n")
println([logistic(diags_1_df[1:5, :theta]) res[1][:samples][:theta][1:5]])
println()

cd(old)
