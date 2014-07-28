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

logistic(x::FloatingPoint) = one(x) / (one(x) + exp(-x))
logistic(x::Real) = logistic(float(x))
@vectorize_1arg Real logistic

println()
[logistic(chains[1][:diagnostics][:theta]) chains[1][:samples][:theta]][1:5,:] |> display

cd(old)
