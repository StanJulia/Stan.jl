######### Stan program example  ###########

using Stan

old = pwd()
ProjDir = homedir()*"/.julia/v0.3/Stan/Examples/Bernoulli"
cd(ProjDir)

stanmodel = Stanmodel(name="bernoulli");
data_file = "bernoulli.data.R"
samples_df = stan(stanmodel, data_file, ProjDir, diagnostics=true)

stan_summary("$(stanmodel.name)_samples_2.csv")
chains = read_stanfit(stanmodel);

println("$(stanmodel.noofchains) chains: ")
for i in 1:stanmodel.noofchains
  chains[i] |> display
  println()
end

println()
chains[1][:samples] |> display
println()
chains[1][:diagnostics] |> display
println()

diags_1_df = read_stanfit("$(stanmodel.name)_diagnostics_1.csv");

println()

cd(old)
