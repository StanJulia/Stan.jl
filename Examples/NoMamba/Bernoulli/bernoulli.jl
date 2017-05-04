######### Stan program example  ###########

using Compat, Stan, Base.Test

ProjDir = dirname(@__FILE__)
cd(ProjDir) #do

bernoullimodel = "
data { 
  int<lower=1> N; 
  int<lower=0,upper=1> y[N];
} 
parameters {
  real<lower=0,upper=1> theta;
} 
model {
  theta ~ beta(1,1);
  y ~ bernoulli(theta);
}
"

bernoullidata = [
  Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
  Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
  Dict("N" => 10, "y" => [0, 0, 0, 0, 0, 0, 1, 0, 1, 1]),
  Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
]

monitor = ["theta", "lp__", "accept_stat__"]

stanmodel = Stanmodel(update=1200, thin=2, name="bernoulli", 
  model=bernoullimodel, useMamba=false);

println("\nStanmodel that will be used:")
stanmodel |> display
println()
println("Input observed data dictionary:")
bernoullidata |> display
println()

sim = stan(stanmodel, bernoullidata, ProjDir, diagnostics=false,
  CmdStanDir=CMDSTAN_HOME);


sim[1:10,:,1] |> display
println()

@test round(mean(sim[:,8,:]), 1) ≈ 0.3

#end # cd
